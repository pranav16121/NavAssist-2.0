class AlertCooldownManager {
  final Map<String, DateTime> _lastAlertTimes = {};

  /// Checks if an alert of [type] can be triggered based on the [cooldown].
  bool canTrigger(String type, Duration cooldown) {
    final now = DateTime.now();
    final lastTime = _lastAlertTimes[type];
    
    if (lastTime == null || now.difference(lastTime) > cooldown) {
      _lastAlertTimes[type] = now;
      return true;
    }
    return false;
  }

  /// Resets the cooldown for a specific alert [type].
  void reset(String type) {
    _lastAlertTimes.remove(type);
  }
}
