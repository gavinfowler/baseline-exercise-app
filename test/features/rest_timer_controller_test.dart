import 'package:exercise_app/features/rest_timer/rest_timer_controller.dart';
import 'package:exercise_app/features/rest_timer/rest_timer_state.dart';
import 'package:exercise_app/services/rest_alerts.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RecordingRestAlerts alerts;

  /// Runs [body] with time under the test's control, so a two-minute rest is
  /// verified instantly rather than actually waiting.
  void withTimer(
    void Function(RestTimerController timer, FakeAsync async) body,
  ) {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [restAlertsProvider.overrideWithValue(alerts)],
      );
      addTearDown(container.dispose);
      body(container.read(restTimerProvider.notifier), async);
    });
  }

  setUp(() => alerts = RecordingRestAlerts());

  test('starts idle', () {
    withTimer((timer, async) {
      expect(timer.state.status, RestTimerStatus.idle);
      expect(timer.state.isActive, isFalse);
    });
  });

  test('counts down once per second', () {
    withTimer((timer, async) {
      timer.start(90);
      expect(timer.state.remainingSeconds, 90);
      expect(timer.state.isRunning, isTrue);

      async.elapse(const Duration(seconds: 1));
      expect(timer.state.remainingSeconds, 89);

      async.elapse(const Duration(seconds: 29));
      expect(timer.state.remainingSeconds, 60);
    });
  });

  test('finishes at zero and alerts exactly once', () {
    withTimer((timer, async) {
      timer.start(3);
      async.elapse(const Duration(seconds: 3));

      expect(timer.state.status, RestTimerStatus.finished);
      expect(timer.state.remainingSeconds, 0);
      expect(alerts.alertCount, 1);

      // The ticker must stop; letting it run would re-alert every second.
      async.elapse(const Duration(seconds: 10));
      expect(alerts.alertCount, 1);
    });
  });

  test(
    'schedules an OS notification up front so a backgrounded app still alerts',
    () {
      withTimer((timer, async) {
        timer.start(120);
        expect(alerts.scheduled, [const Duration(seconds: 120)]);
      });
    },
  );

  test(
    'cancels the scheduled notification when it finishes in the foreground',
    () {
      withTimer((timer, async) {
        timer.start(2);
        final cancelsBefore = alerts.cancelCount;

        async.elapse(const Duration(seconds: 2));

        // Otherwise the user gets both an in-app chime and a notification.
        expect(alerts.cancelCount, greaterThan(cancelsBefore));
        expect(alerts.alertCount, 1);
      });
    },
  );

  test('progress runs from zero to one', () {
    withTimer((timer, async) {
      timer.start(100);
      expect(timer.state.progress, 0);

      async.elapse(const Duration(seconds: 25));
      expect(timer.state.progress, closeTo(0.25, 1e-9));

      async.elapse(const Duration(seconds: 75));
      expect(timer.state.progress, 1.0);
    });
  });

  group('pause and resume', () {
    test('pausing holds the countdown', () {
      withTimer((timer, async) {
        timer.start(60);
        async.elapse(const Duration(seconds: 10));
        timer.pause();

        async.elapse(const Duration(seconds: 30));
        expect(timer.state.remainingSeconds, 50);
        expect(timer.state.isPaused, isTrue);
      });
    });

    test('pausing cancels the scheduled alert, which would now fire early', () {
      withTimer((timer, async) {
        timer.start(60);
        async.elapse(const Duration(seconds: 10));
        timer.pause();
        expect(alerts.cancelCount, greaterThan(0));
      });
    });

    test('resuming continues and reschedules for the time left', () {
      withTimer((timer, async) {
        timer.start(60);
        async.elapse(const Duration(seconds: 10));
        timer.pause();
        alerts.scheduled.clear();

        timer.resume();
        expect(alerts.scheduled, [const Duration(seconds: 50)]);

        async.elapse(const Duration(seconds: 50));
        expect(timer.state.isFinished, isTrue);
      });
    });

    test('resume does nothing when the timer is not paused', () {
      withTimer((timer, async) {
        timer.resume();
        expect(timer.state.status, RestTimerStatus.idle);
      });
    });
  });

  group('adjust', () {
    test('adding time extends the countdown', () {
      withTimer((timer, async) {
        timer.start(60);
        async.elapse(const Duration(seconds: 10));
        timer.adjust(30);

        expect(timer.state.remainingSeconds, 80);
        // The bar must not exceed full when time is added past the original.
        expect(timer.state.totalSeconds, 80);
        expect(timer.state.progress, lessThanOrEqualTo(1.0));
      });
    });

    test('removing time shortens the countdown', () {
      withTimer((timer, async) {
        timer.start(60);
        timer.adjust(-20);
        expect(timer.state.remainingSeconds, 40);
        expect(timer.state.totalSeconds, 60);
      });
    });

    test('removing more time than remains finishes the rest', () {
      withTimer((timer, async) {
        timer.start(30);
        timer.adjust(-60);

        expect(timer.state.isFinished, isTrue);
        expect(alerts.alertCount, 1);
      });
    });
  });

  group('stop', () {
    test('returns to idle without alerting', () {
      withTimer((timer, async) {
        timer.start(60);
        async.elapse(const Duration(seconds: 5));
        timer.stop();

        expect(timer.state.status, RestTimerStatus.idle);
        expect(alerts.alertCount, 0);

        // No stray tick may resurrect the countdown.
        async.elapse(const Duration(seconds: 60));
        expect(timer.state.status, RestTimerStatus.idle);
      });
    });
  });

  group('edge cases', () {
    test('a zero-second rest stays idle instead of alerting immediately', () {
      withTimer((timer, async) {
        timer.start(0);
        expect(timer.state.status, RestTimerStatus.idle);
        expect(alerts.alertCount, 0);
        expect(alerts.scheduled, isEmpty);
      });
    });

    test('restarting replaces the previous countdown', () {
      withTimer((timer, async) {
        timer.start(60);
        async.elapse(const Duration(seconds: 10));
        timer.start(30, label: 'Barbell Row');

        expect(timer.state.remainingSeconds, 30);
        expect(timer.state.label, 'Barbell Row');

        // The first countdown's ticker must not still be running.
        async.elapse(const Duration(seconds: 30));
        expect(timer.state.isFinished, isTrue);
        expect(alerts.alertCount, 1);
      });
    });
  });
}
