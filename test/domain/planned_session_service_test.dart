import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/baseline_repository.dart';
import 'package:exercise_app/data/repositories/exercise_repository.dart';
import 'package:exercise_app/data/repositories/plan_repository.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/planning/planned_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late PlanRepository plans;
  late SessionRepository sessions;
  late BaselineRepository baselines;
  late PlannedSessionService service;
  late int benchId;
  late int rowId;
  late int treadmillId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    plans = PlanRepository(db, clock: clock);
    sessions = SessionRepository(db, clock: clock);
    baselines = BaselineRepository(db);
    service = PlannedSessionService(
      plans: plans,
      sessions: sessions,
      baselines: baselines,
      exercises: ExerciseRepository(db, clock: clock),
      clock: clock,
    );

    benchId = await insertExercise(db);
    rowId = await insertExercise(db, name: 'Barbell Row');
    treadmillId = await insertExercise(
      db,
      name: 'Treadmill Run',
      type: ExerciseType.cardio,
      cardioActivity: CardioActivity.run,
    );
  });

  Future<PlanRow> plan({
    PlanMode mode = PlanMode.staticPlan,
    ScheduleType scheduleType = ScheduleType.sequential,
  }) async {
    final id = await insertPlan(db, mode: mode, scheduleType: scheduleType);
    return (await plans.findById(id))!;
  }

  group('choosing the next workout', () {
    test('a plan with no workouts has nothing to start', () async {
      expect(await service.nextDay(await plan()), isNull);
    });

    test('starts at the first workout when nothing has been done', () async {
      final p = await plan();
      await insertPlanDay(db, planId: p.id, label: 'Push', orderIndex: 0);
      await insertPlanDay(db, planId: p.id, label: 'Pull', orderIndex: 1);

      expect((await service.nextDay(p))!.label, 'Push');
    });

    test('moves on to the workout after the last completed one', () async {
      final p = await plan();
      final push = await insertPlanDay(db, planId: p.id, label: 'Push');
      await insertPlanDay(db, planId: p.id, label: 'Pull', orderIndex: 1);

      await insertSession(db, planId: p.id, planDayId: push);

      expect((await service.nextDay(p))!.label, 'Pull');
    });

    test('wraps back to the start after the last workout', () async {
      // A plan that has been worked all the way through should start again, not
      // stop offering anything.
      final p = await plan();
      await insertPlanDay(db, planId: p.id, label: 'Push');
      final pull = await insertPlanDay(
        db,
        planId: p.id,
        label: 'Pull',
        orderIndex: 1,
      );

      await insertSession(db, planId: p.id, planDayId: pull);

      expect((await service.nextDay(p))!.label, 'Push');
    });

    test('ignores a workout that is still in progress', () async {
      final p = await plan();
      final push = await insertPlanDay(db, planId: p.id, label: 'Push');
      await insertPlanDay(db, planId: p.id, label: 'Pull', orderIndex: 1);

      await insertSession(
        db,
        planId: p.id,
        planDayId: push,
        status: SessionStatus.inProgress,
      );

      // Push has been started but not finished, so it is still what is due.
      expect((await service.nextDay(p))!.label, 'Push');
    });

    test('ignores ad-hoc sessions logged against the plan', () async {
      final p = await plan();
      await insertPlanDay(db, planId: p.id, label: 'Push');
      await insertPlanDay(db, planId: p.id, label: 'Pull', orderIndex: 1);

      await insertSession(db, planId: p.id);

      expect((await service.nextDay(p))!.label, 'Push');
    });

    test('a weekly plan picks the workout pinned to today', () async {
      // 2026-01-07 is a Wednesday.
      clock.setTo(DateTime.utc(2026, 1, 7, 9));
      final p = await plan(scheduleType: ScheduleType.weekly);

      await insertPlanDay(
        db,
        planId: p.id,
        label: 'Monday',
        orderIndex: 0,
        dayOfWeek: Weekday.monday,
      );
      await insertPlanDay(
        db,
        planId: p.id,
        label: 'Wednesday',
        orderIndex: 1,
        dayOfWeek: Weekday.wednesday,
      );

      expect((await service.nextDay(p))!.label, 'Wednesday');
    });

    test('a weekly plan rotates when nothing is pinned to today', () async {
      // Sunday, which neither workout claims.
      clock.setTo(DateTime.utc(2026, 1, 11, 9));
      final p = await plan(scheduleType: ScheduleType.weekly);

      final monday = await insertPlanDay(
        db,
        planId: p.id,
        label: 'Monday',
        orderIndex: 0,
        dayOfWeek: Weekday.monday,
      );
      await insertPlanDay(
        db,
        planId: p.id,
        label: 'Wednesday',
        orderIndex: 1,
        dayOfWeek: Weekday.wednesday,
      );

      await insertSession(db, planId: p.id, planDayId: monday);

      expect((await service.nextDay(p))!.label, 'Wednesday');
    });
  });

  group('starting the workout', () {
    test('links the session to the plan and names it after the day', () async {
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id, label: 'Push');
      final day = (await plans.getDays(p.id)).single;

      final sessionId = await service.start(plan: p, day: day);

      final session = (await sessions.findById(sessionId))!;
      expect(session.planId, p.id);
      expect(session.planDayId, dayId);
      expect(session.title, 'Push');
      expect(session.status, SessionStatus.inProgress);
    });

    test('writes one pending set per round', () async {
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id);
      final blockId = await insertPlanBlock(db, planDayId: dayId, rounds: 3);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 5,
        targetWeightKg: 80,
        weightMode: WeightMode.absolute,
      );

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      final sets = await sessions.getStrengthSets(sessionId);
      expect(sets, hasLength(3));
      expect(sets.map((s) => s.roundIndex), [0, 1, 2]);
      expect(sets.every((s) => s.status == EntryStatus.pending), isTrue);
      expect(sets.every((s) => s.plannedReps == 5), isTrue);
      expect(sets.every((s) => s.plannedWeightKg == 80), isTrue);
      expect(sets.every((s) => s.exerciseId == benchId), isTrue);
    });

    test('keeps a superset in one group, ordered by item', () async {
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id);
      final blockId = await insertPlanBlock(
        db,
        planDayId: dayId,
        kind: BlockKind.superset,
        rounds: 2,
        label: 'A1/A2',
      );
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        orderIndex: 0,
      );
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: rowId,
        orderIndex: 1,
      );

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      final sets = await sessions.getStrengthSets(sessionId);
      expect(sets, hasLength(4));
      expect(sets.map((s) => s.groupIndex).toSet(), {0});
      expect(sets.every((s) => s.groupKind == BlockKind.superset), isTrue);
      expect(sets.every((s) => s.groupLabel == 'A1/A2'), isTrue);

      for (final round in [0, 1]) {
        final inRound = sets.where((s) => s.roundIndex == round).toList()
          ..sort((a, b) => a.itemIndex.compareTo(b.itemIndex));
        expect(inRound.map((s) => s.exerciseId), [benchId, rowId]);
      }
    });

    test('gives each block its own group', () async {
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id);

      for (final (order, exerciseId) in [(0, benchId), (1, rowId)]) {
        final blockId = await insertPlanBlock(
          db,
          planDayId: dayId,
          orderIndex: order,
          rounds: 1,
        );
        await insertPlanItem(db, planBlockId: blockId, exerciseId: exerciseId);
      }

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      final sets = await sessions.getStrengthSets(sessionId);
      expect(sets, hasLength(2));
      expect(
        {for (final s in sets) s.exerciseId: s.groupIndex},
        {benchId: 0, rowId: 1},
      );
    });

    test('writes a cardio item as a cardio entry, not a set', () async {
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id);
      final blockId = await insertPlanBlock(db, planDayId: dayId, rounds: 1);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: treadmillId,
        targetReps: null,
        targetWeightKg: null,
        targetDurationSeconds: 1800,
        targetDistanceMeters: 5000,
        targetPaceSecPerKm: 360,
      );

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      expect(await sessions.getStrengthSets(sessionId), isEmpty);

      final entry = (await sessions.getCardioEntries(sessionId)).single;
      expect(entry.exerciseId, treadmillId);
      expect(entry.status, EntryStatus.pending);
      expect(entry.plannedDurationSeconds, 1800);
      expect(entry.plannedDistanceMeters, 5000);
      expect(entry.plannedPaceSecPerKm, 360);
    });

    test('prescribes from the baseline when the plan tracks one', () async {
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id);
      final blockId = await insertPlanBlock(db, planDayId: dayId, rounds: 1);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 5,
        targetWeightKg: 60,
        weightMode: WeightMode.baseline,
      );

      // The lifter has moved past what the plan was written with.
      await baselines.set(
        planId: p.id,
        exerciseId: benchId,
        reps: 5,
        weightKg: 75,
        achievedAt: clock.now(),
      );

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      expect(
        (await sessions.getStrengthSets(sessionId)).single.plannedWeightKg,
        75,
      );
    });

    test('a periodized plan ignores baselines entirely', () async {
      // Its numbers are fixed for the life of the program, so a baseline left
      // over from elsewhere must not move them.
      final p = await plan(mode: PlanMode.periodized);
      final dayId = await insertPlanDay(db, planId: p.id);
      final blockId = await insertPlanBlock(db, planDayId: dayId, rounds: 1);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 5,
        targetWeightKg: 60,
        weightMode: WeightMode.baseline,
      );

      await baselines.set(
        planId: p.id,
        exerciseId: benchId,
        reps: 5,
        weightKg: 75,
        achievedAt: clock.now(),
      );

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      expect(
        (await sessions.getStrengthSets(sessionId)).single.plannedWeightKg,
        60,
      );
    });

    test('points every entry back at the plan item it came from', () async {
      // The link is what lets a finished session be compared against what was
      // asked for.
      final p = await plan();
      final dayId = await insertPlanDay(db, planId: p.id);
      final blockId = await insertPlanBlock(db, planDayId: dayId, rounds: 2);
      final itemId = await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
      );

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      final sets = await sessions.getStrengthSets(sessionId);
      expect(sets.every((s) => s.planItemId == itemId), isTrue);
    });

    test('an empty workout still opens a session', () async {
      // A day with no blocks is a legitimate stub; starting it should give an
      // empty session to add to, not fail.
      final p = await plan();
      await insertPlanDay(db, planId: p.id, label: 'Empty');

      final sessionId = await service.start(
        plan: p,
        day: (await plans.getDays(p.id)).single,
      );

      expect(await sessions.findById(sessionId), isNotNull);
      expect(await sessions.getStrengthSets(sessionId), isEmpty);
    });
  });
}
