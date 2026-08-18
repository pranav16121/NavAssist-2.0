import 'package:flutter/material.dart';
import '../../services/mapping/local_map_storage_service.dart';

class SavedMapsScreen extends StatefulWidget {
  const SavedMapsScreen({super.key});

  @override
  State<SavedMapsScreen> createState() => _SavedMapsScreenState();
}

class _SavedMapsScreenState extends State<SavedMapsScreen> {
  final _storageService = LocalMapStorageService();
  List<Map<String, dynamic>> _mapMetadata = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaps();
  }

  Future<void> _loadMaps() async {
    setState(() => _isLoading = true);
    final names = await _storageService.listMaps();
    final List<Map<String, dynamic>> meta = [];
    for (var name in names) {
      final map = await _storageService.loadMap(name);
      if (map != null) {
        meta.add({
          'name': map.name,
          'points': map.nodes.length,
          'distance': map.totalDistance,
          'date': map.createdAt,
        });
      }
    }
    if (mounted) {
      setState(() {
        _mapMetadata = meta;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SAVED MAPS')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : _mapMetadata.isEmpty
              ? const Center(child: Text('No maps found', style: TextStyle(color: Colors.white70, fontSize: 24)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mapMetadata.length,
                  itemBuilder: (context, index) {
                    final map = _mapMetadata[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.yellow), color: Colors.grey[900]),
                      child: ListTile(
                        onTap: () => Navigator.pushNamed(context, '/navigation'),
                        leading: const Icon(Icons.map, color: Colors.yellow, size: 40),
                        title: Text(map['name'].toString().toUpperCase(), style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 20)),
                        subtitle: Text('${map['points']} points | ${map['distance'].toStringAsFixed(1)}m total', style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _storageService.deleteMap(map['name']);
                            _loadMaps();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
