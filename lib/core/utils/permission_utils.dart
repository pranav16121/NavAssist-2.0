import 'package:flutter/services.dart';

class PermissionUtils {
  static const _channel = MethodChannel('com.navassist/permissions');

  static Future<bool> requestPerceptionPermissions() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('requestPermissions');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> checkPerceptionPermissions() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('checkPermissions');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }
}
