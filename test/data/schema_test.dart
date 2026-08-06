import 'package:drift/drift.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import '../support/builders.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  test('foreign keys are enforced', () async {
    // SQLite disables foreign keys per connection by default. If the
    // `PRAGMA foreign_keys = ON` in the migration strategy ever regresses,
    // every cascade rule in the schema silently stops working.
    await expectLater(
      db
          .into(db.planDays)
          .insert(
            PlanDaysCompanion.insert(
              planId: 9999,
              orderIndex: 0,
              label: 'Orphan',
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a plan cascades through days, blocks and items', () async {
    final exerciseId = await insertExercise(db);
    final planId = await insertPlan(db);
    final dayId = await insertPlanDay(db, planId: planId);
    final blockId = await insertPlanBlock(db, planDayId: dayId);
    await insertPlanItem(db, planBlockId: blockId, exerciseId: exerciseId);

    await (db.delete(db.plans)..where((t) => t.id.equals(planId))).go();

    expect(await db.select(db.planDays).get(), isEmpty);
    expect(await db.select(db.planBlocks).get(), isEmpty);
    expect(await db.select(db.planItems).get(), isEmpty);
    // The exercise itself belongs to the catalog and must survive.
    expect(await db.select(db.exercises).get(), hasLength(1));
  });

  test('an exercise cannot be deleted while history references it', () async {
    final exerciseId = await insertExercise(db);
    final sessionId = await insertSession(db);
    await insertStrengthSet(db, sessionId: sessionId, exerciseId: exerciseId);

    // Catalog entries are archived, never deleted, precisely so that past
    // workouts keep meaning something.
    await expectLater(
      (db.delete(db.exercises)..where((t) => t.id.equals(exerciseId))).go(),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a session removes its logged sets', () async {
    final exerciseId = await insertExercise(db);
    final sessionId = await insertSession(db);
    await insertStrengthSet(db, sessionId: sessionId, exerciseId: exerciseId);

    await (db.delete(db.sessions)..where((t) => t.id.equals(sessionId))).go();

    expect(await db.select(db.strengthSets).get(), isEmpty);
  });

  test('exercise name keys are unique', () async {
    await insertExercise(db, name: 'Barbell Bench Press');
    await expectLater(
      insertExercise(db, name: 'Barbell Bench Press'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a baseline is unique per plan, exercise and rep count', () async {
    final exerciseId = await insertExercise(db);
    final planId = await insertPlan(db);

    Future<int> addBaseline({required int reps, required double weight}) {
      return db
          .into(db.exerciseBaselines)
          .insert(
            ExerciseBaselinesCompanion.insert(
              planId: planId,
              exerciseId: exerciseId,
              reps: reps,
              weightKg: weight,
              achievedAt: DateTime.utc(2026, 1, 5),
            ),
          );
    }

    await addBaseline(reps: 8, weight: 60);
    // A different rep count is a different baseline, which is the whole point
    // of keying on reps.
    await addBaseline(reps: 5, weight: 70);
    expect(await db.select(db.exerciseBaselines).get(), hasLength(2));

    await expectLater(
      addBaseline(reps: 8, weight: 65),
      throwsA(isA<SqliteException>()),
    );
  });

  test(
    'personal records are unique per exercise, type and rep count',
    () async {
      final exerciseId = await insertExercise(db);

      Future<int> addRecord({required RecordType type, int reps = 0}) {
        return db
            .into(db.personalRecords)
            .insert(
              PersonalRecordsCompanion.insert(
                exerciseId: exerciseId,
                recordType: type,
                reps: Value(reps),
                value: 100,
                achievedAt: DateTime.utc(2026, 1, 5),
              ),
            );
      }

      await addRecord(type: RecordType.maxWeightAtReps, reps: 8);
      await addRecord(type: RecordType.maxWeight);

      // `reps` defaults to 0 rather than NULL specifically so this collides:
      // SQLite treats NULLs as distinct in a unique index, which would have let
      // duplicate "max weight" records accumulate silently.
      await expectLater(
        addRecord(type: RecordType.maxWeight),
        throwsA(isA<SqliteException>()),
      );
    },
  );

  test('enum columns round-trip', () async {
    final planId = await insertPlan(
      db,
      mode: PlanMode.periodized,
      scheduleType: ScheduleType.weekly,
      source: PlanSource.imported,
    );

    final plan = await (db.select(
      db.plans,
    )..where((t) => t.id.equals(planId))).getSingle();

    expect(plan.mode, PlanMode.periodized);
    expect(plan.scheduleType, ScheduleType.weekly);
    expect(plan.source, PlanSource.imported);
  });

  test('the schema is at version 1', () {
    expect(db.schemaVersion, 1);
  });
}
