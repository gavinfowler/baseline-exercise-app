/// How the app tells the user their rest is over.
///
/// Split behind an interface so the timer's logic can be tested without any
/// platform plugin, and so desktop can fall back to a no-op cleanly.
abstract interface class RestAlerts {
  /// Books an OS notification for when the rest ends.
  ///
  /// Scheduled up front rather than fired on completion, because a Dart timer
  /// does not reliably run once the app is backgrounded — which is exactly when
  /// the user needs the reminder.
  Future<void> scheduleCompletionAlert({
    required Duration after,
    String? label,
  });

  /// Cancels a pending scheduled alert (rest was stopped, or finished while the
  /// app was in the foreground and already chimed).
  Future<void> cancelCompletionAlert();

  /// Immediate in-app feedback: sound and vibration.
  Future<void> alertNow();
}

/// Does nothing. Used in tests and on platforms without notification support.
class NoopRestAlerts implements RestAlerts {
  const NoopRestAlerts();

  @override
  Future<void> scheduleCompletionAlert({
    required Duration after,
    String? label,
  }) async {}

  @override
  Future<void> cancelCompletionAlert() async {}

  @override
  Future<void> alertNow() async {}
}

/// Records calls instead of making them, for assertions in tests.
class RecordingRestAlerts implements RestAlerts {
  final List<Duration> scheduled = [];
  int cancelCount = 0;
  int alertCount = 0;

  @override
  Future<void> scheduleCompletionAlert({
    required Duration after,
    String? label,
  }) async {
    scheduled.add(after);
  }

  @override
  Future<void> cancelCompletionAlert() async {
    cancelCount++;
  }

  @override
  Future<void> alertNow() async {
    alertCount++;
  }
}
