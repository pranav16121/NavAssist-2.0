import 'package:flutter/services.dart';
import 'voice_service.dart';

class AndroidVoiceService implements VoiceService {
  static const _channel = MethodChannel('com.navassist/voice');
  static const _eventChannel = EventChannel('com.navassist/voice/events');

  bool _isSpeaking = false;
  bool _isListening = false;

  @override
  Future<void> speak(String text) async {
    try {
      _isSpeaking = true;
      await _channel.invokeMethod('speak', {'text': text});
      _isSpeaking = false;
    } on PlatformException {
      _isSpeaking = false;
    }
  }

  @override
  Future<void> listen() async {
    try {
      _isListening = true;
      await _channel.invokeMethod('listen');
    } on PlatformException {
      _isListening = false;
    }
  }

  @override
  Future<void> stopSpeaking() async {
    await _channel.invokeMethod('stopSpeaking');
    _isSpeaking = false;
  }

  @override
  Future<void> stopListening() async {
    await _channel.invokeMethod('stopListening');
    _isListening = false;
  }

  @override
  Stream<String> get speechResults {
    return _eventChannel.receiveBroadcastStream().map((event) => event as String);
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isListening => _isListening;
}
