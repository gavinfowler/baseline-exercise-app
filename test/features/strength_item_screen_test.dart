import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/features/plans/strength_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The editor takes plain data classes rather than a database, so it can be
/// driven here rather than in `integration_test/`.
void main() {
  const metric = UnitFormatter(UnitSystem.metric);
  const imperial = UnitFormatter(UnitSystem.imperial);

  ExerciseRow exercise() => ExerciseRow(
    id: 1,
    name: 'Barbell Bench Press',
    nameKey: 'barbell bench press',
    type: ExerciseType.strength,
    isCustom: false,
    isArchived: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  PlanItemRow item({
    required WeightMode weightMode,
    double? weightOffsetKg,
    double? weightPercent,
  }) => PlanItemRow(
    id: 1,
    planBlockId: 1,
    exerciseId: 1,
    orderIndex: 0,
    targetReps: 5,
    targetWeightKg: 60,
    weightMode: weightMode,
    weightOffsetKg: weightOffsetKg,
    weightPercent: weightPercent,
    toFailure: false,
  );

  /// Opens the editor the way the plan day editor does, and holds whatever it
  /// returns when saved.
  Future<List<StrengthItemResult?>> openOn(
    WidgetTester tester,
    PlanItemRow existing, {
    UnitFormatter formatter = metric,
    PlanMode planMode = PlanMode.staticPlan,
  }) async {
    final results = <StrengthItemResult?>[];
    await tester.pumpWidget(
      MaterialApp(
        // Material 3's InkSparkle needs a fragment shader the widget-test
        // environment cannot compile.
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async => results.add(
                await showStrengthItemEditor(
                  context,
                  exercise: exercise(),
                  planMode: planMode,
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

  group('opening on an existing prescription', () {
    // A plan file can prescribe any weight mode, so the editor has to survive
    // being opened on every one of them. Missing baselinePlus from the dropdown
    // made this an assertion failure rather than a missing feature.
    for (final mode in WeightMode.values) {
      testWidgets('survives ${mode.wireName}', (tester) async {
        await openOn(
          tester,
          item(
            weightMode: mode,
            weightOffsetKg: mode == WeightMode.baselinePlus ? 2.5 : null,
            weightPercent: mode == WeightMode.baselinePercent ? 85 : null,
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          find.byType(DropdownButtonFormField<WeightMode>),
          findsOneWidget,
        );
      });
    }

    testWidgets('a periodized plan hides the baseline modes entirely', (
      tester,
    ) async {
      // Baseline modes never progress in a periodized plan, so offering them
      // would promise behaviour the plan will not perform.
      await openOn(
        tester,
        item(weightMode: WeightMode.baseline),
        planMode: PlanMode.periodized,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(DropdownButtonFormField<WeightMode>), findsNothing);
    });

    testWidgets('names the exercise and marks it as strength', (tester) async {
      await openOn(tester, item(weightMode: WeightMode.baseline));

      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
    });
  });

  group('baselinePlus', () {
    testWidgets('shows the offset rather than the weight', (tester) async {
      await openOn(
        tester,
        item(weightMode: WeightMode.baselinePlus, weightOffsetKg: 2.5),
      );

      expect(find.widgetWithText(TextField, '2.5'), findsOneWidget);
      expect(find.text('Amount to add'), findsOneWidget);
    });

    testWidgets('keeps the offset through a save', (tester) async {
      // The save path used to drop weightOffsetKg, so editing an imported
      // baselinePlus item silently turned it into a plain baseline.
      final results = await openOn(
        tester,
        item(weightMode: WeightMode.baselinePlus, weightOffsetKg: 2.5),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = results.single!;
      expect(saved.weightMode, WeightMode.baselinePlus);
      expect(saved.weightOffsetKg, closeTo(2.5, 0.0001));
    });

    testWidgets('converts a typed offset from the display unit', (
      tester,
    ) async {
      final results = await openOn(
        tester,
        item(weightMode: WeightMode.baselinePlus, weightOffsetKg: 2.5),
        formatter: imperial,
      );

      // 2.5 kg shows as 5.51 lb, so target the field by its label.
      await tester.enterText(
        find.widgetWithText(TextField, 'Amount to add'),
        '10',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Ten pounds, stored as kilograms.
      expect(results.single!.weightOffsetKg, closeTo(4.5359237, 0.0001));
    });
  });
}
