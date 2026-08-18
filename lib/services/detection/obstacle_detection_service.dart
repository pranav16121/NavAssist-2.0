abstract class ObstacleDetectionService {
  /// Starts the obstacle detection process.
  Future<void> start();

  /// Stops the obstacle detection process.
  Future<void> stop();

  /// Stream of detected obstacles.
  Stream<List<DetectedObstacle>> get detections;
}

class DetectedObstacle {
  final String label;
  final double confidence;
  final double proximity; // Estimated distance/coverage

  DetectedObstacle({
    required this.label,
    required this.confidence,
    required this.proximity,
  });
}
