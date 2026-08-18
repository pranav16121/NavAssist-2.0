import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/indoor_map.dart';
import '../../models/map_node.dart';
import '../../services/mapping/local_map_storage_service.dart';
import '../../services/camera/android_camera_service.dart';
import '../../services/sensors/movement_tracker.dart';
import '../../core/utils/permission_utils.dart';

class MapBuilderScreen extends StatefulWidget {
  const MapBuilderScreen({super.key});

  @override
  State<MapBuilderScreen> createState() => _MapBuilderScreenState();
}

class _MapBuilderScreenState extends State<MapBuilderScreen> {
  final _storageService = LocalMapStorageService();
  final _cameraService = AndroidCameraService();
  final _movementTracker = MovementTracker();
  final _nameController = TextEditingController();
  final List<MapNode> _nodes = [];
  
  bool _isSaving = false;
  bool _permissionsGranted = false;
  bool _isCheckingPermissions = true;

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
      });
      if (granted) {
        _cameraService.start();
        _movementTracker.start();
        // Periodic rebuild to update sensor stats
        Timer.periodic(const Duration(milliseconds: 500), (t) {
          if (!mounted || _isSaving) { t.cancel(); return; }
          setState(() {});
        });
      }
    }
  }

  void _markPoint() {
    final turn = _nodes.isEmpty ? 'straight' : _movementTracker.getTurnDirection();
    final steps = _movementTracker.stepsSinceMark;
    final distance = _movementTracker.distanceSinceMark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final controller = TextEditingController(text: 'Point ${_nodes.length + 1}');
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('MARK POINT', style: TextStyle(color: Colors.yellow)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'NAME', labelStyle: TextStyle(color: Colors.yellow)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                print('MAPPING_DEBUG: Saving point: ${controller.text}');
                print('MAPPING_DEBUG: Steps since last: $steps, Distance: $distance, Turn: $turn');
                setState(() {
                  _nodes.add(MapNode(
                    id: const Uuid().v4(),
                    name: controller.text,
                    x: 0.0, y: 0.0,
                    sequence: _nodes.length,
                    stepsFromPrevious: steps,
                    distanceFromPrevious: distance,
                    turn: turn,
                  ));
                  _movementTracker.resetSegment();
                });
                Navigator.pop(context);
              },
              child: const Text('SAVE POINT'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveMap() async {
    if (_nameController.text.isEmpty || _nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and points required')));
      return;
    }
    setState(() => _isSaving = true);
    final map = IndoorMap(name: _nameController.text, version: 1, nodes: _nodes, edges: []);
    await _storageService.saveMap(map);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _cameraService.stop();
    _movementTracker.stop();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_permissionsGranted) return const Scaffold(body: Center(child: Text('Permissions required')));

    final textureId = _cameraService.textureId;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (textureId != null) Positioned.fill(child: Texture(textureId: textureId)),
          SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'MAP NAME', labelStyle: TextStyle(color: Colors.yellow)),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStats(),
                        _buildPointList(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(onPressed: _markPoint, child: const Text('MARK POINT')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]), child: const Text('CANCEL'))),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: _saveMap, child: const Text('SAVE MAP'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black87, border: Border.all(color: Colors.yellow)),
      child: Column(
        children: [
          Text('STEPS: ${_movementTracker.stepsSinceMark}', style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
          Text('DISTANCE: ${_movementTracker.distanceSinceMark.toStringAsFixed(1)}m', style: const TextStyle(color: Colors.white, fontSize: 18)),
          Text('HEADING: ${_movementTracker.heading.toInt()}°', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPointList() {
    return Column(
      children: _nodes.map((n) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.black45,
        child: ListTile(
          title: Text(n.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text('${n.stepsFromPrevious} steps | ${n.turn.toUpperCase()}', style: const TextStyle(color: Colors.white70)),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _nodes.remove(n))),
        ),
      )).toList(),
    );
  }
}
