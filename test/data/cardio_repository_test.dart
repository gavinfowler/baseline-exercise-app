import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SessionRepository repo;
  late int runId;
  late int sessionId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    repo = SessionRepository(db, clock: clock);
    runId = await insertExercise(
      db,
      name: 'Treadmill Run',
      type: ExerciseType.cardio,
      cardioActivity: CardioActivity.run,
    );
    sessionId = await repo.startSession();
  });

  Future<int> addEntry() => repo.addCardioEntry(
    sessionId: sessionId,
    exerciseId: runId,
    groupIndex: 0,
  );

  group('adding', () {
    test('starts pending with no actuals', () async {
      final id = await addEntry();
      final entry = await repo.findCardioEntry(id);

      expect(entry!.status, EntryStatus.pending);
      expect(entry.actualDurationSeconds, isNull);
      expect(entry.performedAt, isNull);
    });

    test('shares the group-index sequence with strength sets', () async {
      await addEntry();
      expect(await repo.nextGroupIndex(sessionId), 1);

      await repo.addStrengthSet(
        sessionId: sessionId,
        exerciseId: runId,
        groupIndex: 1,
        roundIndex: 0,
      );
      // Otherwise a cardio entry and a strength block could collide on one
      // index and render out of order.
      expect(await repo.nextGroupIndex(sessionId), 2);
    });
  });

  group('completing', () {
    test('derives and stores pace', () async {
      final id = await addEntry();
      // 5 km in 25 minutes is 5:00/km.
      await repo.completeCardioEntry(
        id,
        durationSeconds: 1500,
        distanceMeters: 5000,
      );

      final entry = await repo.findCardioEntry(id);
      expect(entry!.status, EntryStatus.completed);
      expect(entry.actualPaceSecPerKm, closeTo(300, 1e-9));
      expect(entry.performedAt, clock.now());
    });

    test('leaves pace null when there is no distance', () async {
      final id = await addEntry();
      await repo.completeCardioEntry(id, durationSeconds: 1800);

      final entry = await repo.findCardioEntry(id);
      expect(entry!.actualDistanceMeters, isNull);
      expect(entry.actualPaceSecPerKm, isNull);
    });

    test('leaves pace null rather than infinite for zero distance', () async {
      // A stair climber logs time but no distance; an infinite pace would
      // poison the personal-record and chart queries.
      final id = await addEntry();
      await repo.completeCardioEntry(
        id,
        durationSeconds: 1200,
        distanceMeters: 0,
      );

      expect((await repo.findCardioEntry(id))!.actualPaceSecPerKm, isNull);
    });

    test('stores the machine and physiological fields', () async {
      final id = await addEntry();
      await repo.completeCardioEntry(
        id,
        durationSeconds: 1800,
        distanceMeters: 5000,
        inclinePercent: 1.5,
        resistanceLevel: 8,
        avgHeartRate: 148,
        maxHeartRate: 171,
        calories: 420,
        elevationGainMeters: 55,
        notes: 'Negative split',
      );

      final entry = await repo.findCardioEntry(id);
      expect(entry!.inclinePercent, 1.5);
      expect(entry.resistanceLevel, 8);
      expect(entry.avgHeartRate, 148);
      expect(entry.maxHeartRate, 171);
      expect(entry.calories, 420);
      expect(entry.elevationGainMeters, 55);
      expect(entry.notes, 'Negative split');
    });

    test('re-logging overwrites the previous values', () async {
      final id = await addEntry();
      await repo.completeCardioEntry(
        id,
        durationSeconds: 1500,
        distanceMeters: 5000,
      );
      await repo.completeCardioEntry(
        id,
        durationSeconds: 1200,
        distanceMeters: 4000,
      );

      final entry = await repo.findCardioEntry(id);
      expect(entry!.actualDurationSeconds, 1200);
      expect(entry.actualPaceSecPerKm, closeTo(300, 1e-9));
    });
  });

  group('session completion', () {
    test('marks unfinished cardio as skipped', () async {
      final pending = await addEntry();
      final done = await repo.addCardioEntry(
        sessionId: sessionId,
        exerciseId: runId,
        groupIndex: 1,
      );
      await repo.completeCardioEntry(done, durationSeconds: 600);

      await repo.completeSession(sessionId);

      expect(
        (await repo.findCardioEntry(pending))!.status,
        EntryStatus.skipped,
      );
      expect((await repo.findCardioEntry(done))!.status, EntryStatus.completed);
    });
  });

  group('splits', () {
    test('are written in order', () async {
      final id = await addEntry();
      await repo.replaceSplits(id, [
        (durationSeconds: 300, distanceMeters: 1000.0),
        (durationSeconds: 290, distanceMeters: 1000.0),
        (durationSeconds: 310, distanceMeters: 1000.0),
      ]);

      final splits = await repo.getSplits(id);
      expect(splits.map((s) => s.splitIndex), [0, 1, 2]);
      expect(splits.map((s) => s.durationSeconds), [300, 290, 310]);
    });

    test('replacing clears the previous list rather than appending', () async {
      final id = await addEntry();
      await repo.replaceSplits(id, [
        (durationSeconds: 300, distanceMeters: null),
        (durationSeconds: 290, distanceMeters: null),
      ]);
      await repo.replaceSplits(id, [
        (durationSeconds: 250, distanceMeters: null),
      ]);

      final splits = await repo.getSplits(id);
      expect(splits, hasLength(1));
      expect(splits.single.durationSeconds, 250);
    });

    test('are removed when the entry is deleted', () async {
      final id = await addEntry();
      await repo.replaceSplits(id, [
        (durationSeconds: 300, distanceMeters: null),
      ]);

      await repo.deleteCardioEntry(id);
      expect(await repo.getSplits(id), isEmpty);
    });
  });

  group('lastCompletedCardio', () {
    test('returns the most recent effort for prefilling', () async {
      final first = await addEntry();
      await repo.completeCardioEntry(
        first,
        durationSeconds: 1500,
        distanceMeters: 5000,
      );

      clock.advance(const Duration(days: 2));
      final second = await repo.addCardioEntry(
        sessionId: sessionId,
        exerciseId: runId,
        groupIndex: 1,
      );
      await repo.completeCardioEntry(
        second,
        durationSeconds: 1400,
        distanceMeters: 5000,
      );

      expect(
        (await repo.lastCompletedCardio(runId))!.actualDurationSeconds,
        1400,
      );
    });

    test('ignores entries that were never completed', () async {
      await addEntry();
      expect(await repo.lastCompletedCardio(runId), isNull);
    });
  });
}
