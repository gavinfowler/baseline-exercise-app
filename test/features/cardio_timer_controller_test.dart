import 'package:exercise_app/features/cardio/cardio_timer_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void withTimer(
    void Function(CardioTimerController timer, FakeAsync async) body,
  ) {
    fakeAsync((async) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      body(container.read(cardioTimerProvider.notifier), async);
    });
  }

  test('starts idle', () {
    withTimer((timer, async) {
      expect(timer.state.status, CardioTimerStatus.idle);
      expect(timer.state.elapsedSeconds, 0);
      expect(timer.state.isActive, isFalse);
    });
  });

  test('counts up once per second', () {
    withTimer((timer, async) {
      timer.start();
      async.elapse(const Duration(seconds: 90));
      expect(timer.state.elapsedSeconds, 90);
      timer.reset();
    });
  });

  test('pausing holds the elapsed time', () {
    withTimer((timer, async) {
      timer.start();
      async.elapse(const Duration(seconds: 30));
      timer.pause();

      async.elapse(const Duration(seconds: 60));
      expect(timer.state.elapsedSeconds, 30);

      timer.resume();
      async.elapse(const Duration(seconds: 10));
      expect(timer.state.elapsedSeconds, 40);
      timer.reset();
    });
  });

  test('resuming from paused does not restart the count', () {
    withTimer((timer, async) {
      timer.start();
      async.elapse(const Duration(seconds: 20));
      timer.pause();
      timer.start();

      expect(timer.state.elapsedSeconds, 20);
      expect(timer.state.isRunning, isTrue);
      timer.reset();
    });
  });

  group('laps', () {
    test('record the time since the previous lap', () {
      withTimer((timer, async) {
        timer.start();
        async.elapse(const Duration(seconds: 300));
        timer.lap();
        async.elapse(const Duration(seconds: 290));
        timer.lap();

        expect(timer.state.laps.map((l) => l.durationSeconds), [300, 290]);
        expect(timer.state.laps.map((l) => l.index), [0, 1]);
        timer.reset();
      });
    });

    test('currentLapSeconds tracks the open lap', () {
      withTimer((timer, async) {
        timer.start();
        async.elapse(const Duration(seconds: 300));
        timer.lap();
        async.elapse(const Duration(seconds: 45));

        expect(timer.state.currentLapSeconds, 45);
        timer.reset();
      });
    });

    test('a double tap cannot create a zero-second lap', () {
      withTimer((timer, async) {
        timer.start();
        async.elapse(const Duration(seconds: 60));
        timer.lap();
        timer.lap();

        expect(timer.state.laps, hasLength(1));
        timer.reset();
      });
    });

    test('lapping does nothing before the timer starts', () {
      withTimer((timer, async) {
        timer.lap();
        expect(timer.state.laps, isEmpty);
      });
    });
  });

  group('stop', () {
    test('keeps the elapsed time and laps so they can be saved', () {
      withTimer((timer, async) {
        timer.start();
        async.elapse(const Duration(seconds: 120));
        timer.lap();
        timer.stop();

        expect(timer.state.status, CardioTimerStatus.stopped);
        expect(timer.state.elapsedSeconds, 120);
        expect(timer.state.laps, hasLength(1));

        // The ticker must actually stop.
        async.elapse(const Duration(seconds: 60));
        expect(timer.state.elapsedSeconds, 120);
        timer.reset();
      });
    });
  });

  group('reset', () {
    test('clears everything back to idle', () {
      withTimer((timer, async) {
        timer.start();
        async.elapse(const Duration(seconds: 100));
        timer.lap();
        timer.reset();

        expect(timer.state.status, CardioTimerStatus.idle);
        expect(timer.state.elapsedSeconds, 0);
        expect(timer.state.laps, isEmpty);

        async.elapse(const Duration(seconds: 30));
        expect(timer.state.elapsedSeconds, 0);
      });
    });
  });

  group('setElapsed', () {
    test('lets the user correct a late start', () {
      withTimer((timer, async) {
        timer.start();
        async.elapse(const Duration(seconds: 60));
        timer.setElapsed(600);

        expect(timer.state.elapsedSeconds, 600);
        timer.reset();
      });
    });

    test('clamps negative input to zero', () {
      withTimer((timer, async) {
        timer.start();
        timer.setElapsed(-30);
        expect(timer.state.elapsedSeconds, 0);
        timer.reset();
      });
    });
  });
}
