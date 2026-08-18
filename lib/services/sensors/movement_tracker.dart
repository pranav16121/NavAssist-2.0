import 'dart:async';
import 'android_sensor_service.dart';
import '../../core/config/app_config.dart';

class MovementTracker {
  final _sensorService = AndroidSensorService();
  
  int _initialSteps = 0;
  int _currentSteps = 0;
  double _currentHeading = 0.0;
  double _initialHeading = 0.0;

  StreamSubscription? _stepsSub;
  StreamSubscription? _headingSub;

  int get stepsSinceMark => (_currentSteps - _initialSteps);
  double get distanceSinceMark => stepsSinceMark * AppConfig.assumedStepLength;
  double get heading => _currentHeading;

  void start() {
    _sensorService.start();
    _stepsSub = _sensorService.steps.listen((s) {
      print('MOVEMENT_DEBUG: Step event received from bridge: $s');
      _currentSteps += s;
      print('MOVEMENT_DEBUG: Total steps accumulated: $_currentSteps');
    });
    _headingSub = _sensorService.heading.listen((h) {
      _currentHeading = h;
    });
  }

  void resetSegment() {
    _initialSteps = _currentSteps;
    _initialHeading = _currentHeading;
    print('MOVEMENT_DEBUG: Segment reset. Baseline: $_initialSteps');
  }

  String getTurnDirection() {
    final diff = (_currentHeading - _initialHeading + 540) % 360 - 180;
    if (diff.abs() < 30) return 'straight';
    if (diff > 30 && diff < 120) return 'right';
    if (diff < -30 && diff > -120) return 'left';
    if (diff.abs() >= 120) return 'u_turn';
    return 'straight';
  }

  void stop() {
    _stepsSub?.cancel();
    _headingSub?.cancel();
    _sensorService.stop();
  }
}
