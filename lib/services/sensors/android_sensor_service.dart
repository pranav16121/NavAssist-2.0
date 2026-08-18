import 'package:flutter/services.dart';
import 'step_detector_service.dart';
import 'heading_service.dart';

class AndroidSensorService implements StepDetectorService, HeadingService {
  static const _methodChannel = MethodChannel('com.navassist/sensors');
  static const _stepsChannel = EventChannel('com.navassist/sensors/steps');
  static const _headingChannel = EventChannel('com.navassist/sensors/heading');

  @override
  Future<void> start() async {
    await _methodChannel.invokeMethod('start');
  }

  @override
  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }

  @override
  Stream<int> get steps {
    return _stepsChannel.receiveBroadcastStream().map((event) => event as int);
  }

  @override
  Stream<double> get heading {
    return _headingChannel.receiveBroadcastStream().map((event) => (event as num).toDouble());
  }
}
