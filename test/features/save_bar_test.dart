import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/models/run_segment.dart';
import 'package:exercise_app/features/plans/cardio_item_screen.dart';
import 'package:exercise_app/features/plans/run_builder_screen.dart';
import 'package:exercise_app/features/plans/save_bar.dart';
import 'package:exercise_app/features/plans/strength_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The three full-screen editors replaced a bottom sheet whose Save was a
/// full-width button under the form. Moving Save into the app bar made it a
/// small pill in the corner that read as missing, so these pin down where it is
/// and that there is only one of it.
void main() {
  const metric = UnitFormatter(UnitSystem.metric);

  ExerciseRow exercise(ExerciseType type) => ExerciseRow(
    id: 1,
    name: 'Barbell Bulgarian Split Squat',
    nameKey: 'barbell bulgarian split squat',
    type: type,
    cardioActivity: type == ExerciseType.cardio ? CardioActivity.run : null,
    isCustom: false,
    isArchived: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  Future<void> pump(WidgetTester tester, Widget screen) async {
    // A phone, not the default 800x600: the point of the bar is that it is
    // reachable on the smallest screen the app runs on.
    tester.view.physicalSize = const Size(392, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F4E)),
          // Material 3's InkSparkle needs a fragment shader the widget-test
          // environment cannot compile.
          splashFactory: InkRipple.splashFactory,
        ),
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
  }

  final screens = <String, Widget>{
    'strength': StrengthItemScreen(
      exercise: exercise(ExerciseType.strength),
      planMode: PlanMode.staticPlan,
      formatter: metric,
    ),
    'cardio': CardioItemScreen(
      exercise: exercise(ExerciseType.cardio),
      formatter: metric,
    ),
    'run builder': const RunBuilderScreen(
      initial: RunWorkout.empty,
      formatter: metric,
      exerciseName: 'Outdoor Run',
    ),
  };

  for (final entry in screens.entries) {
    group(entry.key, () {
      testWidgets('has exactly one Save, in a SaveBar', (tester) async {
        await pump(tester, entry.value);

        expect(find.text('Save'), findsOneWidget);
        expect(find.byType(SaveBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SaveBar),
            matching: find.text('Save'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('keeps Save out of the app bar', (tester) async {
        // Where it was: a pill in the top-right corner, easily read as absent.
        await pump(tester, entry.value);

        expect(
          find.descendant(of: find.byType(AppBar), matching: find.text('Save')),
          findsNothing,
        );
      });

      testWidgets('pins Save to the bottom, full width', (tester) async {
        await pump(tester, entry.value);

        final button = tester.getRect(
          find.descendant(
            of: find.byType(SaveBar),
            matching: find.byType(FilledButton),
          ),
        );

        expect(
          button.bottom,
          greaterThan(780 * 0.9),
          reason: 'Save should sit at the bottom of the screen',
        );
        expect(
          button.width,
          greaterThan(392 * 0.8),
          reason: 'Save should span the width, not sit in a corner',
        );
      });
    });
  }

  testWidgets('the totals bar fits a narrow phone', (tester) async {
    // Three totals at their longest overflowed the row, which clips silently in
    // a release build.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: const RunBuilderScreen(
          initial: RunWorkout([
            RunSegment(
              label: 'Warm-up',
              work: RunEffort(durationSeconds: 3870, paceSecPerKm: 390),
            ),
            RunSegment(
              label: 'Repeats',
              repeat: 12,
              work: RunEffort(distanceMeters: 12430, paceSecPerKm: 255),
            ),
          ]),
          formatter: metric,
          exerciseName: 'Outdoor Run',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
