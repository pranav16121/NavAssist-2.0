import '../../models/indoor_map.dart';
import '../../models/map_node.dart';

abstract class NavigationService {
  /// Starts navigation to the [destination] on the given [map].
  Future<void> startNavigation(IndoorMap map, MapNode destination);

  /// Stops active navigation.
  Future<void> stopNavigation();

  /// Pauses navigation (e.g., for obstacle interruption).
  void pauseNavigation();

  /// Resumes navigation.
  void resumeNavigation();

  /// Stream of navigation instructions.
  Stream<String> get instructions;

  /// Stream of progress (e.g., distance to destination).
  Stream<double> get progress;

  /// Whether navigation is currently active.
  bool get isActive;
}
