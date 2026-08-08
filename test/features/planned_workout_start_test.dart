import 'package:exercise_app/app/providers.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/plan_repository.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/features/session/workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/test_database.dart';

/// The workout screen's empty state is where an active plan becomes useful:
/// before this, `isActive` was a label on the plans list and nothing read it.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late PlanRepository plans;
  late SessionRepository sessions;

  setUp(() {
    // createTestDatabase registers its own close.
    db = createTestDatabase();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        // The real one seeds the starter catalog on first build, which this
        // screen does not need and which would race the assertions. The int is
        // the number of exercises seeded.
        catalogSeedProvider.overrideWith((ref) => Future.value(0)),
      ],
    );
    plans = container.read(planRepositoryProvider);
    sessions = container.read(sessionRepositoryProvider);
    addTearDown(container.dispose);
  });

  /// Pumps the screen and lets its streams and the next-workout lookup arrive.
  ///
  /// Fixed pumps rather than `pumpAndSettle`: the empty state has no animation
  /// to settle once loaded, but the loading spinner before it never stops.
  Future<void> pumpWorkout(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          // Material 3's InkSparkle needs a fragment shader the widget-test
          // environment cannot compile.
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: const WorkoutScreen(),
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// An active plan whose single workout prescribes 3 × bench.
  Future<void> activePlanWithPush() async {
    final planId = await insertPlan(db, name: 'Upper/Lower');
    final dayId = await insertPlanDay(db, planId: planId, label: 'Push');
    final blockId = await insertPlanBlock(db, planDayId: dayId, rounds: 3);
    await insertPlanItem(
      db,
      planBlockId: blockId,
      exerciseId: await insertExercise(db),
      targetReps: 5,
      targetWeightKg: 80,
      weightMode: WeightMode.absolute,
    );
    await plans.setActivePlan(planId);
  }

  testWidgets('with no plan, only an empty session is offered', (tester) async {
    await pumpWorkout(tester);

    expect(find.text('Start workout'), findsOneWidget);
    // The demoted button, not the body copy, which says something similar.
    expect(find.text('Start an empty session instead'), findsNothing);
  });

  testWidgets('an active plan offers its next workout by name', (tester) async {
    await activePlanWithPush();
    await pumpWorkout(tester);

    expect(find.text('Start Push'), findsOneWidget);
    expect(find.textContaining('Upper/Lower'), findsOneWidget);
    // Ad-hoc workouts stay available, just demoted.
    expect(find.text('Start an empty session instead'), findsOneWidget);
  });

  testWidgets('a deactivated plan is not offered', (tester) async {
    // The other half of the deactivate control: it has to actually stop the
    // plan driving the workout screen.
    await activePlanWithPush();
    await plans.setActivePlan(null);
    await pumpWorkout(tester);

    expect(find.text('Start Push'), findsNothing);
    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('an active plan with no workouts falls back to empty', (
    tester,
  ) async {
    final planId = await insertPlan(db, name: 'Empty Plan');
    await plans.setActivePlan(planId);
    await pumpWorkout(tester);

    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('starting the planned workout lays out its prescription', (
    tester,
  ) async {
    await activePlanWithPush();
    await pumpWorkout(tester);

    await tapAndSettle(tester, find.text('Start Push'));

    final session = (await sessions.getActiveSession())!;
    expect(session.title, 'Push');
    expect(session.planId, isNotNull);

    final sets = await sessions.getStrengthSets(session.id);
    expect(sets, hasLength(3));
    expect(sets.every((s) => s.status == EntryStatus.pending), isTrue);
    expect(sets.every((s) => s.plannedReps == 5), isTrue);
    expect(sets.every((s) => s.plannedWeightKg == 80), isTrue);

    // And the screen has moved on to show it: the point of laying the
    // prescription out is that the session opens with the work already in it.
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Start Push'), findsNothing);
  });

  testWidgets('starting an empty session logs nothing against the plan', (
    tester,
  ) async {
    await activePlanWithPush();
    await pumpWorkout(tester);

    await tapAndSettle(tester, find.text('Start an empty session instead'));

    final session = (await sessions.getActiveSession())!;
    expect(session.planId, isNull);
    expect(session.planDayId, isNull);
    expect(await sessions.getStrengthSets(session.id), isEmpty);
  });
}
