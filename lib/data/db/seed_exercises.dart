import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../repositories/exercise_repository.dart';
import 'app_database.dart';

/// A starter exercise so the app is usable the moment it opens.
class SeedExercise {
  const SeedExercise(
    this.name,
    this.type, {
    this.cardioActivity,
    this.muscleGroup,
    this.equipment,
  });

  final String name;
  final ExerciseType type;
  final CardioActivity? cardioActivity;
  final String? muscleGroup;
  final String? equipment;
}

/// Seeds the catalog if and only if it is empty.
///
/// Guarding on emptiness rather than on a "has seeded" flag means a user who
/// deliberately deletes a starter exercise never has it silently reappear.
Future<int> seedExercisesIfEmpty(AppDatabase db) async {
  final existing = await db.select(db.exercises).get();
  if (existing.isNotEmpty) return 0;

  final now = DateTime.now();
  await db.batch((batch) {
    batch.insertAll(
      db.exercises,
      starterExercises.map(
        (e) => ExercisesCompanion.insert(
          name: e.name,
          nameKey: normalizeExerciseName(e.name),
          type: e.type,
          cardioActivity: Value(e.cardioActivity),
          muscleGroup: Value(e.muscleGroup),
          equipment: Value(e.equipment),
          // Seeded entries are not "custom" — the distinction lets the UI offer
          // to restore the starter set later without touching the user's own.
          isCustom: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  });
  return starterExercises.length;
}

/// Common movements, chosen to cover the usual training splits without turning
/// the picker into a catalogue the user has to scroll past.
const List<SeedExercise> starterExercises = [
  // ---- Chest ----
  SeedExercise(
    'Barbell Bench Press',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Incline Barbell Bench Press',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Dumbbell Bench Press',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Dumbbell Fly',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Cable Chest Fly',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Cable',
  ),
  SeedExercise(
    'Push-Up',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Bodyweight',
  ),

  // ---- Back ----
  SeedExercise(
    'Deadlift',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Barbell Row',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Pull-Up',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Bodyweight',
  ),
  SeedExercise(
    'Chin-Up',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Bodyweight',
  ),
  SeedExercise(
    'Lat Pulldown',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),
  SeedExercise(
    'Seated Cable Row',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),
  SeedExercise(
    'Dumbbell Row',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Face Pull',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),

  // ---- Legs ----
  SeedExercise(
    'Back Squat',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Front Squat',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Romanian Deadlift',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Leg Press',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  SeedExercise(
    'Walking Lunge',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Bulgarian Split Squat',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Leg Curl',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  SeedExercise(
    'Leg Extension',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  SeedExercise(
    'Standing Calf Raise',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  SeedExercise(
    'Hip Thrust',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),

  // ---- Shoulders ----
  SeedExercise(
    'Overhead Press',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Dumbbell Shoulder Press',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Lateral Raise',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Rear Delt Fly',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Dumbbell',
  ),

  // ---- Arms ----
  SeedExercise(
    'Barbell Curl',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Dumbbell Curl',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Hammer Curl',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Dumbbell',
  ),
  SeedExercise(
    'Triceps Pushdown',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Cable',
  ),
  SeedExercise(
    'Skullcrusher',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Barbell',
  ),
  SeedExercise(
    'Dip',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Bodyweight',
  ),

  // ---- Core ----
  SeedExercise(
    'Plank',
    ExerciseType.strength,
    muscleGroup: 'Core',
    equipment: 'Bodyweight',
  ),
  SeedExercise(
    'Hanging Leg Raise',
    ExerciseType.strength,
    muscleGroup: 'Core',
    equipment: 'Bodyweight',
  ),
  SeedExercise(
    'Cable Crunch',
    ExerciseType.strength,
    muscleGroup: 'Core',
    equipment: 'Cable',
  ),

  // ---- Cardio ----
  SeedExercise(
    'Outdoor Run',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.run,
  ),
  SeedExercise(
    'Treadmill Run',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.run,
    equipment: 'Treadmill',
  ),
  SeedExercise(
    'Walk',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.walk,
  ),
  SeedExercise(
    'Hike',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.hike,
  ),
  SeedExercise(
    'Outdoor Cycle',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.cycle,
  ),
  SeedExercise(
    'Stationary Bike',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.cycle,
    equipment: 'Stationary Bike',
  ),
  SeedExercise(
    'Rowing Machine',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.row,
    equipment: 'Rower',
  ),
  SeedExercise(
    'Elliptical',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.elliptical,
    equipment: 'Elliptical',
  ),
  SeedExercise(
    'Stair Climber',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.stairs,
    equipment: 'Stair Climber',
  ),
  SeedExercise(
    'Swim',
    ExerciseType.cardio,
    cardioActivity: CardioActivity.swim,
  ),
];
