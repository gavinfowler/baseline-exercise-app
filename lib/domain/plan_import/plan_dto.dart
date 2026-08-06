import '../models/enums.dart';

/// A parsed plan file.
///
/// Every measurement here is already **canonical** — kilograms, meters, seconds,
/// seconds per kilometre — because the parser knows the file's `units` and the
/// importer should not have to. Nothing downstream needs to think about pounds.
class PlanFileDto {
  const PlanFileDto({required this.schemaVersion, required this.plan});

  final String schemaVersion;
  final PlanDto plan;
}

class PlanDto {
  const PlanDto({
    required this.name,
    required this.mode,
    required this.days,
    this.description,
    this.scheduleType = ScheduleType.sequential,
    this.startDate,
    this.durationWeeks,
  });

  final String name;
  final String? description;
  final PlanMode mode;
  final ScheduleType scheduleType;
  final DateTime? startDate;
  final int? durationWeeks;
  final List<PlanDayDto> days;

  int get exerciseCount => days.fold(
    0,
    (sum, d) => sum + d.blocks.fold(0, (s, b) => s + b.exercises.length),
  );
}

class PlanDayDto {
  const PlanDayDto({
    required this.label,
    required this.blocks,
    this.weekNumber,
    this.dayOfWeek,
    this.notes,
  });

  final String label;
  final int? weekNumber;
  final Weekday? dayOfWeek;
  final String? notes;
  final List<PlanBlockDto> blocks;
}

class PlanBlockDto {
  const PlanBlockDto({
    required this.kind,
    required this.exercises,
    this.label,
    this.rounds = 1,
    this.restBetweenExercisesSeconds = 0,
    this.restAfterRoundSeconds = 90,
  });

  final BlockKind kind;
  final String? label;
  final int rounds;
  final int restBetweenExercisesSeconds;
  final int restAfterRoundSeconds;
  final List<PlanExerciseDto> exercises;
}

/// One prescribed exercise. Strength and cardio fields are both present but
/// mutually exclusive in practice; the parser rejects mixtures.
class PlanExerciseDto {
  const PlanExerciseDto({
    required this.name,
    required this.type,
    this.notes,
    // Strength
    this.reps,
    this.weightKg,
    this.weightMode = WeightMode.absolute,
    this.weightOffsetKg,
    this.weightPercent,
    this.rpe,
    this.tempo,
    this.toFailure = false,
    // Cardio
    this.activity,
    this.durationSeconds,
    this.distanceMeters,
    this.paceSecPerKm,
    this.inclinePercent,
    this.resistanceLevel,
    this.intervalsJson,
  });

  final String name;
  final ExerciseType type;
  final String? notes;

  final int? reps;
  final double? weightKg;
  final WeightMode weightMode;
  final double? weightOffsetKg;
  final double? weightPercent;
  final double? rpe;
  final String? tempo;
  final bool toFailure;

  final CardioActivity? activity;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? paceSecPerKm;
  final double? inclinePercent;
  final int? resistanceLevel;
  final String? intervalsJson;

  bool get isStrength => type == ExerciseType.strength;
}
