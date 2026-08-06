import 'package:drift/drift.dart' show Value;
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
  late int benchId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    repo = SessionRepository(db, clock: clock);
    benchId = await insertExercise(db);
  });

  group('starting a session', () {
    test('records the start time from the clock', () async {
      final id = await repo.startSession();
      final session = await repo.findById(id);

      expect(session!.startedAt, clock.now());
      expect(session.status, SessionStatus.inProgress);
      expect(session.planId, isNull);
    });

    test('is discoverable as the active session', () async {
      final id = await repo.startSession();
      expect((await repo.getActiveSession())!.id, id);
    });

    test('there is no active session before one starts', () async {
      expect(await repo.getActiveSession(), isNull);
    });

    test('the most recent wins if an older session was left open', () async {
      // Happens when the app is killed mid-workout.
      await repo.startSession();
      clock.advance(const Duration(hours: 2));
      final second = await repo.startSession();

      expect((await repo.getActiveSession())!.id, second);
    });
  });

  group('completing a session', () {
    test('stamps the end time and duration', () async {
      final id = await repo.startSession();
      clock.advance(const Duration(minutes: 47, seconds: 30));
      await repo.completeSession(id);

      final session = await repo.findById(id);
      expect(session!.status, SessionStatus.completed);
      expect(session.endedAt, clock.now());
      expect(session.durationSeconds, 2850);
    });

    test(
      'marks unfinished sets skipped rather than leaving them pending',
      () async {
        final id = await repo.startSession();
        await repo.addStrengthSet(
          sessionId: id,
          exerciseId: benchId,
          groupIndex: 0,
          roundIndex: 0,
          status: EntryStatus.pending,
        );
        await repo.addStrengthSet(
          sessionId: id,
          exerciseId: benchId,
          groupIndex: 0,
          roundIndex: 1,
          actualReps: 8,
          actualWeightKg: 60,
        );

        await repo.completeSession(id);

        // History must distinguish "did not do it" from "not yet done".
        final sets = await repo.getStrengthSets(id);
        expect(sets.map((s) => s.status), [
          EntryStatus.skipped,
          EntryStatus.completed,
        ]);
      },
    );

    test('is a no-op for a session that does not exist', () async {
      await expectLater(repo.completeSession(9999), completes);
    });

    test('a completed session is no longer active', () async {
      final id = await repo.startSession();
      await repo.completeSession(id);
      expect(await repo.getActiveSession(), isNull);
    });
  });

  group('logging sets', () {
    test('stamps performedAt for completed sets only', () async {
      final id = await repo.startSession();

      final doneId = await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 8,
        actualWeightKg: 60,
      );
      final pendingId = await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 1,
        status: EntryStatus.pending,
      );

      final sets = await repo.getStrengthSets(id);
      final done = sets.firstWhere((s) => s.id == doneId);
      final pending = sets.firstWhere((s) => s.id == pendingId);

      expect(done.performedAt, clock.now());
      expect(pending.performedAt, isNull);
    });

    test('returns sets ordered by group, then round, then position', () async {
      final id = await repo.startSession();
      // Inserted deliberately out of order.
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 1,
        roundIndex: 0,
      );
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 1,
      );
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        itemIndex: 1,
      );
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
      );

      final sets = await repo.getStrengthSets(id);
      expect(
        sets.map((s) => '${s.groupIndex}.${s.roundIndex}.${s.itemIndex}'),
        ['0.0.0', '0.0.1', '0.1.0', '1.0.0'],
      );
    });

    test('preserves superset grouping on the logged rows', () async {
      final id = await repo.startSession();
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        groupKind: BlockKind.superset,
        groupLabel: 'A',
        roundIndex: 0,
        itemIndex: 0,
      );

      final set = (await repo.getStrengthSets(id)).single;
      expect(set.groupKind, BlockKind.superset);
      expect(set.groupLabel, 'A');
    });

    test('completing a planned set fills in the actuals', () async {
      final id = await repo.startSession();
      final setId = await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        plannedReps: 8,
        plannedWeightKg: 60,
        status: EntryStatus.pending,
      );

      clock.advance(const Duration(minutes: 3));
      await repo.completeStrengthSet(
        setId,
        actualReps: 8,
        actualWeightKg: 65,
        rpe: 8.5,
      );

      final set = (await repo.getStrengthSets(id)).single;
      expect(set.status, EntryStatus.completed);
      expect(set.actualReps, 8);
      expect(set.actualWeightKg, 65);
      expect(set.rpe, 8.5);
      expect(set.performedAt, clock.now());
      // The prescription snapshot must survive untouched.
      expect(set.plannedReps, 8);
      expect(set.plannedWeightKg, 60);
    });

    test('deleting a set removes only that set', () async {
      final id = await repo.startSession();
      final first = await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
      );
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 1,
      );

      await repo.deleteStrengthSet(first);
      expect(await repo.getStrengthSets(id), hasLength(1));
    });
  });

  group('index helpers', () {
    test(
      'nextGroupIndex starts at zero and then follows the maximum',
      () async {
        final id = await repo.startSession();
        expect(await repo.nextGroupIndex(id), 0);

        await repo.addStrengthSet(
          sessionId: id,
          exerciseId: benchId,
          groupIndex: 0,
          roundIndex: 0,
        );
        expect(await repo.nextGroupIndex(id), 1);

        await repo.addStrengthSet(
          sessionId: id,
          exerciseId: benchId,
          groupIndex: 5,
          roundIndex: 0,
        );
        expect(await repo.nextGroupIndex(id), 6);
      },
    );

    test('nextRoundIndex counts rounds within one group only', () async {
      final id = await repo.startSession();
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
      );
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 1,
      );
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 1,
        roundIndex: 0,
      );

      expect(await repo.nextRoundIndex(id, 0), 2);
      expect(await repo.nextRoundIndex(id, 1), 1);
      expect(await repo.nextRoundIndex(id, 2), 0);
    });
  });

  group('lastCompletedSet', () {
    test(
      'returns the most recent working set, for prefilling the form',
      () async {
        final id = await repo.startSession();
        await repo.addStrengthSet(
          sessionId: id,
          exerciseId: benchId,
          groupIndex: 0,
          roundIndex: 0,
          actualReps: 8,
          actualWeightKg: 60,
        );

        clock.advance(const Duration(days: 3));
        final later = await repo.startSession();
        await repo.addStrengthSet(
          sessionId: later,
          exerciseId: benchId,
          groupIndex: 0,
          roundIndex: 0,
          actualReps: 8,
          actualWeightKg: 65,
        );

        final last = await repo.lastCompletedSet(benchId);
        expect(last!.actualWeightKg, 65);
      },
    );

    test('ignores warm-ups', () async {
      final id = await repo.startSession();
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 8,
        actualWeightKg: 60,
      );
      clock.advance(const Duration(minutes: 5));
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 1,
        roundIndex: 0,
        actualReps: 10,
        actualWeightKg: 20,
        isWarmup: true,
      );

      expect((await repo.lastCompletedSet(benchId))!.actualWeightKg, 60);
    });

    test('can exclude the session in progress', () async {
      final first = await repo.startSession();
      await repo.addStrengthSet(
        sessionId: first,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 8,
        actualWeightKg: 60,
      );

      clock.advance(const Duration(days: 2));
      final current = await repo.startSession();
      await repo.addStrengthSet(
        sessionId: current,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 8,
        actualWeightKg: 70,
      );

      final previous = await repo.lastCompletedSet(
        benchId,
        excludingSessionId: current,
      );
      expect(previous!.actualWeightKg, 60);
    });

    test('returns null when the exercise has never been logged', () async {
      final other = await insertExercise(db, name: 'Overhead Press');
      expect(await repo.lastCompletedSet(other), isNull);
    });
  });

  group('history', () {
    test(
      'lists completed sessions newest first, excluding in-progress ones',
      () async {
        final first = await repo.startSession();
        await repo.completeSession(first);

        clock.advance(const Duration(days: 1));
        final second = await repo.startSession();
        await repo.completeSession(second);

        clock.advance(const Duration(days: 1));
        await repo.startSession();

        final history = await repo.watchHistory().first;
        expect(history.map((s) => s.id), [second, first]);
      },
    );
  });

  group('abandoning', () {
    test('clears the active session without deleting its data', () async {
      final id = await repo.startSession();
      await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
      );

      await repo.abandonSession(id);

      expect(await repo.getActiveSession(), isNull);
      expect((await repo.findById(id))!.status, SessionStatus.abandoned);
      expect(await repo.getStrengthSets(id), hasLength(1));
    });
  });

  group('notes', () {
    test('round-trip', () async {
      final id = await repo.startSession();
      await repo.setSessionNotes(id, 'Felt strong');
      expect((await repo.findById(id))!.notes, 'Felt strong');

      await repo.setSessionNotes(id, null);
      expect((await repo.findById(id))!.notes, isNull);
    });
  });

  group('updateStrengthSet', () {
    test('changes only the fields provided', () async {
      final id = await repo.startSession();
      final setId = await repo.addStrengthSet(
        sessionId: id,
        exerciseId: benchId,
        groupIndex: 0,
        roundIndex: 0,
        actualReps: 8,
        actualWeightKg: 60,
      );

      await repo.updateStrengthSet(setId, actualReps: const Value(10));

      final set = (await repo.getStrengthSets(id)).single;
      expect(set.actualReps, 10);
      expect(set.actualWeightKg, 60);
    });
  });
}
