import 'package:exercise_app/features/rest_timer/rest_timer_bar.dart';
import 'package:exercise_app/features/rest_timer/rest_timer_controller.dart';
import 'package:exercise_app/services/rest_alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget coverage for the rest bar.
///
/// Needs no database, so it runs in the normal widget-test environment. UI that
/// reads from the database is exercised in `integration_test/` instead, where
/// real async makes drift behave.
void main() {
  late ProviderContainer container;

  Future<void> pumpBar(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [restAlertsProvider.overrideWithValue(const NoopRestAlerts())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          // Material 3's default InkSparkle loads a fragment shader the widget
          // test environment cannot compile, which fails the first test to tap
          // anything. The ripple looks the same here and needs no shader.
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: const Scaffold(body: Column(children: [RestTimerBar()])),
        ),
      ),
    );
  }

  RestTimerController timer() => container.read(restTimerProvider.notifier);

  testWidgets('is invisible while idle', (tester) async {
    await pumpBar(tester);

    // It sits in the workout screen permanently, so it must cost no space
    // between sets.
    expect(find.byType(RestTimerBar), findsOneWidget);
    expect(find.byTooltip('Skip rest'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('shows the remaining time once started', (tester) async {
    await pumpBar(tester);

    timer().start(90, label: 'Barbell Row');
    await tester.pump();

    expect(find.text('1:30'), findsOneWidget);
    expect(find.text('Next: Barbell Row'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:29'), findsOneWidget);

    timer().stop();
    await tester.pump();
  });

  testWidgets('+30s and -15s adjust the countdown', (tester) async {
    await pumpBar(tester);

    timer().start(60);
    await tester.pump();

    await tester.tap(find.text('+30s'));
    await tester.pump();
    expect(find.text('1:30'), findsOneWidget);

    await tester.tap(find.text('-15s'));
    await tester.pump();
    expect(find.text('1:15'), findsOneWidget);

    timer().stop();
    await tester.pump();
  });

  testWidgets('pause swaps to a resume control and holds the time', (
    tester,
  ) async {
    await pumpBar(tester);

    timer().start(60);
    await tester.pump();

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.byTooltip('Resume'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('1:00'), findsOneWidget);

    await tester.tap(find.byTooltip('Resume'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:59'), findsOneWidget);

    timer().stop();
    await tester.pump();
  });

  testWidgets('announces completion and offers dismissal', (tester) async {
    await pumpBar(tester);

    timer().start(2);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Rest complete'), findsOneWidget);
    // Adjust controls disappear once there is nothing left to adjust.
    expect(find.text('+30s'), findsNothing);
    expect(find.byTooltip('Dismiss'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pump();
    expect(find.text('Rest complete'), findsNothing);
  });

  testWidgets('skipping hides the bar immediately', (tester) async {
    await pumpBar(tester);

    timer().start(120);
    await tester.pump();
    expect(find.byTooltip('Skip rest'), findsOneWidget);

    await tester.tap(find.byTooltip('Skip rest'));
    await tester.pump();

    expect(find.byTooltip('Skip rest'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
