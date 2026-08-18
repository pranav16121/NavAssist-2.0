import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'obstacle_detection_service.dart';
import 'wall_detection_service.dart';

class AndroidDetectionService implements ObstacleDetectionService, WallDetectionService {
  static const _eventChannel = EventChannel('com.navassist/detection');
  
  // Singleton controller to ensure only one subscription to the platform channel
  static final StreamController<dynamic> _broadcastController = StreamController<dynamic>.broadcast();
  static StreamSubscription? _platformSubscription;

  AndroidDetectionService() {
    _initSubscription();
  }

  static void _initSubscription() {
    if (_platformSubscription == null) {
      debugPrint('EVENT_DEBUG: Initializing platform subscription for DETECTION_CHANNEL');
      _platformSubscription = _eventChannel.receiveBroadcastStream().listen(
        (event) {
          debugPrint('EVENT_DEBUG: Dart received raw event: $event');
          _broadcastController.add(event);
        },
        onError: (error) {
          debugPrint('EVENT_DEBUG: Platform subscription error: $error');
          _broadcastController.addError(error);
        },
        onDone: () {
          debugPrint('EVENT_DEBUG: Platform subscription closed');
          _platformSubscription = null;
        },
      );
    }
  }

  @override
  Future<void> start() async {
    _initSubscription();
  }

  @override
  Future<void> stop() async {
    // We don't necessarily want to stop the singleton subscription here
    // as other services might still be using it.
  }

  @override
  Stream<List<DetectedObstacle>> get detections {
    return _broadcastController.stream
        .where((event) => event is Map && event['label'] != null)
        .map((event) {
          debugPrint('EVENT_DEBUG: Mapping to DetectedObstacle list');
          final data = event as Map;
          return [
            DetectedObstacle(
              label: data['label'] as String,
              confidence: (data['confidence'] as num).toDouble(),
              proximity: (data['coverage'] as num).toDouble(),
            )
          ];
        });
  }

  @override
  Stream<WallState> get wallStates {
    return _broadcastController.stream
        .where((event) => event is Map && event['type'] == 'wall')
        .map((event) {
          debugPrint('EVENT_DEBUG: Mapping to WallState: ${event['state']}');
          final state = (event as Map)['state'] as String;
          switch (state) {
            case 'all': return WallState.uniform;
            case 'center_left': return WallState.left;
            case 'center_right': return WallState.right;
            case 'center': return WallState.center;
            default: return WallState.none;
          }
        });
  }
}
