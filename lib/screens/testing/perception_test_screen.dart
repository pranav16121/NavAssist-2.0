import 'package:flutter/material.dart';
import '../../services/camera/android_camera_service.dart';
import '../../services/detection/android_detection_service.dart';
import '../../services/detection/obstacle_detection_service.dart';
import '../../services/detection/wall_detection_service.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/permission_utils.dart';

class PerceptionTestScreen extends StatefulWidget {
  const PerceptionTestScreen({super.key});

  @override
  State<PerceptionTestScreen> createState() => _PerceptionTestScreenState();
}

class _PerceptionTestScreenState extends State<PerceptionTestScreen> {
  final _cameraService = AndroidCameraService();
  final _detectionService = AndroidDetectionService();
  
  List<DetectedObstacle> _latestDetections = [];
  WallState _latestWallState = WallState.none;
  bool _permissionsGranted = false;
  bool _isCheckingPermissions = true;
  String? _errorMessage;
  int _totalEventsReceived = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final granted = await PermissionUtils.requestPerceptionPermissions();
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
        _isCheckingPermissions = false;
        _errorMessage = null;
      });
      if (granted) {
        _startPerception();
      }
    }
  }

  Future<void> _startPerception() async {
    try {
      await _cameraService.start();
      if (mounted) setState(() {});
      
      _detectionService.detections.listen((detections) {
        if (mounted) {
          debugPrint('DETECTION_5_SCREEN: Received ${detections.length} objects');
          setState(() {
            _latestDetections = detections;
            _totalEventsReceived++;
          });
        }
      });

      _detectionService.wallStates.listen((state) {
        if (mounted) {
          debugPrint('DETECTION_5_SCREEN: Received wall state: $state');
          setState(() {
            _latestWallState = state;
            _totalEventsReceived++;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.yellow)),
      );
    }

    if (!_permissionsGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('PERMISSIONS REQUIRED')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, color: Colors.yellow, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Camera, Microphone, and Activity permissions are required for perception.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _init,
                  child: const Text('GRANT PERMISSIONS'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('INITIALIZATION FAILED')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _init,
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final textureId = _cameraService.textureId;

    return Scaffold(
      appBar: AppBar(title: const Text('PERCEPTION TEST')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          if (textureId != null)
            Center(
              child: AspectRatio(
                aspectRatio: 3 / 4, // Typical portrait resolution
                child: Texture(textureId: textureId),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.yellow)),

          // 2. Detection Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusPanel(),
                  const Spacer(),
                  _buildDetectionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
    final wallColor = _latestWallState != WallState.none ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WALL STATE: ${_latestWallState.name.toUpperCase()}',
            style: TextStyle(color: wallColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'RAW EVENTS: $_totalEventsReceived',
            style: const TextStyle(color: Colors.yellow, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Threshold: BR < 40',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ML KIT DETECTIONS',
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.yellow),
          if (_latestDetections.isEmpty)
            const Text('No objects detected', style: TextStyle(color: Colors.white54))
          else
            ..._latestDetections.map((d) => _buildDetectionItem(d)),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(DetectedObstacle d) {
    final isClose = d.proximity >= AppConfig.obstacleCoverageThreshold;
    final statusColor = isClose ? Colors.red : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detected: ${d.label}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Confidence: ${(d.confidence * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            'Coverage: ${(d.proximity * 100).toStringAsFixed(0)}% | STATUS: ${isClose ? 'CLOSE' : 'NOT CLOSE'}',
            style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
