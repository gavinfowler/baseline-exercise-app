import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/db/seed_exercises.dart';
import 'package:exercise_app/data/repositories/exercise_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  test('seeds the starter catalog into an empty database', () async {
    final inserted = await seedExercisesIfEmpty(db);

    expect(inserted, starterExercises.length);
    expect(await db.select(db.exercises).get(), hasLength(inserted));
  });

  test('does nothing when the catalog already has entries', () async {
    await ExerciseRepository(
      db,
    ).create(name: 'My Own Lift', type: ExerciseType.strength);

    final inserted = await seedExercisesIfEmpty(db);

    // Guarding on emptiness means a user who deletes a starter exercise never
    // has it silently reappear.
    expect(inserted, 0);
    expect(await db.select(db.exercises).get(), hasLength(1));
  });

  test('is safe to call twice', () async {
    await seedExercisesIfEmpty(db);
    await seedExercisesIfEmpty(db);
    expect(
      await db.select(db.exercises).get(),
      hasLength(starterExercises.length),
    );
  });

  test('starter names are unique after normalization', () {
    // A duplicate would trip the unique index and abort the whole seed batch.
    final keys = starterExercises
        .map((e) => normalizeExerciseName(e.name))
        .toList();
    expect(keys.toSet(), hasLength(keys.length));
  });

  test('every cardio entry declares an activity, and no strength one does', () {
    for (final exercise in starterExercises) {
      if (exercise.type == ExerciseType.cardio) {
        expect(
          exercise.cardioActivity,
          isNotNull,
          reason: '${exercise.name} is cardio but has no activity',
        );
      } else {
        expect(
          exercise.cardioActivity,
          isNull,
          reason: '${exercise.name} is strength but declares an activity',
        );
      }
    }
  });

  test('seeded exercises are marked as not custom', () async {
    await seedExercisesIfEmpty(db);
    final rows = await db.select(db.exercises).get();
    expect(rows.every((r) => !r.isCustom), isTrue);
  });

  test('covers both strength and cardio', () async {
    await seedExercisesIfEmpty(db);
    final repo = ExerciseRepository(db);

    expect(await repo.getAll(type: ExerciseType.strength), isNotEmpty);
    expect(await repo.getAll(type: ExerciseType.cardio), isNotEmpty);
  });
}
