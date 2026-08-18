import 'dart:async';

abstract class CameraService {
  /// Starts the camera stream.
  Future<void> start();

  /// Stops the camera stream.
  Future<void> stop();

  /// Whether the camera is currently active.
  bool get isActive;

  /// Stream of image data frames (type to be refined in Phase 2).
  Stream<dynamic> get frameStream;
}
