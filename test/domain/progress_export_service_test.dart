import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/settings_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/progress_export/progress_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

/// The export is read by a language model, not by this app, so the assertions
/// here are about the *document*: what it includes, what it leaves out, and
/// whether its numbers say what they claim to.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late ProgressExportService service;
  late int benchId;

  /// Sits comfortably inside the 90-day window from the fake clock's now.
  final recently = DateTime.utc(2025, 12, 1, 18);
  final longAgo = DateTime.utc(2025, 6, 1, 18);

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    service = ProgressExportService(
      db: db,
      settings: SettingsRepository(db),
      clock: clock,
    );
    benchId = await insertExercise(db);
  });

  tearDown(() => db.close());

  Future<Map<String, Object?>> exported() async {
    final export = await service.export();
    return jsonDecode(export.json) as Map<String, Object?>;
  }

  /// A completed session on [on] holding one set at [weight] × [reps].
  Future<int> loggedSession({
    required DateTime on,
    double weight = 60,
    int reps = 8,
    int? exerciseId,
    bool isWarmup = false,
  }) async {
    final sessionId = await insertSession(db, startedAt: on);
    await insertStrengthSet(
      db,
      sessionId: sessionId,
      exerciseId: exerciseId ?? benchId,
      actualReps: reps,
      actualWeightKg: weight,
      isWarmup: isWarmup,
      performedAt: on,
    );
    return sessionId;
  }

  group('the window', () {
    test('is empty before anything is logged', () async {
      final export = await service.export();

      expect(export.isEmpty, isTrue);
      expect(export.sessionCount, 0);
      expect(export.exerciseCount, 0);
      // Still a valid, self-describing document rather than an error.
      final json = jsonDecode(export.json) as Map<String, Object?>;
      expect(json['progressExportVersion'], kProgressExportVersion);
      expect(json['sessions'], isEmpty);
    });

    test('covers the last 3 months', () async {
      final export = await service.export();

      expect(export.to, clock.now());
      expect(export.to.difference(export.from).inDays, kProgressExportDays);
    });

    test('leaves out sessions older than the window', () async {
      await loggedSession(on: longAgo);
      await loggedSession(on: recently);

      final export = await service.export();

      expect(export.sessionCount, 1);
      expect((await exported())['sessions'], hasLength(1));
    });

    test('leaves out sessions that were never finished', () async {
      await insertSession(
        db,
        startedAt: recently,
        status: SessionStatus.inProgress,
      );

      expect((await service.export()).sessionCount, 0);
    });

    test('leaves out entries that were skipped', () async {
      final sessionId = await insertSession(db, startedAt: recently);
      await insertStrengthSet(
        db,
        sessionId: sessionId,
        exerciseId: benchId,
        status: EntryStatus.skipped,
        performedAt: recently,
      );

      final json = await exported();

      expect(json['strengthExercises'], isEmpty);
      expect((json['summary']! as Map)['strengthSets'], 0);
    });
  });

  group('summary', () {
    test('counts sessions, sets and volume', () async {
      await loggedSession(on: recently, weight: 60, reps: 10);
      await loggedSession(
        on: recently.add(const Duration(days: 3)),
        weight: 65,
        reps: 8,
      );

      final summary = (await exported())['summary']! as Map<String, Object?>;

      expect(summary['sessions'], 2);
      expect(summary['strengthSets'], 2);
      expect(summary['trainingDays'], 2);
      expect(summary['totalVolumeKg'], 60 * 10 + 65 * 8);
    });

    /// Frequency is measured from the first session, not from the start of the
    /// window: three weeks of training must not read as one workout a month
    /// just because the window is longer than the training history.
    test('measures frequency from the first session', () async {
      final start = clock.now().subtract(const Duration(days: 14));
      for (var i = 0; i < 6; i++) {
        await loggedSession(on: start.add(Duration(days: i * 2)));
      }

      final summary = (await exported())['summary']! as Map<String, Object?>;

      expect(summary['sessionsPerWeek'], 3);
    });

    test('reports the unit system the user reads in', () async {
      await SettingsRepository(db).setUnitSystem(UnitSystem.imperial);

      expect((await exported())['preferredDisplayUnits'], 'imperial');
      // The numbers themselves never change — only how they are shown.
      expect(((await exported())['units']! as Map)['weight'], 'kg');
    });
  });

  group('strength exercises', () {
    test(
      'reports the heaviest set and the best estimated one-rep max',
      () async {
        await loggedSession(on: recently, weight: 60, reps: 10);
        await loggedSession(
          on: recently.add(const Duration(days: 7)),
          weight: 80,
          reps: 3,
        );

        final entry =
            ((await exported())['strengthExercises']! as List).single
                as Map<String, Object?>;

        expect(entry['name'], 'Barbell Bench Press');
        expect((entry['heaviestSet']! as Map)['weightKg'], 80);
        expect((entry['heaviestSet']! as Map)['reps'], 3);
        // Epley over both sets: 60 × (1 + 10/30) = 80, 80 × (1 + 3/30) = 88.
        expect(entry['bestEstimatedOneRepMaxKg'], 88);
      },
    );

    test('shows where the numbers started and where they are now', () async {
      await loggedSession(on: recently, weight: 60);
      await loggedSession(
        on: recently.add(const Duration(days: 7)),
        weight: 70,
      );
      await loggedSession(
        on: recently.add(const Duration(days: 14)),
        weight: 75,
      );

      final entry =
          ((await exported())['strengthExercises']! as List).single
              as Map<String, Object?>;

      expect(entry['topSetFirstDayKg'], 60);
      expect(entry['topSetLatestDayKg'], 75);
      expect(entry['days'], 3);
    });

    test('carries every set from the most recent day', () async {
      final latest = recently.add(const Duration(days: 7));
      await loggedSession(on: recently, weight: 60);
      final sessionId = await insertSession(db, startedAt: latest);
      for (final weight in [70.0, 72.5]) {
        await insertStrengthSet(
          db,
          sessionId: sessionId,
          exerciseId: benchId,
          actualWeightKg: weight,
          actualReps: 5,
          performedAt: latest,
        );
      }

      final entry =
          ((await exported())['strengthExercises']! as List).single
              as Map<String, Object?>;
      final latestSession = entry['latestSession']! as Map<String, Object?>;

      expect(latestSession['date'], '2025-12-08');
      expect(latestSession['sets'], [
        {'reps': 5, 'weightKg': 70},
        {'reps': 5, 'weightKg': 72.5},
      ]);
    });

    /// Warm-ups belong in the log — they are part of what the user did — but
    /// counting them would report a lighter training history than the truth.
    test('keeps warm-ups out of the aggregates but in the log', () async {
      final sessionId = await insertSession(db, startedAt: recently);
      await insertStrengthSet(
        db,
        sessionId: sessionId,
        exerciseId: benchId,
        actualWeightKg: 20,
        actualReps: 10,
        isWarmup: true,
        performedAt: recently,
      );
      await insertStrengthSet(
        db,
        sessionId: sessionId,
        exerciseId: benchId,
        actualWeightKg: 60,
        actualReps: 8,
        performedAt: recently,
      );

      final json = await exported();
      final entry =
          (json['strengthExercises']! as List).single as Map<String, Object?>;

      expect(entry['sets'], 1);
      expect(entry['topSetFirstDayKg'], 60);
      expect((json['summary']! as Map)['warmupSets'], 1);

      final logged =
          ((((json['sessions']! as List).single
                          as Map<String, Object?>)['strength']!
                      as List)
                  .single
              as Map<String, Object?>)['sets']!;
      expect(logged, hasLength(2));
      expect((logged as List).first, containsPair('warmup', true));
    });

    test('lists the busiest exercise first', () async {
      final squatId = await insertExercise(db, name: 'Back Squat');
      final sessionId = await insertSession(db, startedAt: recently);
      await insertStrengthSet(
        db,
        sessionId: sessionId,
        exerciseId: benchId,
        performedAt: recently,
      );
      for (var i = 0; i < 3; i++) {
        await insertStrengthSet(
          db,
          sessionId: sessionId,
          exerciseId: squatId,
          roundIndex: i,
          performedAt: recently,
        );
      }

      final names = [
        for (final entry in (await exported())['strengthExercises']! as List)
          (entry as Map<String, Object?>)['name'],
      ];

      expect(names, ['Back Squat', 'Barbell Bench Press']);
    });
  });

  group('cardio exercises', () {
    late int runId;

    setUp(() async {
      runId = await insertExercise(
        db,
        name: 'Easy Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );
    });

    Future<void> loggedRun({
      required DateTime on,
      required double meters,
      required int seconds,
    }) async {
      final sessionId = await insertSession(db, startedAt: on);
      await db
          .into(db.cardioEntries)
          .insert(
            CardioEntriesCompanion.insert(
              sessionId: sessionId,
              exerciseId: runId,
              groupIndex: 0,
              groupKind: BlockKind.single,
              roundIndex: 0,
              itemIndex: 0,
              actualDurationSeconds: Value(seconds),
              actualDistanceMeters: Value(meters),
              actualPaceSecPerKm: Value(seconds / (meters / 1000)),
              status: EntryStatus.completed,
              performedAt: Value(on),
            ),
          );
    }

    test('totals distance and keeps the fastest pace', () async {
      await loggedRun(on: recently, meters: 5000, seconds: 1800);
      await loggedRun(
        on: recently.add(const Duration(days: 4)),
        meters: 8000,
        seconds: 2640,
      );

      final entry =
          ((await exported())['cardioExercises']! as List).single
              as Map<String, Object?>;

      expect(entry['activity'], 'run');
      expect(entry['efforts'], 2);
      expect(entry['totalDistanceMeters'], 13000);
      expect(entry['longestDistanceMeters'], 8000);
      // 330 s/km beats the first run's 360, and lower wins for pace.
      expect(entry['bestPaceSecPerKm'], 330);
      expect((entry['latestEffort']! as Map)['distanceMeters'], 8000);
    });
  });

  group('personal records', () {
    Future<void> record(DateTime achievedAt, double value) async {
      await db
          .into(db.personalRecords)
          .insert(
            PersonalRecordsCompanion.insert(
              exerciseId: benchId,
              recordType: RecordType.maxWeight,
              value: value,
              achievedAt: achievedAt,
            ),
          );
    }

    /// Records are all-time on purpose: a plan that prescribes below a number
    /// the user hit four months ago is a plan that goes backwards.
    test('include older records, marked as outside the window', () async {
      await loggedSession(on: recently);
      await record(longAgo, 100);

      final records = (await exported())['personalRecords']! as List;

      expect(records, hasLength(1));
      expect(records.single, containsPair('inWindow', false));
      expect(records.single, containsPair('value', 100));
    });

    test('are limited to exercises trained in the window', () async {
      final unusedId = await insertExercise(db, name: 'Leg Press');
      await loggedSession(on: recently);
      await db
          .into(db.personalRecords)
          .insert(
            PersonalRecordsCompanion.insert(
              exerciseId: unusedId,
              recordType: RecordType.maxWeight,
              value: 200,
              achievedAt: recently,
            ),
          );

      expect((await exported())['personalRecords'], isEmpty);
    });
  });

  test('names the active plan', () async {
    final planId = await insertPlan(db, name: 'Upper/Lower');
    await (db.update(db.plans)..where((t) => t.id.equals(planId))).write(
      const PlansCompanion(isActive: Value(true)),
    );
    await loggedSession(on: recently);

    final plan = (await exported())['activePlan']! as Map<String, Object?>;

    expect(plan['name'], 'Upper/Lower');
    expect(plan['mode'], 'static');
  });
}
