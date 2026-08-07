import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/features/plans/cardio_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Like the strength editor, this takes plain data classes and so needs no
/// database.
void main() {
  const metric = UnitFormatter(UnitSystem.metric);

  ExerciseRow exercise(CardioActivity activity, {String name = 'Treadmill'}) =>
      ExerciseRow(
        id: 1,
        name: name,
        nameKey: name.toLowerCase(),
        type: ExerciseType.cardio,
        cardioActivity: activity,
        isCustom: false,
        isArchived: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  PlanItemRow item({
    int? durationSeconds,
    double? distanceMeters,
    double? inclinePercent,
    int? resistanceLevel,
  }) => PlanItemRow(
    id: 1,
    planBlockId: 1,
    exerciseId: 1,
    orderIndex: 0,
    targetDurationSeconds: durationSeconds,
    targetDistanceMeters: distanceMeters,
    targetInclinePercent: inclinePercent,
    targetResistanceLevel: resistanceLevel,
    toFailure: false,
  );

  Future<List<CardioItemResult?>> openOn(
    WidgetTester tester,
    ExerciseRow on, {
    PlanItemRow? existing,
    UnitFormatter formatter = metric,
  }) async {
    final results = <CardioItemResult?>[];
    await tester.pumpWidget(
      MaterialApp(
        // Material 3's InkSparkle needs a fragment shader the widget-test
        // environment cannot compile.
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async => results.add(
                await showCardioItemEditor(
                  context,
                  exercise: on,
                  formatter: formatter,
                  existing: existing,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  group('machine settings', () {
    // These columns have existed since the first schema and the plan parser has
    // always read them, but no in-app editor could set one until this screen.
    testWidgets('a treadmill run is offered incline but not resistance', (
      tester,
    ) async {
      await openOn(tester, exercise(CardioActivity.run));

      expect(find.text('Target incline'), findsOneWidget);
      expect(find.text('Target resistance level'), findsNothing);
    });

    testWidgets('a rower is offered resistance but not incline', (
      tester,
    ) async {
      await openOn(tester, exercise(CardioActivity.row, name: 'Rower'));

      expect(find.text('Target resistance level'), findsOneWidget);
      expect(find.text('Target incline'), findsNothing);
    });

    testWidgets('a swim is offered neither', (tester) async {
      await openOn(tester, exercise(CardioActivity.swim, name: 'Swim'));

      expect(find.text('Machine settings'), findsNothing);
      expect(find.text('Target incline'), findsNothing);
      expect(find.text('Target resistance level'), findsNothing);
    });

    testWidgets('a cycle is offered resistance', (tester) async {
      await openOn(tester, exercise(CardioActivity.cycle, name: 'Bike'));

      expect(find.text('Target resistance level'), findsOneWidget);
    });

    testWidgets('an existing incline opens prefilled and saves back', (
      tester,
    ) async {
      final results = await openOn(
        tester,
        exercise(CardioActivity.run),
        existing: item(durationSeconds: 1800, inclinePercent: 6),
      );

      expect(find.widgetWithText(TextField, '6.0'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(results.single!.inclinePercent, 6);
    });

    testWidgets('a typed resistance level is reported', (tester) async {
      final results = await openOn(
        tester,
        exercise(CardioActivity.row, name: 'Rower'),
        existing: item(durationSeconds: 1200),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Target resistance level'),
        '7',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(results.single!.resistanceLevel, 7);
    });

    testWidgets('an activity without the field never reports one', (
      tester,
    ) async {
      // Editing a treadmill item that somehow carries a resistance level must
      // not silently keep it: the field was never shown, so the user could not
      // have meant it.
      final results = await openOn(
        tester,
        exercise(CardioActivity.run),
        existing: item(durationSeconds: 1800, resistanceLevel: 9),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(results.single!.resistanceLevel, isNull);
    });
  });

  group('steady and structured', () {
    testWidgets('opens on Steady with the duration prefilled', (tester) async {
      await openOn(
        tester,
        exercise(CardioActivity.run),
        existing: item(durationSeconds: 1800, distanceMeters: 5000),
      );

      expect(find.text('Steady'), findsOneWidget);
      expect(find.text('Structured'), findsOneWidget);
      expect(find.widgetWithText(TextField, '30:00'), findsOneWidget);
    });

    testWidgets('a steady effort saves its duration and distance', (
      tester,
    ) async {
      final results = await openOn(
        tester,
        exercise(CardioActivity.run),
        existing: item(durationSeconds: 1800, distanceMeters: 5000),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = results.single!;
      expect(saved.durationSeconds, 1800);
      expect(saved.distanceMeters, closeTo(5000, 0.5));
      // Nothing structured was built, so the column must stay clear rather than
      // holding an empty segment list.
      expect(saved.intervalsJson, isNull);
    });

    testWidgets('a stair climber hides the pace field', (tester) async {
      // Pace is meaningless without distance, and a stair climber has none.
      await openOn(tester, exercise(CardioActivity.stairs, name: 'Stairs'));

      expect(find.text('Target pace'), findsNothing);
      expect(find.text('Target duration'), findsOneWidget);
    });
  });
}
