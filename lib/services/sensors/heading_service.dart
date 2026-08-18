abstract class HeadingService {
  /// Starts heading tracking.
  Future<void> start();

  /// Stops heading tracking.
  Future<void> stop();

  /// Stream of heading values in degrees (0-360).
  Stream<double> get heading;
}
