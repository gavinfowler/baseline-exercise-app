import '../../core/result.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../models/enums.dart';
import '../progression/progression_service.dart';
import 'plan_dto.dart';
import 'plan_parser.dart';

/// What an import created, for the confirmation shown afterwards.
class ImportSummary {
  const ImportSummary({
    required this.planId,
    required this.planName,
    required this.mode,
    required this.dayCount,
    required this.blockCount,
    required this.exerciseCount,
    required this.createdExerciseNames,
  });

  final int planId;
  final String planName;
  final PlanMode mode;
  final int dayCount;
  final int blockCount;
  final int exerciseCount;

  /// Exercises that were not already in the catalog and had to be created.
  /// Worth surfacing: a typo in a generated plan shows up here as a near
  /// duplicate of an existing movement.
  final List<String> createdExerciseNames;
}

/// Writes a parsed plan into the database.
class PlanImporter {
  PlanImporter({
    required AppDatabase db,
    required PlanRepository plans,
    required ExerciseRepository exercises,
    required ProgressionService progression,
  }) : _db = db,
       _plans = plans,
       _exercises = exercises,
       _progression = progression;

  final AppDatabase _db;
  final PlanRepository _plans;
  final ExerciseRepository _exercises;
  final ProgressionService _progression;

  /// Imports a plan atomically.
  ///
  /// The whole plan is written inside one transaction: a file that fails partway
  /// through leaves nothing behind, rather than a half-built plan the user has
  /// to clean up by hand.
  Future<ImportSummary> import(PlanFileDto file) async {
    final plan = file.plan;
    final createdNames = <String>[];

    final planId = await _db.transaction(() async {
      final planId = await _plans.createPlan(
        name: plan.name,
        description: plan.description,
        mode: plan.mode,
        scheduleType: plan.scheduleType,
        source: PlanSource.imported,
        startDate: plan.startDate,
        durationWeeks: plan.durationWeeks,
        schemaVersion: file.schemaVersion,
      );

      for (var dayIndex = 0; dayIndex < plan.days.length; dayIndex++) {
        final day = plan.days[dayIndex];
        final dayId = await _plans.addDay(
          planId: planId,
          label: day.label,
          orderIndex: dayIndex,
          weekNumber: day.weekNumber,
          dayOfWeek: day.dayOfWeek,
          notes: day.notes,
        );

        for (var blockIndex = 0; blockIndex < day.blocks.length; blockIndex++) {
          final block = day.blocks[blockIndex];
          final blockId = await _plans.addBlock(
            planDayId: dayId,
            orderIndex: blockIndex,
            kind: block.kind,
            label: block.label,
            rounds: block.rounds,
            restBetweenExercisesSeconds: block.restBetweenExercisesSeconds,
            restAfterRoundSeconds: block.restAfterRoundSeconds,
          );

          for (
            var itemIndex = 0;
            itemIndex < block.exercises.length;
            itemIndex++
          ) {
            final dto = block.exercises[itemIndex];

            // Plans reference exercises by name so they can be written without
            // knowing the user's catalog; resolve or create here.
            final existing = await _exercises.findByName(dto.name);
            if (existing == null) createdNames.add(dto.name);

            final exercise =
                existing ??
                await _exercises.create(
                  name: dto.name,
                  type: dto.type,
                  cardioActivity: dto.activity,
                );

            if (dto.isStrength) {
              await _plans.addStrengthItem(
                planBlockId: blockId,
                exerciseId: exercise.id,
                orderIndex: itemIndex,
                targetReps: dto.reps,
                targetWeightKg: dto.weightKg,
                weightMode: dto.weightMode,
                weightOffsetKg: dto.weightOffsetKg,
                weightPercent: dto.weightPercent,
                rpe: dto.rpe,
                tempo: dto.tempo,
                toFailure: dto.toFailure,
                notes: dto.notes,
              );
            } else {
              await _plans.addCardioItem(
                planBlockId: blockId,
                exerciseId: exercise.id,
                orderIndex: itemIndex,
                targetDurationSeconds: dto.durationSeconds,
                targetDistanceMeters: dto.distanceMeters,
                targetPaceSecPerKm: dto.paceSecPerKm,
                targetInclinePercent: dto.inclinePercent,
                targetResistanceLevel: dto.resistanceLevel,
                intervalsJson: dto.intervalsJson,
                notes: dto.notes,
              );
            }
          }
        }
      }

      return planId;
    });

    // Static plans start from the weights written in the file. Done outside the
    // transaction because it reads the plan back through the repository.
    await _progression.seedBaselines(planId);

    return ImportSummary(
      planId: planId,
      planName: plan.name,
      mode: plan.mode,
      dayCount: plan.days.length,
      blockCount: plan.days.fold(0, (sum, d) => sum + d.blocks.length),
      exerciseCount: plan.exerciseCount,
      createdExerciseNames: createdNames,
    );
  }

  /// Convenience: parse then import in one step.
  ///
  /// Returns the parse issues untouched when the file is invalid, so nothing is
  /// written and the user sees every problem at once.
  Future<ImportOutcome> importSource(String source) async {
    final parsed = const PlanParser().parse(source);
    return switch (parsed) {
      Ok<PlanFileDto>(:final value) => ImportOutcome.success(
        await import(value),
      ),
      Err<PlanFileDto>(:final issues) => ImportOutcome.failure(issues),
    };
  }
}

/// Either a completed import or the reasons it could not run.
class ImportOutcome {
  const ImportOutcome.success(ImportSummary this.summary) : issues = const [];

  const ImportOutcome.failure(this.issues) : summary = null;

  final ImportSummary? summary;
  final List<ValidationIssue> issues;

  bool get isSuccess => summary != null;
}
