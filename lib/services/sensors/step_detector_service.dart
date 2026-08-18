abstract class StepDetectorService {
  /// Starts step detection.
  Future<void> start();

  /// Stops step detection.
  Future<void> stop();

  /// Stream of cumulative step count or step events.
  Stream<int> get steps;
}
