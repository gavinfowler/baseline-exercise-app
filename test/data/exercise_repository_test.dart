import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/exercise_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late ExerciseRepository repo;

  setUp(() {
    db = createTestDatabase();
    clock = FakeClock();
    repo = ExerciseRepository(db, clock: clock);
  });

  group('normalizeExerciseName', () {
    test('lower-cases, trims and collapses whitespace', () {
      expect(
        normalizeExerciseName('  Barbell   Bench  Press '),
        'barbell bench press',
      );
    });
  });

  group('create', () {
    test('stores the display name and its lookup key', () async {
      final created = await repo.create(
        name: '  Barbell Bench Press ',
        type: ExerciseType.strength,
      );

      expect(created.name, 'Barbell Bench Press');
      expect(created.nameKey, 'barbell bench press');
      expect(created.type, ExerciseType.strength);
      expect(created.isCustom, isTrue);
      expect(created.createdAt, clock.now());
    });

    test('records the cardio activity for cardio exercises', () async {
      final created = await repo.create(
        name: 'Treadmill Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );

      expect(created.cardioActivity, CardioActivity.run);
    });
  });

  group('findByName', () {
    test('matches regardless of case and spacing', () async {
      await repo.create(
        name: 'Barbell Bench Press',
        type: ExerciseType.strength,
      );

      expect(await repo.findByName('barbell bench press'), isNotNull);
      expect(await repo.findByName('  BARBELL   BENCH PRESS  '), isNotNull);
    });

    test('returns null for an unknown name', () async {
      expect(await repo.findByName('Zercher Squat'), isNull);
    });
  });

  group('ensure', () {
    test('creates the exercise when it does not exist', () async {
      final created = await repo.ensure(
        name: 'Romanian Deadlift',
        type: ExerciseType.strength,
      );

      expect(created.name, 'Romanian Deadlift');
      expect(await repo.getAll(), hasLength(1));
    });

    test('reuses an existing exercise instead of duplicating it', () async {
      // This is what stops an imported plan from filling the catalog with
      // near-identical entries.
      final first = await repo.create(
        name: 'Barbell Bench Press',
        type: ExerciseType.strength,
      );
      final second = await repo.ensure(
        name: 'barbell  bench press',
        type: ExerciseType.strength,
      );

      expect(second.id, first.id);
      expect(await repo.getAll(), hasLength(1));
    });
  });

  group('listing', () {
    test('returns exercises alphabetically', () async {
      await repo.create(name: 'Squat', type: ExerciseType.strength);
      await repo.create(name: 'Bench Press', type: ExerciseType.strength);
      await repo.create(name: 'Deadlift', type: ExerciseType.strength);

      final names = (await repo.getAll()).map((e) => e.name).toList();
      expect(names, ['Bench Press', 'Deadlift', 'Squat']);
    });

    test('filters by type', () async {
      await repo.create(name: 'Squat', type: ExerciseType.strength);
      await repo.create(
        name: 'Treadmill Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
      );

      final cardio = await repo.getAll(type: ExerciseType.cardio);
      expect(cardio.map((e) => e.name), ['Treadmill Run']);
    });

    test('hides archived exercises unless asked for them', () async {
      final squat = await repo.create(
        name: 'Squat',
        type: ExerciseType.strength,
      );
      await repo.create(name: 'Bench Press', type: ExerciseType.strength);

      await repo.setArchived(squat.id, archived: true);

      expect((await repo.getAll()).map((e) => e.name), ['Bench Press']);
      expect(await repo.getAll(includeArchived: true), hasLength(2));
    });
  });

  group('rename', () {
    test('updates the lookup key alongside the display name', () async {
      final created = await repo.create(
        name: 'Bench Press',
        type: ExerciseType.strength,
      );

      clock.advance(const Duration(days: 1));
      await repo.rename(created.id, 'Barbell Bench Press');

      // Without the key being rewritten, lookups by the new name would miss.
      final found = await repo.findByName('BARBELL BENCH PRESS');
      expect(found, isNotNull);
      expect(found!.id, created.id);
      expect(found.updatedAt, clock.now());
      expect(await repo.findByName('Bench Press'), isNull);
    });
  });

  group('filtering', () {
    setUp(() async {
      await repo.create(
        name: 'Bench Press',
        type: ExerciseType.strength,
        muscleGroup: 'Chest',
        equipment: 'Barbell',
      );
      await repo.create(
        name: 'Dumbbell Fly',
        type: ExerciseType.strength,
        muscleGroup: 'Chest',
        equipment: 'Dumbbell',
      );
      await repo.create(
        name: 'Back Squat',
        type: ExerciseType.strength,
        muscleGroup: 'Legs',
        equipment: 'Barbell',
      );
      await repo.create(
        name: 'Treadmill Run',
        type: ExerciseType.cardio,
        cardioActivity: CardioActivity.run,
        equipment: 'Treadmill',
      );
    });

    test('narrows by muscle group', () async {
      final rows = await repo.getAll(muscleGroup: 'Chest');
      expect(rows.map((e) => e.name), ['Bench Press', 'Dumbbell Fly']);
    });

    test('narrows by equipment', () async {
      final rows = await repo.getAll(equipment: 'Barbell');
      expect(rows.map((e) => e.name), ['Back Squat', 'Bench Press']);
    });

    test('matches free-text values case-insensitively', () async {
      // An imported plan may well have written "barbell".
      expect(await repo.getAll(equipment: 'barbell'), hasLength(2));
      expect(await repo.getAll(muscleGroup: 'CHEST'), hasLength(2));
    });

    test('combines every filter', () async {
      final rows = await repo.getAll(
        type: ExerciseType.strength,
        muscleGroup: 'Chest',
        equipment: 'Barbell',
      );
      expect(rows.map((e) => e.name), ['Bench Press']);
    });

    test('a blank filter is treated as no filter', () async {
      expect(await repo.getAll(muscleGroup: '  '), hasLength(4));
      expect(await repo.getAll(equipment: ''), hasLength(4));
    });

    test('archived exercises are hidden unless asked for', () async {
      final fly = await repo.findByName('Dumbbell Fly');
      await repo.setArchived(fly!.id, archived: true);

      expect(await repo.getAll(muscleGroup: 'Chest'), hasLength(1));
      expect(
        await repo.getAll(muscleGroup: 'Chest', includeArchived: true),
        hasLength(2),
      );
    });

    test('watchAll applies the same filters as getAll', () async {
      // The two read paths share one query builder; this is the guard that
      // they cannot drift apart.
      final rows = await repo
          .watchAll(type: ExerciseType.cardio, equipment: 'Treadmill')
          .first;
      expect(rows.map((e) => e.name), ['Treadmill Run']);
    });
  });

  group('watchAll', () {
    test('emits again when the catalog changes', () async {
      final emissions = <List<String>>[];
      final sub = repo.watchAll().listen(
        (rows) => emissions.add(rows.map((e) => e.name).toList()),
      );

      await repo.create(name: 'Squat', type: ExerciseType.strength);
      await repo.create(name: 'Bench Press', type: ExerciseType.strength);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emissions.last, ['Bench Press', 'Squat']);
    });
  });
}
