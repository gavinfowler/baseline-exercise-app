import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CardioTimerStatus { idle, running, paused, stopped }

/// One recorded lap.
class CardioLap {
  const CardioLap({required this.index, required this.durationSeconds});

  final int index;
  final int durationSeconds;
}

/// Immutable snapshot of the cardio stopwatch.
class CardioTimerState {
  const CardioTimerState({
    required this.status,
    required this.elapsedSeconds,
    required this.laps,
  });

  const CardioTimerState.idle()
    : status = CardioTimerStatus.idle,
      elapsedSeconds = 0,
      laps = const [];

  final CardioTimerStatus status;
  final int elapsedSeconds;
  final List<CardioLap> laps;

  bool get isRunning => status == CardioTimerStatus.running;

  bool get isPaused => status == CardioTimerStatus.paused;

  bool get isActive => status != CardioTimerStatus.idle;

  /// Elapsed time not yet closed into a lap.
  int get currentLapSeconds =>
      elapsedSeconds - laps.fold<int>(0, (sum, l) => sum + l.durationSeconds);

  CardioTimerState copyWith({
    CardioTimerStatus? status,
    int? elapsedSeconds,
    List<CardioLap>? laps,
  }) {
    return CardioTimerState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      laps: laps ?? this.laps,
    );
  }
}

final cardioTimerProvider =
    NotifierProvider<CardioTimerController, CardioTimerState>(
      CardioTimerController.new,
    );

/// A stopwatch for cardio done with the app open.
///
/// Deliberately a plain elapsed-second counter with laps — no GPS, no location
/// permission, nothing that needs a network. Distance is entered by the user or
/// read off the machine.
class CardioTimerController extends Notifier<CardioTimerState> {
  Timer? _ticker;

  @override
  CardioTimerState build() {
    ref.onDispose(_cancelTicker);
    return const CardioTimerState.idle();
  }

  void start() {
    if (state.isRunning) return;
    state = state.status == CardioTimerStatus.idle
        ? const CardioTimerState(
            status: CardioTimerStatus.running,
            elapsedSeconds: 0,
            laps: [],
          )
        : state.copyWith(status: CardioTimerStatus.running);
    _startTicker();
  }

  void pause() {
    if (!state.isRunning) return;
    _cancelTicker();
    state = state.copyWith(status: CardioTimerStatus.paused);
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(status: CardioTimerStatus.running);
    _startTicker();
  }

  /// Closes the current lap. Ignored when nothing has elapsed since the last
  /// one, so a double tap cannot create a zero-second split.
  void lap() {
    if (!state.isActive) return;
    final current = state.currentLapSeconds;
    if (current <= 0) return;

    state = state.copyWith(
      laps: [
        ...state.laps,
        CardioLap(index: state.laps.length, durationSeconds: current),
      ],
    );
  }

  /// Stops the stopwatch, keeping the elapsed time and laps so they can be
  /// saved onto the entry.
  void stop() {
    _cancelTicker();
    if (!state.isActive) return;
    state = state.copyWith(status: CardioTimerStatus.stopped);
  }

  void reset() {
    _cancelTicker();
    state = const CardioTimerState.idle();
  }

  /// Lets the user correct the elapsed time before saving — the app may have
  /// been started late.
  void setElapsed(int seconds) {
    state = state.copyWith(elapsedSeconds: seconds < 0 ? 0 : seconds);
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
