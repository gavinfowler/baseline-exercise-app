import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../domain/models/enums.dart';
import '../db/app_database.dart';

/// A plan day with everything under it, assembled for display or execution.
class PlanDayDetail {
  const PlanDayDetail({required this.day, required this.blocks});

  final PlanDayRow day;
  final List<PlanBlockDetail> blocks;
}

class PlanBlockDetail {
  const PlanBlockDetail({required this.block, required this.items});

  final PlanBlockRow block;
  final List<PlanItemRow> items;

  /// Total prescribed efforts in this block: rounds × exercises.
  int get totalEntries => block.rounds * items.length;
}

/// Reads and writes training plans.
class PlanRepository {
  PlanRepository(this._db, {Clock clock = const SystemClock()})
    : _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  // ------------------------------------------------------------------- plans

  Stream<List<PlanRow>> watchAll() {
    return (_db.select(_db.plans)..orderBy([
          (t) => OrderingTerm.desc(t.isActive),
          (t) => OrderingTerm.desc(t.updatedAt),
        ]))
        .watch();
  }

  Future<List<PlanRow>> getAll() {
    return (_db.select(_db.plans)..orderBy([
          (t) => OrderingTerm.desc(t.isActive),
          (t) => OrderingTerm.desc(t.updatedAt),
        ]))
        .get();
  }

  Future<PlanRow?> findById(int id) =>
      (_db.select(_db.plans)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<PlanRow?> watchById(int id) => (_db.select(
    _db.plans,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<PlanRow?> getActivePlan() => (_db.select(
    _db.plans,
  )..where((t) => t.isActive.equals(true))).getSingleOrNull();

  Future<int> createPlan({
    required String name,
    required PlanMode mode,
    ScheduleType scheduleType = ScheduleType.sequential,
    PlanSource source = PlanSource.ui,
    String? description,
    DateTime? startDate,
    int? durationWeeks,
    String? schemaVersion,
  }) {
    final now = _clock.now();
    return _db
        .into(_db.plans)
        .insert(
          PlansCompanion.insert(
            name: name,
            description: Value(description),
            mode: mode,
            scheduleType: scheduleType,
            startDate: Value(startDate),
            durationWeeks: Value(durationWeeks),
            source: source,
            schemaVersion: Value(schemaVersion),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Makes one plan active and every other plan inactive.
  ///
  /// Done in a transaction because "exactly one active plan" is an invariant the
  /// home screen relies on.
  Future<void> setActivePlan(int? planId) async {
    await _db.transaction(() async {
      await _db
          .update(_db.plans)
          .write(const PlansCompanion(isActive: Value(false)));
      if (planId != null) {
        await (_db.update(_db.plans)..where((t) => t.id.equals(planId))).write(
          PlansCompanion(
            isActive: const Value(true),
            updatedAt: Value(_clock.now()),
          ),
        );
      }
    });
  }

  Future<void> renamePlan(int planId, String name) async {
    await (_db.update(_db.plans)..where((t) => t.id.equals(planId))).write(
      PlansCompanion(name: Value(name), updatedAt: Value(_clock.now())),
    );
  }

  /// Removes a plan and, by cascade, its days, blocks and items.
  ///
  /// Sessions already performed against it survive: their plan reference is
  /// nulled, and the prescription snapshots on each logged row keep history
  /// readable.
  Future<void> deletePlan(int planId) async {
    await (_db.delete(_db.plans)..where((t) => t.id.equals(planId))).go();
  }

  // -------------------------------------------------------------------- days

  Future<int> addDay({
    required int planId,
    required String label,
    required int orderIndex,
    int? weekNumber,
    Weekday? dayOfWeek,
    String? notes,
  }) {
    return _db
        .into(_db.planDays)
        .insert(
          PlanDaysCompanion.insert(
            planId: planId,
            orderIndex: orderIndex,
            label: label,
            weekNumber: Value(weekNumber),
            dayOfWeek: Value(dayOfWeek),
            notes: Value(notes),
          ),
        );
  }

  Future<List<PlanDayRow>> getDays(int planId) {
    return (_db.select(_db.planDays)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.weekNumber),
            (t) => OrderingTerm.asc(t.orderIndex),
          ]))
        .get();
  }

  Stream<List<PlanDayRow>> watchDays(int planId) {
    return (_db.select(_db.planDays)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.weekNumber),
            (t) => OrderingTerm.asc(t.orderIndex),
          ]))
        .watch();
  }

  Future<void> deleteDay(int dayId) async {
    await (_db.delete(_db.planDays)..where((t) => t.id.equals(dayId))).go();
  }

  // ------------------------------------------------------------------ blocks

