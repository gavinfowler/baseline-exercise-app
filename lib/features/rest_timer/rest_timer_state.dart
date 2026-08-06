enum RestTimerStatus { idle, running, paused, finished }

/// Immutable snapshot of the between-sets rest countdown.
class RestTimerState {
  const RestTimerState({
    required this.status,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.label,
  });

  const RestTimerState.idle()
    : status = RestTimerStatus.idle,
      totalSeconds = 0,
      remainingSeconds = 0,
      label = null;

  final RestTimerStatus status;

  /// What the rest was set to, so the UI can draw progress against it even as
  /// the user adds or subtracts time.
  final int totalSeconds;

  final int remainingSeconds;

  /// What the user is resting before, e.g. "Barbell Row".
  final String? label;

  bool get isRunning => status == RestTimerStatus.running;

  bool get isPaused => status == RestTimerStatus.paused;

  bool get isFinished => status == RestTimerStatus.finished;

  /// True whenever the timer should be visible on screen.
  bool get isActive => status != RestTimerStatus.idle;

  /// 0.0 at the start through 1.0 when the rest is over.
  double get progress {
    if (totalSeconds <= 0) return 0;
    final elapsed = totalSeconds - remainingSeconds;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  RestTimerState copyWith({
    RestTimerStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    String? label,
  }) {
    return RestTimerState(
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RestTimerState &&
      other.status == status &&
      other.totalSeconds == totalSeconds &&
      other.remainingSeconds == remainingSeconds &&
      other.label == label;

  @override
  int get hashCode =>
      Object.hash(status, totalSeconds, remainingSeconds, label);

  @override
  String toString() =>
      'RestTimerState(${status.name}, $remainingSeconds/$totalSeconds)';
}
