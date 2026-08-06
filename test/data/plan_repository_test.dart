import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/plan_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late PlanRepository repo;
  late int benchId;
  late int rowId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    repo = PlanRepository(db, clock: clock);
    benchId = await insertExercise(db);
    rowId = await insertExercise(db, name: 'Barbell Row');
  });

  group('creating plans', () {
    test('stores the mode and stamps timestamps', () async {
      final id = await repo.createPlan(
        name: 'Upper/Lower',
        mode: PlanMode.staticPlan,
      );

      final plan = await repo.findById(id);
      expect(plan!.name, 'Upper/Lower');
      expect(plan.mode, PlanMode.staticPlan);
      expect(plan.source, PlanSource.ui);
      expect(plan.isActive, isFalse);
      expect(plan.createdAt, clock.now());
    });

    test('records the duration of a periodized plan', () async {
      final id = await repo.createPlan(
        name: 'Block',
        mode: PlanMode.periodized,
        durationWeeks: 12,
      );

      expect((await repo.findById(id))!.durationWeeks, 12);
    });
  });

  group('activation', () {
    test('exactly one plan is active at a time', () async {
      final first = await repo.createPlan(name: 'A', mode: PlanMode.staticPlan);
      final second = await repo.createPlan(
        name: 'B',
        mode: PlanMode.staticPlan,
      );

      await repo.setActivePlan(first);
      expect((await repo.getActivePlan())!.id, first);

      await repo.setActivePlan(second);
      // The previous one must be deactivated, or `getActivePlan` would find two.
      expect((await repo.getActivePlan())!.id, second);
      expect((await repo.findById(first))!.isActive, isFalse);
    });

    test('passing null deactivates everything', () async {
      final id = await repo.createPlan(name: 'A', mode: PlanMode.staticPlan);
      await repo.setActivePlan(id);
      await repo.setActivePlan(null);

      expect(await repo.getActivePlan(), isNull);
    });
  });

  group('structure', () {
    late int planId;

    setUp(() async {
      planId = await repo.createPlan(name: 'Test', mode: PlanMode.staticPlan);
    });

    test('loads a day with its blocks and items in order', () async {
      final dayId = await repo.addDay(
        planId: planId,
        label: 'Upper A',
        orderIndex: 0,
      );

      final second = await repo.addBlock(planDayId: dayId, orderIndex: 1);
      final first = await repo.addBlock(
        planDayId: dayId,
        orderIndex: 0,
        kind: BlockKind.superset,
        rounds: 3,
      );

      await repo.addStrengthItem(
        planBlockId: first,
        exerciseId: rowId,
        orderIndex: 1,
        targetReps: 8,
      );
      await repo.addStrengthItem(
        planBlockId: first,
        exerciseId: benchId,
        orderIndex: 0,
        targetReps: 8,
        targetWeightKg: 60,
      );
      await repo.addCardioItem(
        planBlockId: second,
        exerciseId: benchId,
        orderIndex: 0,
        targetDurationSeconds: 600,
      );

      final detail = await repo.loadDay(dayId);

      expect(detail!.day.label, 'Upper A');
      expect(detail.blocks.map((b) => b.block.id), [first, second]);

      final superset = detail.blocks.first;
      expect(superset.block.kind, BlockKind.superset);
      // Items come back in performance order, not insertion order.
      expect(superset.items.map((i) => i.exerciseId), [benchId, rowId]);
      expect(superset.totalEntries, 6);
    });

    test('loadDay returns null for an unknown day', () async {
      expect(await repo.loadDay(9999), isNull);
    });

    test('a day with no blocks loads as empty rather than null', () async {
      final dayId = await repo.addDay(
        planId: planId,
        label: 'Rest',
        orderIndex: 0,
      );

      final detail = await repo.loadDay(dayId);
      expect(detail, isNotNull);
      expect(detail!.blocks, isEmpty);
    });

    test('days are ordered by week, then position', () async {
      await repo.addDay(
        planId: planId,
        label: 'W2D1',
        orderIndex: 0,
        weekNumber: 2,
      );
      await repo.addDay(
        planId: planId,
        label: 'W1D2',
        orderIndex: 1,
        weekNumber: 1,
      );
      await repo.addDay(
        planId: planId,
        label: 'W1D1',
        orderIndex: 0,
        weekNumber: 1,
      );

      final days = await repo.getDays(planId);
      expect(days.map((d) => d.label), ['W1D1', 'W1D2', 'W2D1']);
    });

    test('loadPlanDays returns every day fully populated', () async {
      for (var i = 0; i < 2; i++) {
        final dayId = await repo.addDay(
          planId: planId,
          label: 'Day ${i + 1}',
          orderIndex: i,
        );
        final blockId = await repo.addBlock(planDayId: dayId, orderIndex: 0);
        await repo.addStrengthItem(
          planBlockId: blockId,
          exerciseId: benchId,
          orderIndex: 0,
          targetReps: 8,
        );
      }

      final days = await repo.loadPlanDays(planId);
      expect(days, hasLength(2));
      expect(days.every((d) => d.blocks.single.items.length == 1), isTrue);
    });
  });

  group('editing', () {
    test('block settings can be changed without touching its items', () async {
      final planId = await repo.createPlan(
        name: 'Test',
        mode: PlanMode.staticPlan,
      );
      final dayId = await repo.addDay(
        planId: planId,
        label: 'Day 1',
        orderIndex: 0,
      );
      final blockId = await repo.addBlock(
        planDayId: dayId,
        orderIndex: 0,
        rounds: 3,
      );
      await repo.addStrengthItem(
        planBlockId: blockId,
        exerciseId: benchId,
        orderIndex: 0,
        targetReps: 8,
      );

      await repo.updateBlockSettings(
        blockId,
        rounds: 5,
        restAfterRoundSeconds: 150,
      );

      final block = (await repo.loadDay(dayId))!.blocks.single;
      expect(block.block.rounds, 5);
      expect(block.block.restAfterRoundSeconds, 150);
      expect(block.items, hasLength(1));
    });

    test('omitted settings are left alone', () async {
      final planId = await repo.createPlan(
        name: 'Test',
        mode: PlanMode.staticPlan,
      );
      final dayId = await repo.addDay(
        planId: planId,
        label: 'Day 1',
        orderIndex: 0,
      );
      final blockId = await repo.addBlock(
        planDayId: dayId,
        orderIndex: 0,
        rounds: 3,
        restAfterRoundSeconds: 90,
      );

      await repo.updateBlockSettings(blockId, rounds: 4);

      final block = (await repo.loadDay(dayId))!.blocks.single;
      expect(block.block.rounds, 4);
      expect(block.block.restAfterRoundSeconds, 90);
    });
  });

  group('deletion', () {
    test('deleting a plan removes its structure but keeps history', () async {
      final planId = await insertPlan(db);
      final dayId = await insertPlanDay(db, planId: planId);
      final blockId = await insertPlanBlock(db, planDayId: dayId);
      await insertPlanItem(db, planBlockId: blockId, exerciseId: benchId);
      final sessionId = await insertSession(db, planId: planId);
      await insertStrengthSet(db, sessionId: sessionId, exerciseId: benchId);

      await repo.deletePlan(planId);

      expect(await db.select(db.planDays).get(), isEmpty);
      expect(await db.select(db.planItems).get(), isEmpty);
      // The workout survives; only its plan reference is cleared.
      final session = (await db.select(db.sessions).get()).single;
      expect(session.id, sessionId);
      expect(session.planId, isNull);
      expect(await db.select(db.strengthSets).get(), hasLength(1));
    });

    test('deleting a day removes its blocks and items', () async {
      final planId = await repo.createPlan(
        name: 'Test',
        mode: PlanMode.staticPlan,
      );
      final dayId = await repo.addDay(
        planId: planId,
        label: 'Day 1',
        orderIndex: 0,
      );
      final blockId = await repo.addBlock(planDayId: dayId, orderIndex: 0);
      await repo.addStrengthItem(
        planBlockId: blockId,
        exerciseId: benchId,
        orderIndex: 0,
      );

      await repo.deleteDay(dayId);

      expect(await db.select(db.planBlocks).get(), isEmpty);
      expect(await db.select(db.planItems).get(), isEmpty);
    });
  });

  group('listing', () {
    test('puts the active plan first', () async {
      await repo.createPlan(name: 'A', mode: PlanMode.staticPlan);
      clock.advance(const Duration(minutes: 1));
      final second = await repo.createPlan(
        name: 'B',
        mode: PlanMode.staticPlan,
      );

      await repo.setActivePlan(second);

      final plans = await repo.getAll();
      expect(plans.first.id, second);
    });
  });
}