  Future<int> addBlock({
    required int planDayId,
    required int orderIndex,
    BlockKind kind = BlockKind.single,
    String? label,
    int rounds = 3,
    int restBetweenExercisesSeconds = 0,
    int restAfterRoundSeconds = 90,
  }) {
    return _db
        .into(_db.planBlocks)
        .insert(
          PlanBlocksCompanion.insert(
            planDayId: planDayId,
            orderIndex: orderIndex,
            kind: kind,
            label: Value(label),
            rounds: Value(rounds),
            restBetweenExercisesSeconds: Value(restBetweenExercisesSeconds),
            restAfterRoundSeconds: Value(restAfterRoundSeconds),
          ),
        );
  }

  Future<void> updateBlockSettings(
    int blockId, {
    int? rounds,
    int? restBetweenExercisesSeconds,
    int? restAfterRoundSeconds,
    String? label,
  }) async {
    await (_db.update(
      _db.planBlocks,
    )..where((t) => t.id.equals(blockId))).write(
      PlanBlocksCompanion(
        rounds: rounds == null ? const Value.absent() : Value(rounds),
        restBetweenExercisesSeconds: restBetweenExercisesSeconds == null
            ? const Value.absent()
            : Value(restBetweenExercisesSeconds),
        restAfterRoundSeconds: restAfterRoundSeconds == null
            ? const Value.absent()
            : Value(restAfterRoundSeconds),
        label: label == null ? const Value.absent() : Value(label),
      ),
    );
  }

  Future<void> deleteBlock(int blockId) async {
    await (_db.delete(_db.planBlocks)..where((t) => t.id.equals(blockId))).go();
  }

  // ------------------------------------------------------------------- items

  Future<int> addStrengthItem({
    required int planBlockId,
    required int exerciseId,
    required int orderIndex,
    int? targetReps,
    double? targetWeightKg,
    WeightMode weightMode = WeightMode.absolute,
    double? weightOffsetKg,
    double? weightPercent,
    double? rpe,
    String? tempo,
    bool toFailure = false,
    String? notes,
  }) {
    return _db
        .into(_db.planItems)
        .insert(
          PlanItemsCompanion.insert(
            planBlockId: planBlockId,
            exerciseId: exerciseId,
            orderIndex: orderIndex,
            targetReps: Value(targetReps),
            targetWeightKg: Value(targetWeightKg),
            weightMode: Value(weightMode),
            weightOffsetKg: Value(weightOffsetKg),
            weightPercent: Value(weightPercent),
            rpe: Value(rpe),
            tempo: Value(tempo),
            toFailure: Value(toFailure),
            notes: Value(notes),
          ),
        );
  }

  Future<int> addCardioItem({
    required int planBlockId,
    required int exerciseId,
    required int orderIndex,
    int? targetDurationSeconds,
    double? targetDistanceMeters,
    double? targetPaceSecPerKm,
    double? targetInclinePercent,
    int? targetResistanceLevel,
    String? intervalsJson,
    String? notes,
  }) {
    return _db
        .into(_db.planItems)
        .insert(
          PlanItemsCompanion.insert(
            planBlockId: planBlockId,
            exerciseId: exerciseId,
            orderIndex: orderIndex,
            targetDurationSeconds: Value(targetDurationSeconds),
            targetDistanceMeters: Value(targetDistanceMeters),
            targetPaceSecPerKm: Value(targetPaceSecPerKm),
            targetInclinePercent: Value(targetInclinePercent),
            targetResistanceLevel: Value(targetResistanceLevel),
            intervalsJson: Value(intervalsJson),
            notes: Value(notes),
          ),
        );
  }

  Future<void> deleteItem(int itemId) async {
    await (_db.delete(_db.planItems)..where((t) => t.id.equals(itemId))).go();
  }

  // ---------------------------------------------------------------- assembly

  /// Loads a whole day: its blocks, in order, each with its items in order.
  ///
  /// Three queries rather than a join per block, so a day with many blocks does
  /// not turn into a query storm.
  Future<PlanDayDetail?> loadDay(int dayId) async {
    final day = await (_db.select(
      _db.planDays,
    )..where((t) => t.id.equals(dayId))).getSingleOrNull();
    if (day == null) return null;

    final blocks =
        await (_db.select(_db.planBlocks)
              ..where((t) => t.planDayId.equals(dayId))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();
    if (blocks.isEmpty) return PlanDayDetail(day: day, blocks: const []);

    final blockIds = blocks.map((b) => b.id).toList();
    final items =
        await (_db.select(_db.planItems)
              ..where((t) => t.planBlockId.isIn(blockIds))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();

    return PlanDayDetail(
      day: day,
      blocks: [
        for (final block in blocks)
          PlanBlockDetail(
            block: block,
            items: items.where((i) => i.planBlockId == block.id).toList(),
          ),
      ],
    );
  }

  /// Every day of a plan, fully loaded.
  Future<List<PlanDayDetail>> loadPlanDays(int planId) async {
    final days = await getDays(planId);
    final details = <PlanDayDetail>[];
    for (final day in days) {
      final detail = await loadDay(day.id);
      if (detail != null) details.add(detail);
    }
    return details;
  }
}
