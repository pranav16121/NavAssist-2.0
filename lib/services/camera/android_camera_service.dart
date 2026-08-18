import 'package:flutter/services.dart';
import 'camera_service.dart';

class AndroidCameraService implements CameraService {
  static const _channel = MethodChannel('com.navassist/camera');

  int? _textureId;
  bool _isActive = false;

  @override
  Future<void> start() async {
    try {
      final id = await _channel.invokeMethod<int>('start');
      _textureId = id;
      _isActive = true;
    } on PlatformException {
      _isActive = false;
    }
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod('stop');
    _textureId = null;
    _isActive = false;
  }

  @override
  bool get isActive => _isActive;

  @override
  Stream<dynamic> get frameStream => const Stream.empty(); // Frames processed natively

  int? get textureId => _textureId;
}
