import 'dart:convert';

import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/baseline_repository.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/data/repositories/settings_repository.dart';
import 'package:exercise_app/domain/backup/backup_service.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late BackupService backup;

  setUp(() {
    db = createTestDatabase();
    clock = FakeClock();
    backup = BackupService(db, clock: clock);
  });

  /// Populates a database with one of everything worth round-tripping.
  Future<void> seedRealisticData(AppDatabase target) async {
    final sessions = SessionRepository(target, clock: clock);
    final baselines = BaselineRepository(target);

    final benchId = await insertExercise(target);
    final runId = await insertExercise(
      target,
      name: 'Outdoor Run',
      type: ExerciseType.cardio,
      cardioActivity: CardioActivity.run,
    );

    final planId = await insertPlan(target, mode: PlanMode.staticPlan);
    final dayId = await insertPlanDay(target, planId: planId);
    final blockId = await insertPlanBlock(
      target,
      planDayId: dayId,
      kind: BlockKind.superset,
    );
    await insertPlanItem(
      target,
      planBlockId: blockId,
      exerciseId: benchId,
      targetReps: 8,
      targetWeightKg: 60,
    );

    await baselines.set(
      planId: planId,
      exerciseId: benchId,
      reps: 8,
      weightKg: 65,
      achievedAt: clock.now(),
    );

    final sessionId = await sessions.startSession(planId: planId);
    await sessions.addStrengthSet(
      sessionId: sessionId,
      exerciseId: benchId,
      groupIndex: 0,
      groupKind: BlockKind.superset,
      groupLabel: 'A',
      roundIndex: 0,
      plannedReps: 8,
      plannedWeightKg: 60,
      actualReps: 8,
      actualWeightKg: 65,
    );
    final entryId = await sessions.addCardioEntry(
      sessionId: sessionId,
      exerciseId: runId,
      groupIndex: 1,
    );
    await sessions.completeCardioEntry(
      entryId,
      durationSeconds: 1500,
      distanceMeters: 5000,
      avgHeartRate: 150,
    );
    await sessions.replaceSplits(entryId, [
      (durationSeconds: 300, distanceMeters: 1000.0),
      (durationSeconds: 290, distanceMeters: 1000.0),
    ]);
    await sessions.completeSession(sessionId);

    await SettingsRepository(target).setUnitSystem(UnitSystem.imperial);
  }

  group('export', () {
    test('produces valid JSON with a version stamp', () async {
      final json =
          jsonDecode(await backup.exportToJson()) as Map<String, Object?>;

      expect(json['backupVersion'], kBackupVersion);
      expect(json['exportedAt'], isNotNull);
      expect(json['exercises'], isA<List<Object?>>());
    });

    test('includes every table', () async {
      await seedRealisticData(db);
      final json =
          jsonDecode(await backup.exportToJson()) as Map<String, Object?>;

      for (final key in const [
        'exercises',
        'plans',
        'planDays',
        'planBlocks',
        'planItems',
        'sessions',
        'strengthSets',
        'cardioEntries',
        'cardioSplits',
        'exerciseBaselines',
        'personalRecords',
        'settings',
      ]) {
        expect(json.containsKey(key), isTrue, reason: 'missing $key');
      }
    });

    test('writes enums as their stable wire names', () async {
      // Renaming a Dart constant must never invalidate an existing backup.
      await seedRealisticData(db);
      final json =
          jsonDecode(await backup.exportToJson()) as Map<String, Object?>;

      final plan =
          (json['plans']! as List<Object?>).first! as Map<String, Object?>;
      expect(plan['mode'], 'static');

      final block =
          (json['planBlocks']! as List<Object?>).first! as Map<String, Object?>;
      expect(block['kind'], 'superset');
    });
  });

  group('restore round-trip', () {
    test('brings back every row into a fresh database', () async {
      await seedRealisticData(db);
      final exported = await backup.exportToJson();

      // Simulate a wiped device.
      final fresh = createTestDatabase();
      final summary = await BackupService(
        fresh,
        clock: clock,
      ).restoreFromJson(exported);

      expect(summary.exercises, 2);
      expect(summary.plans, 1);
      expect(summary.sessions, 1);
      expect(summary.strengthSets, 1);
      expect(summary.cardioEntries, 1);

      expect(await fresh.select(fresh.exercises).get(), hasLength(2));
      expect(await fresh.select(fresh.planItems).get(), hasLength(1));
      expect(await fresh.select(fresh.cardioSplits).get(), hasLength(2));
      expect(await fresh.select(fresh.exerciseBaselines).get(), hasLength(1));
    });

    test('preserves identifiers so foreign keys still resolve', () async {
      await seedRealisticData(db);
      final exported = await backup.exportToJson();

      final fresh = createTestDatabase();
      await BackupService(fresh, clock: clock).restoreFromJson(exported);

      final set = (await fresh.select(fresh.strengthSets).get()).single;
      final exercise = await (fresh.select(
        fresh.exercises,
      )..where((t) => t.id.equals(set.exerciseId))).getSingleOrNull();

      expect(exercise, isNotNull);
      expect(exercise!.name, 'Barbell Bench Press');
    });

    test('preserves values, enums and timestamps exactly', () async {
      await seedRealisticData(db);
      final exported = await backup.exportToJson();

      final fresh = createTestDatabase();
      await BackupService(fresh, clock: clock).restoreFromJson(exported);

      final set = (await fresh.select(fresh.strengthSets).get()).single;
      expect(set.actualWeightKg, 65);
      expect(set.plannedWeightKg, 60);
      expect(set.groupKind, BlockKind.superset);
      expect(set.groupLabel, 'A');
      expect(set.status, EntryStatus.completed);

      final cardio = (await fresh.select(fresh.cardioEntries).get()).single;
      expect(cardio.actualDistanceMeters, 5000);
      expect(cardio.avgHeartRate, 150);
      expect(cardio.actualPaceSecPerKm, closeTo(300, 1e-9));

      final original = (await db.select(db.sessions).get()).single;
      final restored = (await fresh.select(fresh.sessions).get()).single;
      expect(restored.startedAt.isAtSameMomentAs(original.startedAt), isTrue);
    });

    test('restores settings', () async {
      await seedRealisticData(db);
      final exported = await backup.exportToJson();

      final fresh = createTestDatabase();
      await BackupService(fresh, clock: clock).restoreFromJson(exported);

      expect(
        await SettingsRepository(fresh).getUnitSystem(),
        UnitSystem.imperial,
      );
    });

    test('replaces existing data rather than merging', () async {
      await seedRealisticData(db);
      final exported = await backup.exportToJson();

      final other = createTestDatabase();
      await insertExercise(other, name: 'Something Else');
      await BackupService(other, clock: clock).restoreFromJson(exported);

      // Restore means "make this device look like the backup".
      final names = (await other.select(other.exercises).get())
          .map((e) => e.name)
          .toList();
      expect(names, isNot(contains('Something Else')));
      expect(names, contains('Barbell Bench Press'));
    });

    test('an empty backup restores to an empty database', () async {
      final exported = await backup.exportToJson();

      final other = createTestDatabase();
      await insertExercise(other, name: 'Will Be Removed');
      await BackupService(other, clock: clock).restoreFromJson(exported);

      expect(await other.select(other.exercises).get(), isEmpty);
    });

    test('a second restore of the same file is idempotent', () async {
      await seedRealisticData(db);
      final exported = await backup.exportToJson();

      final fresh = createTestDatabase();
      final service = BackupService(fresh, clock: clock);
      await service.restoreFromJson(exported);
      await service.restoreFromJson(exported);

      expect(await fresh.select(fresh.exercises).get(), hasLength(2));
      expect(await fresh.select(fresh.strengthSets).get(), hasLength(1));
    });
  });

  group('rejecting bad files', () {
    test('rejects invalid JSON', () async {
      await expectLater(
        backup.restoreFromJson('{not json'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects a non-object document', () async {
      await expectLater(
        backup.restoreFromJson('[]'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects an unknown backup version', () async {
      await expectLater(
        backup.restoreFromJson('{"backupVersion":"99.0"}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('leaves existing data untouched when the file is rejected', () async {
      await seedRealisticData(db);

      await expectLater(
        backup.restoreFromJson('{"backupVersion":"99.0"}'),
        throwsA(isA<BackupFormatException>()),
      );

      // A rejected restore must not have deleted anything first.
      expect(await db.select(db.exercises).get(), hasLength(2));
      expect(await db.select(db.strengthSets).get(), hasLength(1));
    });
  });
}
