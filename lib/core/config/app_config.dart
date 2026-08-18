class AppConfig {
  /// Initial configurable prototype value for obstacle proximity estimation.
  static double obstacleCoverageThreshold = 0.50;

  /// Initial threshold for wall brightness variation.
  static int wallBrightnessThreshold = 40;

  /// Pixel sampling interval for wall detection analysis.
  static int pixelSamplingInterval = 8;

  /// Prototype step length in metres.
  static double assumedStepLength = 0.75;

  /// Default cooldown for urgent alerts (seconds).
  static Duration urgentAlertCooldown = const Duration(seconds: 4);

  /// Default cooldown for clear-path announcements (seconds).
  static Duration clearPathCooldown = const Duration(seconds: 8);

  /// ML Kit detection configuration.
  static const bool enableMultipleObjects = true;
  static const bool enableClassification = true;
}
