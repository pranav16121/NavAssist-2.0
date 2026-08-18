abstract class WallDetectionService {
  /// Starts the wall detection process.
  Future<void> start();

  /// Stops the wall detection process.
  Future<void> stop();

  /// Stream of wall detection results.
  Stream<WallState> get wallStates;
}

enum WallState { none, left, center, right, uniform }
