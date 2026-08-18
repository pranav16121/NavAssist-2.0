package com.navassist.navassist_2.perception

import android.annotation.SuppressLint
import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Color
import android.util.Log
import android.util.Size
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class PerceptionManager(
    private val activity: Activity,
    private val textureRegistry: TextureRegistry
) {
    private val TAG = "PerceptionManager"
    private var cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var surfaceTextureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var firstFrameReceived = false
    
    var detectionListener: ((Map<String, Any>) -> Unit)? = null
    var wallListener: ((String) -> Unit)? = null

    private val objectDetector = ObjectDetection.getClient(
        ObjectDetectorOptions.Builder()
            .setDetectorMode(ObjectDetectorOptions.STREAM_MODE)
            .enableMultipleObjects()
            .enableClassification()
            .build()
    )

    fun start(result: MethodChannel.Result) {
        Log.d(TAG, "PERCEPTION_DEBUG: start() called")
        firstFrameReceived = false
        val cameraProviderFuture = ProcessCameraProvider.getInstance(activity)
        cameraProviderFuture.addListener({
            try {
                Log.d(TAG, "PERCEPTION_DEBUG: CameraProvider ready")
                val cameraProvider = cameraProviderFuture.get()

                // Preview for Flutter
                if (surfaceTextureEntry == null) {
                    surfaceTextureEntry = textureRegistry.createSurfaceTexture()
                }
                
                val textureId = surfaceTextureEntry?.id()
                Log.d(TAG, "PERCEPTION_DEBUG: Texture created with ID: $textureId")

                val preview = Preview.Builder().build().apply {
                    setSurfaceProvider { request ->
                        val surfaceTexture = surfaceTextureEntry?.surfaceTexture()
                        surfaceTexture?.setDefaultBufferSize(request.resolution.width, request.resolution.height)
                        val surface = android.view.Surface(surfaceTexture)
                        request.provideSurface(surface, ContextCompat.getMainExecutor(activity)) {
                            surface.release()
                        }
                    }
                }

                // Image Analysis for Perception
                val imageAnalysis = ImageAnalysis.Builder()
                    .setTargetResolution(Size(640, 480))
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .build()

                imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
                    if (!firstFrameReceived) {
                        firstFrameReceived = true
                        Log.d(TAG, "PERCEPTION_DEBUG: First frame received in analyzer")
                    }
                    processImage(imageProxy)
                }

                val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    activity as LifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalysis
                )
                
                Log.d(TAG, "PERCEPTION_DEBUG: Camera bound successfully. Returning textureId: $textureId")
                result.success(textureId)

            } catch (exc: Exception) {
                Log.e(TAG, "PERCEPTION_DEBUG: Camera initialization failed", exc)
                result.error("CAMERA_INITIALIZATION_FAILED", exc.message, null)
            }
        }, ContextCompat.getMainExecutor(activity))
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun processImage(imageProxy: ImageProxy) {
        val now = java.lang.System.currentTimeMillis()
        if (now % 2000 < 50) {
            Log.d(TAG, "PERCEPTION_DEBUG: processImage - Format: ${imageProxy.format}, Size: ${imageProxy.width}x${imageProxy.height}")
        }
        
        val mediaImage = imageProxy.image
        if (mediaImage == null) {
            Log.e(TAG, "PERCEPTION_DEBUG: processImage - mediaImage is NULL!")
            imageProxy.close()
            return
        }

        val inputImage = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)
        
        objectDetector.process(inputImage)
            .addOnSuccessListener { objects ->
                val count = objects.size
                Log.d(TAG, "MLKIT_DEBUG: Found $count objects")
                
                for (obj in objects) {
                    val label = obj.labels.firstOrNull()?.text ?: "unknown"
                    val conf = obj.labels.firstOrNull()?.confidence ?: 0.0f
                    val bounds = obj.boundingBox
                    val coverage = (bounds.width() * bounds.height()).toDouble() / (imageProxy.width * imageProxy.height).toDouble()
                    
                    val result = mutableMapOf<String, Any>(
                        "label" to label,
                        "confidence" to conf,
                        "coverage" to coverage,
                        "bounds" to mapOf(
                            "left" to bounds.left,
                            "top" to bounds.top,
                            "right" to bounds.right,
                            "bottom" to bounds.bottom
                        ),
                        "frameWidth" to imageProxy.width,
                        "frameHeight" to imageProxy.height
                    )
                    Log.d(TAG, "MLKIT_DEBUG: Emitting object: $label, Conf: $conf, Coverage: $coverage")
                    detectionListener?.invoke(result)
                }
            }
            .addOnFailureListener { e: Exception ->
                Log.e(TAG, "PERCEPTION_DEBUG: ML Kit Failure", e)
            }
            .addOnCompleteListener {
                detectWall(imageProxy)
                imageProxy.close()
            }
    }

    private fun detectWall(imageProxy: ImageProxy) {
        val width = imageProxy.width
        val interval = 8
        val threshold = 40
        
        val zones = mapOf(
            "left" to checkZone(imageProxy, 0, width / 3, interval, threshold),
            "center" to checkZone(imageProxy, width / 3, 2 * width / 3, interval, threshold),
            "right" to checkZone(imageProxy, 2 * width / 3, width, interval, threshold)
        )
        
        val result = if (zones["center"] == true) {
            if (zones["left"] == true && zones["right"] == true) "all"
            else if (zones["left"] == true) "center_left"
            else if (zones["right"] == true) "center_right"
            else "center"
        } else {
            "none"
        }
        
        wallListener?.invoke(result)
    }

    private fun checkZone(
        imageProxy: ImageProxy, 
        startX: Int, 
        endX: Int, 
        interval: Int, 
        threshold: Int
    ): Boolean {
        val yPlane = imageProxy.planes[0]
        val buffer = yPlane.buffer
        val rowStride = yPlane.rowStride
        val pixelStride = yPlane.pixelStride
        
        var minB = 255
        var maxB = 0
        var sampled = 0

        val h = imageProxy.height
        val w = imageProxy.width

        val startY = (h * 0.4).toInt()
        val endY = (h * 0.6).toInt()

        var y = startY
        while (y < endY) {
            var x = startX
            while (x < endX) {
                val index = (y * rowStride) + (x * pixelStride)
                if (index < buffer.remaining()) {
                    val b = buffer.get(index).toInt() and 0xFF
                    if (b < minB) minB = b
                    if (b > maxB) maxB = b
                    sampled++
                }
                x += interval
            }
            y += interval
        }

        val range = maxB - minB
        
        if (java.lang.System.currentTimeMillis() % 1000 < 50 && startX == w / 3) {
            Log.d(TAG, "PERCEPTION_DEBUG: Zone [Center] sampled $sampled. Range: $range (Min: $minB, Max: $maxB)")
        }

        return sampled > 0 && range < threshold
    }

    fun getTextureId(): Long? = surfaceTextureEntry?.id()

    fun stop() {
        surfaceTextureEntry?.release()
        surfaceTextureEntry = null
        cameraExecutor.shutdown()
    }
}
