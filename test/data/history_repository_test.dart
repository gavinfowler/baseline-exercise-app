import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/history_repository.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SessionRepository sessions;
  late HistoryRepository history;
  late int benchId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    sessions = SessionRepository(db, clock: clock);
    history = HistoryRepository(db);
    benchId = await insertExercise(db);
  });

  /// One completed session containing a single set at [weight] × [reps].
  Future<int> loggedSession({
    required double weight,
    int reps = 8,
    bool isWarmup = false,
  }) async {
    final id = await sessions.startSession();
    await sessions.addStrengthSet(
      sessionId: id,
      exerciseId: benchId,
      groupIndex: 0,
      roundIndex: 0,
      actualReps: reps,
      actualWeightKg: weight,
      isWarmup: isWarmup,
    );
    await sessions.completeSession(id);
    return id;
  }

  group('recentSessions', () {
    test('is empty before anything is logged', () async {
      expect(await history.recentSessions(), isEmpty);
    });

    test('summarises volume, counts and exercise names', () async {
      final id = await sessions.startSession();
      await sessions.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 10,
        actualWeightKg: 60,
      );
      await sessions.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 1,
        actualReps: 8,
        actualWeightKg: 65,
      );
      await sessions.completeSession(id);

      final summary = (await history.recentSessions()).single;
      expect(summary.strengthSetCount, 2);
      expect(summary.totalVolumeKg, 60 * 10 + 65 * 8);
      expect(summary.exerciseNames, ['Barbell Bench Press']);
      expect(summary.isEmpty, isFalse);
    });

    test('excludes warm-ups from volume but still counts the set', () async {
      final id = await sessions.startSession();
      await sessions.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 15,
        actualWeightKg: 20,
        isWarmup: true,
      );
      await sessions.completeSession(id);

      final summary = (await history.recentSessions()).single;
      expect(summary.totalVolumeKg, 0);
      expect(summary.strengthSetCount, 1);
    });

    test('lists newest first and excludes sessions in progress', () async {
      await loggedSession(weight: 60);
      clock.advance(const Duration(days: 1));
      final second = await loggedSession(weight: 65);
      clock.advance(const Duration(days: 1));
      await sessions.startSession();

      final summaries = await history.recentSessions();
      expect(summaries, hasLength(2));
      expect(summaries.first.session.id, second);
    });

    test('counts cardio efforts', () async {
      final runId = await insertExercise(
        db,
        name: 'Outdoor Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );
      final id = await sessions.startSession();
      final entryId = await sessions.addCardioEntry(
        sessionId: id,
        exerciseId: runId,
        groupIndex: 0,
      );
      await sessions.completeCardioEntry(
        entryId,
        durationSeconds: 1500,
        distanceMeters: 5000,
      );
      await sessions.completeSession(id);

      final summary = (await history.recentSessions()).single;
      expect(summary.cardioCount, 1);
      expect(summary.exerciseNames, contains('Outdoor Run'));
    });

    test('respects the limit', () async {
      for (var i = 0; i < 5; i++) {
        await loggedSession(weight: 60 + i.toDouble());
        clock.advance(const Duration(days: 1));
      }
      expect(await history.recentSessions(limit: 3), hasLength(3));
    });
  });

  group('strengthProgress', () {
    test('returns one point per training day, heaviest set winning', () async {
      await loggedSession(weight: 60);
      await loggedSession(weight: 70);
      clock.advance(const Duration(days: 2));
      await loggedSession(weight: 65);

      final points = await history.strengthProgress(benchId);

      // Two sessions on day one collapse to a single point at the heavier
      // weight, so the chart shows one point per training day.
      expect(points, hasLength(2));
      expect(points.first.value, 70);
      expect(points.last.value, 65);
    });

    test('is chronological', () async {
      await loggedSession(weight: 60);
      clock.advance(const Duration(days: 3));
      await loggedSession(weight: 80);

      final points = await history.strengthProgress(benchId);
      expect(points.first.date.isBefore(points.last.date), isTrue);
    });

    test('excludes warm-ups', () async {
      // Otherwise a thorough warm-up day would look like a regression.
      await loggedSession(weight: 100, isWarmup: true);
      await loggedSession(weight: 60);

      final points = await history.strengthProgress(benchId);
      expect(points.single.value, 60);
    });

    test('is empty for an exercise with no history', () async {
      final other = await insertExercise(db, name: 'Overhead Press');
      expect(await history.strengthProgress(other), isEmpty);
    });
  });

  group('estimatedOneRepMaxProgress', () {
    test('tracks progress across changing rep schemes', () async {
      // 60x10 estimates higher than 70x3, even though the weight is lower.
      await loggedSession(weight: 60, reps: 10);
      clock.advance(const Duration(days: 2));
      await loggedSession(weight: 70, reps: 3);

      final points = await history.estimatedOneRepMaxProgress(benchId);
      expect(points, hasLength(2));
      expect(points.first.value, closeTo(80, 0.001));
      expect(points.last.value, closeTo(77, 0.001));
    });
  });

  group('cardio progress', () {
    late int runId;

    setUp(() async {
      runId = await insertExercise(
        db,
        name: 'Outdoor Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );
    });

    Future<void> logRun({required int seconds, required double meters}) async {
      final id = await sessions.startSession();
      final entryId = await sessions.addCardioEntry(
        sessionId: id,
        exerciseId: runId,
        groupIndex: 0,
      );
      await sessions.completeCardioEntry(
        entryId,
        durationSeconds: seconds,
        distanceMeters: meters,
      );
      await sessions.completeSession(id);
    }

    test('distance keeps the longest run of each day', () async {
      await logRun(seconds: 1500, meters: 5000);
      await logRun(seconds: 2400, meters: 8000);

      final points = await history.cardioDistanceProgress(runId);
      expect(points.single.value, 8000);
    });

    test('pace keeps the fastest of each day, where lower wins', () async {
      await logRun(seconds: 1500, meters: 5000); // 300 s/km
      await logRun(seconds: 1400, meters: 5000); // 280 s/km — faster

      final points = await history.cardioPaceProgress(runId);
      expect(points.single.value, closeTo(280, 1e-9));
    });

    test(
      'entries without distance are skipped rather than charted as zero',
      () async {
        final id = await sessions.startSession();
        final entryId = await sessions.addCardioEntry(
          sessionId: id,
          exerciseId: runId,
          groupIndex: 0,
        );
        await sessions.completeCardioEntry(entryId, durationSeconds: 1800);
        await sessions.completeSession(id);

        expect(await history.cardioDistanceProgress(runId), isEmpty);
        expect(await history.cardioPaceProgress(runId), isEmpty);
      },
    );
  });

  group('exercisesWithHistory', () {
    test('is empty before anything is logged', () async {
      expect(await history.exercisesWithHistory(), isEmpty);
    });

    test('lists only exercises that have been performed', () async {
      await insertExercise(db, name: 'Never Done');
      await loggedSession(weight: 60);

      final withHistory = await history.exercisesWithHistory();
      expect(withHistory.map((e) => e.name), ['Barbell Bench Press']);
    });

    test('includes cardio exercises', () async {
      final runId = await insertExercise(
        db,
        name: 'Outdoor Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );
      final id = await sessions.startSession();
      final entryId = await sessions.addCardioEntry(
        sessionId: id,
        exerciseId: runId,
        groupIndex: 0,
      );
      await sessions.completeCardioEntry(entryId, durationSeconds: 600);
      await sessions.completeSession(id);

      expect(
        (await history.exercisesWithHistory()).map((e) => e.name),
        contains('Outdoor Run'),
      );
    });

    test('does not list an exercise twice', () async {
      await loggedSession(weight: 60);
      clock.advance(const Duration(days: 1));
      await loggedSession(weight: 65);

      expect(await history.exercisesWithHistory(), hasLength(1));
    });
  });
}
