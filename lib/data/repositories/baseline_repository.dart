import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Stores the current working weight for each (plan, exercise, rep count).
///
/// Only static plans use these. A periodized plan's prescriptions are fixed for
/// the life of the program, so it never reads or writes a baseline.
class BaselineRepository {
  BaselineRepository(this._db);

  final AppDatabase _db;

  Future<ExerciseBaselineRow?> find({
    required int planId,
    required int exerciseId,
    required int reps,
  }) {
    return (_db.select(_db.exerciseBaselines)..where(
          (t) =>
              t.planId.equals(planId) &
              t.exerciseId.equals(exerciseId) &
              t.reps.equals(reps),
        ))
        .getSingleOrNull();
  }

  Future<List<ExerciseBaselineRow>> forPlan(int planId) {
    return (_db.select(
      _db.exerciseBaselines,
    )..where((t) => t.planId.equals(planId))).get();
  }

  Stream<List<ExerciseBaselineRow>> watchForPlan(int planId) {
    return (_db.select(
      _db.exerciseBaselines,
    )..where((t) => t.planId.equals(planId))).watch();
  }

  /// Inserts or replaces the baseline for this exact (plan, exercise, reps).
  Future<void> set({
    required int planId,
    required int exerciseId,
    required int reps,
    required double weightKg,
    required DateTime achievedAt,
    int? sourceSetId,
  }) async {
    await _db
        .into(_db.exerciseBaselines)
        .insert(
          ExerciseBaselinesCompanion.insert(
            planId: planId,
            exerciseId: exerciseId,
            reps: reps,
            weightKg: weightKg,
            achievedAt: achievedAt,
            sourceSetId: Value(sourceSetId),
          ),
          // The conflict to resolve is on the (plan, exercise, reps) unique
          // index, not on the surrogate primary key. Without naming the target,
          // drift upserts against `id`, which for a fresh auto-increment row
          // never collides — so the insert would violate the unique index
          // instead of updating the existing baseline.
          onConflict: DoUpdate(
            (_) => ExerciseBaselinesCompanion(
              weightKg: Value(weightKg),
              achievedAt: Value(achievedAt),
              sourceSetId: Value(sourceSetId),
            ),
            target: [
              _db.exerciseBaselines.planId,
              _db.exerciseBaselines.exerciseId,
              _db.exerciseBaselines.reps,
            ],
          ),
        );
  }

  /// Raises the baseline only if [weightKg] beats what is already recorded.
  ///
  /// Reports whether it wrote and what the previous weight was. Those are two
  /// separate facts — a first-ever baseline is written but has no predecessor —
  /// so they cannot be collapsed into one nullable return.
  Future<({bool raised, double? previousWeightKg})> raiseIfHeavier({
    required int planId,
    required int exerciseId,
    required int reps,
    required double weightKg,
    required DateTime achievedAt,
    int? sourceSetId,
  }) async {
    final existing = await find(
      planId: planId,
      exerciseId: exerciseId,
      reps: reps,
    );

    if (existing != null && weightKg <= existing.weightKg) {
      return (raised: false, previousWeightKg: existing.weightKg);
    }

    await set(
      planId: planId,
      exerciseId: exerciseId,
      reps: reps,
      weightKg: weightKg,
      achievedAt: achievedAt,
      sourceSetId: sourceSetId,
    );

    return (raised: true, previousWeightKg: existing?.weightKg);
  }

  Future<void> clearForPlan(int planId) async {
    await (_db.delete(
      _db.exerciseBaselines,
    )..where((t) => t.planId.equals(planId))).go();
  }
}
