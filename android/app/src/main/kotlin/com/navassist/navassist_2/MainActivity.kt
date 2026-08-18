package com.navassist.navassist_2

import androidx.annotation.NonNull
import android.Manifest
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.navassist.navassist_2.perception.PerceptionManager
import com.navassist.navassist_2.sensors.SensorManager
import com.navassist.navassist_2.voice.VoiceManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var voiceManager: VoiceManager? = null
    private var sensorManager: SensorManager? = null
    private var perceptionManager: PerceptionManager? = null
    private var permissionResult: MethodChannel.Result? = null

    private val VOICE_CHANNEL = "com.navassist/voice"
    private val SENSOR_CHANNEL = "com.navassist/sensors"
    private val DETECTION_CHANNEL = "com.navassist/detection"
    private val CAMERA_CHANNEL = "com.navassist/camera"
    private val PERMISSIONS_CHANNEL = "com.navassist/permissions"

    private val PERMISSION_REQUEST_CODE = 1001

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        voiceManager = VoiceManager(this)
        sensorManager = SensorManager(this)
        perceptionManager = PerceptionManager(this, flutterEngine.renderer)

        // Permissions Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    result.success(checkAllPermissions())
                }
                "requestPermissions" -> {
                    permissionResult = result
                    requestAllPermissions()
                }
                else -> result.notImplemented()
            }
        }

        // Voice Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    voiceManager?.speak(text)
                    result.success(null)
                }
                "stopSpeaking" -> {
                    voiceManager?.stopSpeaking()
                    result.success(null)
                }
                "listen" -> {
                    voiceManager?.startListening()
                    result.success(null)
                }
                "stopListening" -> {
                    voiceManager?.stopListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$VOICE_CHANNEL/events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    voiceManager?.speechListener = { text ->
                        this@MainActivity.runOnUiThread {
                            events?.success(text)
                        }
                    }
                    voiceManager?.errorListener = { error ->
                        this@MainActivity.runOnUiThread {
                            events?.error("SPEECH_ERROR", error, null)
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    voiceManager?.speechListener = null
                    voiceManager?.errorListener = null
                }
            }
        )

        // Sensors Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    Log.d("MainActivity", "SENSOR_DEBUG: Method start called")
                    sensorManager?.start()
                    result.success(null)
                }
                "stop" -> {
                    Log.d("MainActivity", "SENSOR_DEBUG: Method stop called")
                    sensorManager?.stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$SENSOR_CHANNEL/steps").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d("MainActivity", "SENSOR_DEBUG: steps onListen called")
                    sensorManager?.stepListener = {
                        this@MainActivity.runOnUiThread {
                            Log.d("MainActivity", "SENSOR_DEBUG: Emitting step (1) to Flutter")
                            events?.success(1)
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    Log.d("MainActivity", "SENSOR_DEBUG: steps onCancel called")
                    sensorManager?.stepListener = null
                }
            }
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$SENSOR_CHANNEL/heading").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d("MainActivity", "SENSOR_DEBUG: heading onListen called")
                    sensorManager?.headingListener = { heading ->
                        this@MainActivity.runOnUiThread {
                            events?.success(heading)
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    Log.d("MainActivity", "SENSOR_DEBUG: heading onCancel called")
                    sensorManager?.headingListener = null
                }
            }
        )

        // Camera & Detection Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    perceptionManager?.start(result)
                }
                "stop" -> {
                    perceptionManager?.stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DETECTION_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d("MainActivity", "EVENT_DEBUG: onListen called for DETECTION_CHANNEL. Sink is null? ${events == null}")
                    perceptionManager?.detectionListener = { data ->
                        if (events != null) {
                            Log.d("MainActivity", "EVENT_DEBUG: Emitting object to Flutter: $data")
                            this@MainActivity.runOnUiThread {
                                events.success(data)
                            }
                        } else {
                            Log.e("MainActivity", "EVENT_DEBUG: Cannot emit object, sink is NULL")
                        }
                    }
                    perceptionManager?.wallListener = { state ->
                        if (events != null) {
                            val wallData = mapOf("type" to "wall", "state" to state)
                            Log.d("MainActivity", "EVENT_DEBUG: Emitting wall to Flutter: $wallData")
                            this@MainActivity.runOnUiThread {
                                events.success(wallData)
                            }
                        } else {
                            Log.e("MainActivity", "EVENT_DEBUG: Cannot emit wall, sink is NULL")
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    Log.d("MainActivity", "EVENT_DEBUG: onCancel called for DETECTION_CHANNEL")
                    perceptionManager?.detectionListener = null
                    perceptionManager?.wallListener = null
                }
            }
        )
    }

    override fun onDestroy() {
        voiceManager?.dispose()
        sensorManager?.stop()
        perceptionManager?.stop()
        super.onDestroy()
    }

    private fun checkAllPermissions(): Boolean {
        val permissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.ACTIVITY_RECOGNITION
        )
        for (permission in permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }

    private fun requestAllPermissions() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.ACTIVITY_RECOGNITION
            ),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            permissionResult?.success(allGranted)
            permissionResult = null
        }
    }
}
