import 'dart:async';
import '../../models/indoor_map.dart';
import '../../models/map_node.dart';
import '../voice/android_voice_service.dart';
import '../sensors/movement_tracker.dart';
import 'navigation_service.dart';

class LocalNavigationService implements NavigationService {
  final _voiceService = AndroidVoiceService();
  final _movementTracker = MovementTracker();
  
  final _instructionsController = StreamController<String>.broadcast();
  final _progressController = StreamController<double>.broadcast();
  
  bool _isActive = false;
  int _currentIndex = 0;
  List<MapNode> _path = [];
  Timer? _navTimer;

  @override
  bool get isActive => _isActive;

  @override
  Stream<String> get instructions => _instructionsController.stream;

  @override
  Stream<double> get progress => _progressController.stream;

  @override
  Future<void> startNavigation(IndoorMap map, MapNode destination) async {
    _isActive = true;
    _path = map.nodes;
    _currentIndex = 0;
    _movementTracker.start();
    _movementTracker.resetSegment();
    
    print('NAV_DEBUG: Starting nav to ${destination.name}');
    print('NAV_DEBUG: Path length: ${_path.length} nodes');
    for (var i = 0; i < _path.length; i++) {
      print('NAV_DEBUG: Node $i: ${_path[i].name}, StepsReq: ${_path[i].stepsFromPrevious}');
    }
    
    _voiceService.speak("Navigation started to ${destination.name}");
    _processNextSegment();

    _navTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!_isActive) { t.cancel(); return; }
      _checkProgress();
    });
  }

  void _processNextSegment() {
    print('NAV_DEBUG: Processing segment index: $_currentIndex');
    if (_currentIndex >= _path.length - 1) {
      print('NAV_DEBUG: Arrival condition met in _processNextSegment');
      _voiceService.speak("You have reached your destination.");
      _instructionsController.add("ARRIVED");
      stopNavigation();
      return;
    }

    final nextNode = _path[_currentIndex + 1];
    String instruction = "Walk straight";
    if (nextNode.turn != 'straight') {
      instruction = "Turn ${nextNode.turn} and walk straight";
    }
    instruction += " to ${nextNode.name}";
    
    _voiceService.speak(instruction);
    _instructionsController.add(instruction);
  }

  void _checkProgress() {
    if (_currentIndex >= _path.length - 1) return;
    
    final target = _path[_currentIndex + 1];
    final currentSteps = _movementTracker.stepsSinceMark;
    
    if (target.stepsFromPrevious > 0) {
      final p = (currentSteps / target.stepsFromPrevious).clamp(0.0, 1.0);
      _progressController.add(p);
      
      if (currentSteps >= target.stepsFromPrevious) {
        print('NAV_DEBUG: Segment complete. Target steps: ${target.stepsFromPrevious}, Current: $currentSteps');
        _currentIndex++;
        _movementTracker.resetSegment();
        _processNextSegment();
      }
    } else {
      // Handle zero-step segment (e.g., immediate turn at start)
      print('NAV_DEBUG: Warning: Zero-step segment encountered at node: ${target.name}');
      // We advance only if it's the start or if we have a minimal time buffer
      // For the prototype, we advance to next segment but log the warning
      _progressController.add(1.0);
      _currentIndex++;
      _movementTracker.resetSegment();
      _processNextSegment();
    }
  }

  @override
  Future<void> stopNavigation() async {
    _isActive = false;
    _navTimer?.cancel();
    _movementTracker.stop();
    _instructionsController.add("Navigation stopped");
  }

  @override
  void pauseNavigation() {
    _isActive = false;
  }

  @override
  void resumeNavigation() {
    _isActive = true;
  }
  
  void dispose() {
    stopNavigation();
  }
}
