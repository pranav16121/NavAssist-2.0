import '../../models/indoor_map.dart';

abstract class MapStorageService {
  /// Saves the [map] to local storage.
  Future<void> saveMap(IndoorMap map);

  /// Loads a map by [name] from local storage.
  Future<IndoorMap?> loadMap(String name);

  /// Lists all saved map names.
  Future<List<String>> listMaps();

  /// Deletes a map by [name].
  Future<void> deleteMap(String name);
}
