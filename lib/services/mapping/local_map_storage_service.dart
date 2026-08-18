import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/indoor_map.dart';
import 'map_storage_service.dart';

class LocalMapStorageService implements MapStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/maps';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  @override
  Future<void> saveMap(IndoorMap map) async {
    final path = await _localPath;
    final file = File('$path/${map.name}.json');
    final jsonString = jsonEncode(map.toJson());
    await file.writeAsString(jsonString);
  }

  @override
  Future<IndoorMap?> loadMap(String name) async {
    try {
      final path = await _localPath;
      final file = File('$path/$name.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return IndoorMap.fromJson(jsonMap);
      }
    } catch (e) {
      // Handle error or return null
    }
    return null;
  }

  @override
  Future<List<String>> listMaps() async {
    final path = await _localPath;
    final dir = Directory(path);
    final List<String> mapNames = [];
    if (await dir.exists()) {
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (var entity in entities) {
        if (entity is File && entity.path.endsWith('.json')) {
          final fileName = entity.path.split('/').last.split('\\').last;
          mapNames.add(fileName.replaceAll('.json', ''));
        }
      }
    }
    return mapNames;
  }

  @override
  Future<void> deleteMap(String name) async {
    final path = await _localPath;
    final file = File('$path/$name.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
