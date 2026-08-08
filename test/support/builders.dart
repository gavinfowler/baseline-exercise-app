import 'package:drift/drift.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/exercise_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';

/// Fixture builders with sensible defaults, so a test only states the values it
/// actually cares about.
final DateTime _defaultTime = DateTime.utc(2026, 1, 5, 9, 30);

Future<int> insertExercise(
  AppDatabase db, {
  String name = 'Barbell Bench Press',
  ExerciseType type = ExerciseType.strength,
  CardioActivity? cardioActivity,
}) {
  return db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          name: name,
          nameKey: normalizeExerciseName(name),
          type: type,
          cardioActivity: Value(cardioActivity),
          createdAt: _defaultTime,
          updatedAt: _defaultTime,
        ),
      );
}

Future<int> insertPlan(
  AppDatabase db, {
  String name = 'Test Plan',
  PlanMode mode = PlanMode.staticPlan,
  ScheduleType scheduleType = ScheduleType.sequential,
  PlanSource source = PlanSource.ui,
  int? durationWeeks,
}) {
  return db
      .into(db.plans)
      .insert(
        PlansCompanion.insert(
          name: name,
          mode: mode,
          scheduleType: scheduleType,
          source: source,
          durationWeeks: Value(durationWeeks),
          createdAt: _defaultTime,
          updatedAt: _defaultTime,
        ),
      );
}

Future<int> insertPlanDay(
  AppDatabase db, {
  required int planId,
  String label = 'Day 1',
  int orderIndex = 0,
  int? weekNumber,
  Weekday? dayOfWeek,
}) {
  return db
      .into(db.planDays)
      .insert(
        PlanDaysCompanion.insert(
          planId: planId,
          orderIndex: orderIndex,
          label: label,
          weekNumber: Value(weekNumber),
          dayOfWeek: Value(dayOfWeek),
        ),
      );
}

Future<int> insertPlanBlock(
  AppDatabase db, {
  required int planDayId,
  BlockKind kind = BlockKind.single,
  int orderIndex = 0,
  int rounds = 3,
  int restAfterRoundSeconds = 90,
  String? label,
}) {
  return db
      .into(db.planBlocks)
      .insert(
        PlanBlocksCompanion.insert(
          planDayId: planDayId,
          orderIndex: orderIndex,
          kind: kind,
          rounds: Value(rounds),
          restAfterRoundSeconds: Value(restAfterRoundSeconds),
          label: Value(label),
        ),
      );
}

Future<int> insertPlanItem(
  AppDatabase db, {
  required int planBlockId,
  required int exerciseId,
  int orderIndex = 0,
  int? targetReps = 8,
  double? targetWeightKg = 60,
  WeightMode weightMode = WeightMode.baseline,
  double? weightPercent,
  double? weightOffsetKg,
  int? targetDurationSeconds,
  double? targetDistanceMeters,
  double? targetPaceSecPerKm,
}) {
  return db
      .into(db.planItems)
      .insert(
        PlanItemsCompanion.insert(
          planBlockId: planBlockId,
          exerciseId: exerciseId,
          orderIndex: orderIndex,
          targetReps: Value(targetReps),
          targetWeightKg: Value(targetWeightKg),
          weightMode: Value(weightMode),
          weightPercent: Value(weightPercent),
          weightOffsetKg: Value(weightOffsetKg),
          targetDurationSeconds: Value(targetDurationSeconds),
          targetDistanceMeters: Value(targetDistanceMeters),
          targetPaceSecPerKm: Value(targetPaceSecPerKm),
        ),
      );
}

Future<int> insertSession(
  AppDatabase db, {
  int? planId,
  int? planDayId,
  SessionStatus status = SessionStatus.completed,
  DateTime? startedAt,
}) {
  return db
      .into(db.sessions)
      .insert(
        SessionsCompanion.insert(
          planId: Value(planId),
          planDayId: Value(planDayId),
          startedAt: startedAt ?? _defaultTime,
          status: status,
        ),
      );
}

Future<int> insertStrengthSet(
  AppDatabase db, {
  required int sessionId,
  required int exerciseId,
  int? planItemId,
  int groupIndex = 0,
  BlockKind groupKind = BlockKind.single,
  int roundIndex = 0,
  int itemIndex = 0,
  int? plannedReps = 8,
  double? plannedWeightKg = 60,
  int? actualReps = 8,
  double? actualWeightKg = 60,
  bool isWarmup = false,
  EntryStatus status = EntryStatus.completed,
  DateTime? performedAt,
}) {
  return db
      .into(db.strengthSets)
      .insert(
        StrengthSetsCompanion.insert(
          sessionId: sessionId,
          exerciseId: exerciseId,
          planItemId: Value(planItemId),
          groupIndex: groupIndex,
          groupKind: groupKind,
          roundIndex: roundIndex,
          itemIndex: itemIndex,
          plannedReps: Value(plannedReps),
          plannedWeightKg: Value(plannedWeightKg),
          actualReps: Value(actualReps),
          actualWeightKg: Value(actualWeightKg),
          isWarmup: Value(isWarmup),
          status: status,
          performedAt: Value(performedAt ?? _defaultTime),
        ),
      );
}
