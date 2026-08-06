import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/rest_alerts.dart';
import 'rest_timer_state.dart';

/// Injected so tests and unsupported platforms can supply a no-op.
final restAlertsProvider = Provider<RestAlerts>(
  (ref) => const NoopRestAlerts(),
);

final restTimerProvider = NotifierProvider<RestTimerController, RestTimerState>(
  RestTimerController.new,
);

/// Drives the between-sets rest countdown.
///
/// The countdown ticks once a second in Dart for the on-screen display, and a
/// separate OS notification is scheduled up front to cover the case where the
/// user leaves the app — those two paths are deliberately independent.
class RestTimerController extends Notifier<RestTimerState> {
  Timer? _ticker;

  @override
  RestTimerState build() {
    ref.onDispose(_cancelTicker);
    return const RestTimerState.idle();
  }

  RestAlerts get _alerts => ref.read(restAlertsProvider);

  /// Begins (or restarts) a rest period.
  ///
  /// A non-positive duration is treated as "no rest" and leaves the timer idle
  /// rather than immediately firing an alert.
  void start(int seconds, {String? label}) {
    _cancelTicker();
    if (seconds <= 0) {
      state = const RestTimerState.idle();
      unawaited(_alerts.cancelCompletionAlert());
      return;
    }

    state = RestTimerState(
      status: RestTimerStatus.running,
      totalSeconds: seconds,
      remainingSeconds: seconds,
      label: label,
    );

    unawaited(
      _alerts.scheduleCompletionAlert(
        after: Duration(seconds: seconds),
        label: label,
      ),
    );
    _startTicker();
  }

  void pause() {
    if (!state.isRunning) return;
    _cancelTicker();
    state = state.copyWith(status: RestTimerStatus.paused);
    // The scheduled notification would still fire at the original time, which
    // would be wrong now that the countdown is held.
    unawaited(_alerts.cancelCompletionAlert());
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(status: RestTimerStatus.running);
    unawaited(
      _alerts.scheduleCompletionAlert(
        after: Duration(seconds: state.remainingSeconds),
        label: state.label,
      ),
    );
    _startTicker();
  }

  /// Adds or removes time mid-rest. Reaching zero via a negative adjustment
  /// finishes the rest exactly as running down to zero would.
  void adjust(int deltaSeconds) {
    if (!state.isActive || state.isFinished) return;

    final remaining = state.remainingSeconds + deltaSeconds;
    if (remaining <= 0) {
      _finish();
      return;
    }

    state = state.copyWith(
      remainingSeconds: remaining,
      // Keep the bar meaningful when time is added beyond the original total.
      totalSeconds: remaining > state.totalSeconds
          ? remaining
          : state.totalSeconds,
    );

    if (state.isRunning) {
      unawaited(
        _alerts.scheduleCompletionAlert(
          after: Duration(seconds: remaining),
          label: state.label,
        ),
      );
    }
  }

  /// Ends the rest early. No alert fires — the user already moved on.
  void stop() {
    _cancelTicker();
    state = const RestTimerState.idle();
    unawaited(_alerts.cancelCompletionAlert());
  }

  /// Dismisses a finished timer.
  void dismiss() {
    if (state.isFinished) stop();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = state.remainingSeconds - 1;
    if (remaining <= 0) {
      _finish();
      return;
    }
    state = state.copyWith(remainingSeconds: remaining);
  }

  void _finish() {
    _cancelTicker();
    state = state.copyWith(
      status: RestTimerStatus.finished,
      remainingSeconds: 0,
    );
    // The app is in the foreground (a Dart timer just fired), so chime here and
    // drop the scheduled notification to avoid alerting twice.
    unawaited(_alerts.cancelCompletionAlert());
    unawaited(_alerts.alertNow());
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
