import 'package:flutter/material.dart';
import '../../models/indoor_map.dart';
import '../../models/map_node.dart';
import '../../services/mapping/local_map_storage_service.dart';
import '../../services/navigation/local_navigation_service.dart';
import '../../services/camera/android_camera_service.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final _storageService = LocalMapStorageService();
  final _navService = LocalNavigationService();
  final _cameraService = AndroidCameraService();
  
  List<String> _maps = [];
  IndoorMap? _selectedMap;
  MapNode? _selectedDestination;
  String _instruction = 'SELECT A MAP';
  double _progress = 0.0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadMaps();
    _navService.instructions.listen((msg) {
      if (mounted) setState(() => _instruction = msg);
    });
    _navService.progress.listen((val) {
      if (mounted) setState(() => _progress = val);
    });
  }

  Future<void> _loadMaps() async {
    final maps = await _storageService.listMaps();
    if (mounted) setState(() => _maps = maps);
  }

  void _startNav() async {
    if (_selectedMap != null && _selectedDestination != null) {
      await _cameraService.start();
      setState(() => _isNavigating = true);
      _navService.startNavigation(_selectedMap!, _selectedDestination!);
    }
  }

  void _stopNav() {
    _navService.stopNavigation();
    _cameraService.stop();
    setState(() {
      _isNavigating = false;
      _progress = 0.0;
      _instruction = 'SELECT A MAP';
    });
  }

  @override
  void dispose() {
    _navService.dispose();
    _cameraService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textureId = _cameraService.textureId;

    return Scaffold(
      appBar: AppBar(title: const Text('NAVIGATION')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isNavigating && textureId != null)
            Positioned.fill(child: Texture(textureId: textureId)),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isNavigating) ...[
                  _buildSelectionUI(),
                ] else ...[
                  _buildNavigationUI(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('MAP', style: TextStyle(color: Colors.yellow, fontSize: 18)),
        DropdownButton<String>(
          isExpanded: true,
          value: _selectedMap?.name,
          dropdownColor: Colors.black,
          items: _maps.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(color: Colors.white)))).toList(),
          onChanged: (val) async {
            if (val != null) {
              final map = await _storageService.loadMap(val);
              setState(() {
                _selectedMap = map;
                _selectedDestination = map?.nodes.last;
              });
            }
          },
        ),
        if (_selectedMap != null) ...[
          const SizedBox(height: 16),
          const Text('DESTINATION', style: TextStyle(color: Colors.yellow, fontSize: 18)),
          DropdownButton<MapNode>(
            isExpanded: true,
            value: _selectedDestination,
            dropdownColor: Colors.black,
            items: _selectedMap!.nodes.map((n) => DropdownMenuItem(value: n, child: Text(n.name, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: (val) => setState(() => _selectedDestination = val),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _startNav, child: const Text('START NAVIGATION')),
        ],
      ],
    );
  }

  Widget _buildNavigationUI() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.black87,
          child: Column(
            children: [
              Text(_instruction.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.yellow, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _progress, minHeight: 12, color: Colors.yellow, backgroundColor: Colors.white24),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toInt()}% COMPLETE', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _stopNav,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('STOP NAVIGATION', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
