import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/baseline_repository.dart';
import 'package:exercise_app/data/repositories/personal_record_repository.dart';
import 'package:exercise_app/data/repositories/plan_repository.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/progression/progression_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SessionRepository sessions;
  late PlanRepository plans;
  late BaselineRepository baselines;
  late PersonalRecordRepository records;
  late ProgressionService service;
  late int benchId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    sessions = SessionRepository(db, clock: clock);
    plans = PlanRepository(db, clock: clock);
    baselines = BaselineRepository(db);
    records = PersonalRecordRepository(db);
    service = ProgressionService(
      sessions: sessions,
      plans: plans,
      baselines: baselines,
      records: records,
      clock: clock,
    );
    benchId = await insertExercise(db);
  });

  /// Logs one completed set inside a session belonging to [planId].
  Future<int> logSet({
    required int planId,
    required int plannedReps,
    required double plannedWeightKg,
    required int actualReps,
    required double actualWeightKg,
    bool isWarmup = false,
    EntryStatus status = EntryStatus.completed,
  }) async {
    final sessionId = await sessions.startSession(planId: planId);
    await sessions.addStrengthSet(
      sessionId: sessionId,
      exerciseId: benchId,
      groupIndex: 0,
      roundIndex: 0,
      plannedReps: plannedReps,
      plannedWeightKg: plannedWeightKg,
      actualReps: actualReps,
      actualWeightKg: actualWeightKg,
      isWarmup: isWarmup,
      status: status,
    );
    return sessionId;
  }

  Future<double?> baselineFor(int planId, int reps) async {
    final row = await baselines.find(
      planId: planId,
      exerciseId: benchId,
      reps: reps,
    );
    return row?.weightKg;
  }

  group('static plan — the baseline follows the user upward', () {
    late int planId;

    setUp(() async {
      planId = await insertPlan(db, mode: PlanMode.staticPlan);
      await baselines.set(
        planId: planId,
        exerciseId: benchId,
        reps: 8,
        weightKg: 60,
        achievedAt: clock.now(),
      );
    });

    test(
      'beating the weight at the prescribed reps raises the baseline',
      () async {
        final sessionId = await logSet(
          planId: planId,
          plannedReps: 8,
          plannedWeightKg: 60,
          actualReps: 8,
          actualWeightKg: 65,
        );

        final outcome = await service.applyForSession(sessionId);

        expect(await baselineFor(planId, 8), 65);
        expect(outcome.promotions, hasLength(1));
        expect(outcome.promotions.single.previousWeightKg, 60);
        expect(outcome.promotions.single.newWeightKg, 65);
        expect(outcome.promotions.single.reps, 8);
      },
    );

    test('exceeding the prescribed reps also promotes', () async {
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 10,
        actualWeightKg: 65,
      );

      await service.applyForSession(sessionId);
      expect(await baselineFor(planId, 8), 65);
    });

    test('a set cut short never promotes, however heavy', () async {
      // This is the rule that keeps the plan honest: 5 reps at 80kg does not
      // mean you can do 8 reps at 80kg.
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 5,
        actualWeightKg: 80,
      );

      final outcome = await service.applyForSession(sessionId);

      expect(await baselineFor(planId, 8), 60);
      expect(outcome.promotions, isEmpty);
    });

    test('matching the baseline does not promote', () async {
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 60,
      );

      final outcome = await service.applyForSession(sessionId);
      expect(outcome.promotions, isEmpty);
      expect(await baselineFor(planId, 8), 60);
    });

    test('lifting less than the baseline does not lower it', () async {
      // A bad day must not undo progress.
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 50,
      );

      await service.applyForSession(sessionId);
      expect(await baselineFor(planId, 8), 60);
    });

    test('warm-ups are ignored', () async {
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 100,
        isWarmup: true,
      );

      final outcome = await service.applyForSession(sessionId);
      expect(outcome.promotions, isEmpty);
      expect(await baselineFor(planId, 8), 60);
    });

    test('skipped sets are ignored', () async {
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 90,
        status: EntryStatus.skipped,
      );

      final outcome = await service.applyForSession(sessionId);
      expect(outcome.promotions, isEmpty);
      expect(await baselineFor(planId, 8), 60);
    });

    test('baselines at different rep counts are independent', () async {
      // Keying on reps is what makes "heaviest at the prescribed reps" a
      // well-defined rule.
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 5,
        plannedWeightKg: 70,
        actualReps: 5,
        actualWeightKg: 75,
      );

      await service.applyForSession(sessionId);

      expect(await baselineFor(planId, 5), 75);
      expect(await baselineFor(planId, 8), 60);
    });

    test('the heaviest qualifying set in a session wins', () async {
      final sessionId = await sessions.startSession(planId: planId);
      for (final weight in [62.5, 67.5, 65.0]) {
        await sessions.addStrengthSet(
          sessionId: sessionId,
          exerciseId: benchId,
          groupIndex: 0,
          roundIndex: [62.5, 67.5, 65.0].indexOf(weight),
          plannedReps: 8,
          plannedWeightKg: 60,
          actualReps: 8,
          actualWeightKg: weight,
        );
      }

      await service.applyForSession(sessionId);
      expect(await baselineFor(planId, 8), 67.5);
    });

    test('baselines are scoped per plan', () async {
      final otherPlan = await insertPlan(
        db,
        name: 'Other',
        mode: PlanMode.staticPlan,
      );

      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 70,
      );
      await service.applyForSession(sessionId);

      expect(await baselineFor(planId, 8), 70);
      // Two static plans must not fight over one number.
      expect(await baselineFor(otherPlan, 8), isNull);
    });

    test('progress compounds across sessions', () async {
      for (final weight in [65.0, 70.0, 72.5]) {
        final sessionId = await logSet(
          planId: planId,
          plannedReps: 8,
          plannedWeightKg: 60,
          actualReps: 8,
          actualWeightKg: weight,
        );
        await service.applyForSession(sessionId);
        clock.advance(const Duration(days: 3));
      }

      expect(await baselineFor(planId, 8), 72.5);
    });
  });

  group('periodized plan — the prescription never moves', () {
    late int planId;
    late int itemId;

    setUp(() async {
      planId = await insertPlan(
        db,
        mode: PlanMode.periodized,
        durationWeeks: 8,
      );
      final dayId = await insertPlanDay(db, planId: planId);
      final blockId = await insertPlanBlock(db, planDayId: dayId);
      itemId = await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 8,
        targetWeightKg: 60,
      );
    });

    test('beating the prescription changes nothing about the plan', () async {
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 10,
        actualWeightKg: 80,
      );

      final outcome = await service.applyForSession(sessionId);

      // The defining behaviour: no promotion, and no baseline written at all.
      expect(outcome.promotions, isEmpty);
      expect(await baselines.forPlan(planId), isEmpty);
    });

    test('the prescribed weight and reps are untouched', () async {
      final before = await (db.select(
        db.planItems,
      )..where((t) => t.id.equals(itemId))).getSingle();

      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 12,
        actualWeightKg: 95,
      );
      await service.applyForSession(sessionId);

      final after = await (db.select(
        db.planItems,
      )..where((t) => t.id.equals(itemId))).getSingle();

      expect(after.targetWeightKg, before.targetWeightKg);
      expect(after.targetReps, before.targetReps);
    });

    test('a personal record is still recorded', () async {
      // The result is celebrated; it just does not alter the program.
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 80,
      );

      final outcome = await service.applyForSession(sessionId);
      expect(outcome.records, isNotEmpty);

      final pr = await records.find(
        exerciseId: benchId,
        recordType: RecordType.maxWeightAtReps,
        reps: 8,
      );
      expect(pr!.value, 80);
    });

    test('repeated over-performance still never moves the plan', () async {
      for (final weight in [70.0, 80.0, 90.0]) {
        final sessionId = await logSet(
          planId: planId,
          plannedReps: 8,
          plannedWeightKg: 60,
          actualReps: 8,
          actualWeightKg: weight,
        );
        await service.applyForSession(sessionId);
        clock.advance(const Duration(days: 3));
      }

      expect(await baselines.forPlan(planId), isEmpty);
      final item = await (db.select(
        db.planItems,
      )..where((t) => t.id.equals(itemId))).getSingle();
      expect(item.targetWeightKg, 60);
    });
  });

  group('personal records', () {
    late int planId;

    setUp(() async {
      planId = await insertPlan(db, mode: PlanMode.staticPlan);
    });

    test('records max weight at reps, max weight and estimated 1RM', () async {
      final sessionId = await logSet(
        planId: planId,
        plannedReps: 5,
        plannedWeightKg: 70,
        actualReps: 5,
        actualWeightKg: 100,
      );
      await service.applyForSession(sessionId);

      expect(
        (await records.find(
          exerciseId: benchId,
          recordType: RecordType.maxWeightAtReps,
          reps: 5,
        ))!.value,
        100,
      );
      expect(
        (await records.find(
          exerciseId: benchId,
          recordType: RecordType.maxWeight,
        ))!.value,
        100,
      );
      // Epley: 100 * (1 + 5/30)
      expect(
        (await records.find(
          exerciseId: benchId,
          recordType: RecordType.estimatedOneRepMax,
        ))!.value,
        closeTo(116.6667, 0.001),
      );
    });

    test('a worse result does not overwrite a record', () async {
      final first = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 100,
      );
      await service.applyForSession(first);

      final second = await logSet(
        planId: planId,
        plannedReps: 8,
        plannedWeightKg: 60,
        actualReps: 8,
        actualWeightKg: 80,
      );
      final outcome = await service.applyForSession(second);

      expect(outcome.records, isEmpty);
      expect(
        (await records.find(
          exerciseId: benchId,
          recordType: RecordType.maxWeight,
        ))!.value,
        100,
      );
    });

    test('cardio records track distance, duration and pace', () async {
      final runId = await insertExercise(
        db,
        name: 'Outdoor Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );
      final sessionId = await sessions.startSession(planId: planId);
      final entryId = await sessions.addCardioEntry(
        sessionId: sessionId,
        exerciseId: runId,
        groupIndex: 0,
      );
      await sessions.completeCardioEntry(
        entryId,
        durationSeconds: 1500,
        distanceMeters: 5000,
      );

      await service.applyForSession(sessionId);

      expect(
        (await records.find(
          exerciseId: runId,
          recordType: RecordType.longestDistance,
        ))!.value,
        5000,
      );
      expect(
        (await records.find(
          exerciseId: runId,
          recordType: RecordType.longestDuration,
        ))!.value,
        1500,
      );
      expect(
        (await records.find(
          exerciseId: runId,
          recordType: RecordType.bestPace,
        ))!.value,
        closeTo(300, 1e-9),
      );
    });

    test('a faster pace wins even though the number is lower', () async {
      final runId = await insertExercise(
        db,
        name: 'Outdoor Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );

      Future<void> run(int seconds) async {
        final sessionId = await sessions.startSession();
        final entryId = await sessions.addCardioEntry(
          sessionId: sessionId,
          exerciseId: runId,
          groupIndex: 0,
        );
        await sessions.completeCardioEntry(
          entryId,
          durationSeconds: seconds,
          distanceMeters: 5000,
        );
        await service.applyForSession(sessionId);
      }

      await run(1500); // 5:00/km
      await run(1400); // 4:40/km — faster
      await run(1600); // slower, must not overwrite

      expect(
        (await records.find(
          exerciseId: runId,
          recordType: RecordType.bestPace,
        ))!.value,
        closeTo(280, 1e-9),
      );
    });
  });

  group('ad-hoc sessions', () {
    test('promote nothing but still record personal records', () async {
      final sessionId = await sessions.startSession();
      await sessions.addStrengthSet(
        sessionId: sessionId,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 8,
        actualWeightKg: 75,
      );

      final outcome = await service.applyForSession(sessionId);

      expect(outcome.promotions, isEmpty);
      expect(outcome.records, isNotEmpty);
    });

    test('a missing session is handled without throwing', () async {
      final outcome = await service.applyForSession(9999);
      expect(outcome.hasChanges, isFalse);
    });
  });

  group('seedBaselines', () {
    test('establishes starting weights for a static plan', () async {
      final planId = await insertPlan(db, mode: PlanMode.staticPlan);
      final dayId = await insertPlanDay(db, planId: planId);
      final blockId = await insertPlanBlock(db, planDayId: dayId);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 8,
        targetWeightKg: 60,
      );

      await service.seedBaselines(planId);
      expect(await baselineFor(planId, 8), 60);
    });

    test('never overwrites progress already made', () async {
      final planId = await insertPlan(db, mode: PlanMode.staticPlan);
      final dayId = await insertPlanDay(db, planId: planId);
      final blockId = await insertPlanBlock(db, planDayId: dayId);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 8,
        targetWeightKg: 60,
      );

      await baselines.set(
        planId: planId,
        exerciseId: benchId,
        reps: 8,
        weightKg: 85,
        achievedAt: clock.now(),
      );

      // Re-importing a plan must not undo months of progress.
      await service.seedBaselines(planId);
      expect(await baselineFor(planId, 8), 85);
    });

    test('does nothing for a periodized plan', () async {
      final planId = await insertPlan(db, mode: PlanMode.periodized);
      final dayId = await insertPlanDay(db, planId: planId);
      final blockId = await insertPlanBlock(db, planDayId: dayId);
      await insertPlanItem(
        db,
        planBlockId: blockId,
        exerciseId: benchId,
        targetReps: 8,
        targetWeightKg: 60,
      );

      await service.seedBaselines(planId);
      expect(await baselines.forPlan(planId), isEmpty);
    });
  });
}
