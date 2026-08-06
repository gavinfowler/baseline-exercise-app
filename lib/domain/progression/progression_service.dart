import '../../core/time/clock.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/baseline_repository.dart';
import '../../data/repositories/personal_record_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../models/enums.dart';

/// A baseline that went up as a result of a session.
class BaselinePromotion {
  const BaselinePromotion({
    required this.exerciseId,
    required this.reps,
    required this.previousWeightKg,
    required this.newWeightKg,
  });

  final int exerciseId;
  final int reps;

  /// Null when this is the first baseline recorded for the exercise.
  final double? previousWeightKg;
  final double newWeightKg;
}

/// What a finished session changed.
class ProgressionOutcome {
  const ProgressionOutcome({
    this.promotions = const [],
    this.records = const [],
  });

  /// Empty for periodized plans, always.
  final List<BaselinePromotion> promotions;

  final List<NewRecord> records;

  bool get hasChanges => promotions.isNotEmpty || records.isNotEmpty;
}

/// Applies progression rules once a session is finished.
///
/// The two plan modes differ in exactly one respect, and it is the whole point
/// of the app:
///
///   * a **static** plan raises its baseline when you beat the prescription, so
///     the plan tracks you upward;
///   * a **periodized** plan never changes — the result is recorded as a
///     personal record and the prescribed numbers stay as written.
///
/// Personal records are captured either way.
class ProgressionService {
  ProgressionService({
    required SessionRepository sessions,
    required PlanRepository plans,
    required BaselineRepository baselines,
    required PersonalRecordRepository records,
    Clock clock = const SystemClock(),
  }) : _sessions = sessions,
       _plans = plans,
       _baselines = baselines,
       _records = records,
       _clock = clock;

  final SessionRepository _sessions;
  final PlanRepository _plans;
  final BaselineRepository _baselines;
  final PersonalRecordRepository _records;
  final Clock _clock;

  /// Processes a completed session.
  ///
  /// Safe to call for ad-hoc sessions too: without a plan there is nothing to
  /// promote, but personal records are still recorded.
  Future<ProgressionOutcome> applyForSession(int sessionId) async {
    final session = await _sessions.findById(sessionId);
    if (session == null) return const ProgressionOutcome();

    final plan = session.planId == null
        ? null
        : await _plans.findById(session.planId!);

    final strengthSets = await _sessions.getStrengthSets(sessionId);
    final cardioEntries = await _sessions.getCardioEntries(sessionId);

    final records = <NewRecord>[
      ...await _recordStrengthPrs(strengthSets, sessionId),
      ...await _recordCardioPrs(cardioEntries, sessionId),
    ];

    // Only a static plan promotes. This branch is the entire behavioural
    // difference between the two planning modes.
    final promotions = plan != null && plan.mode == PlanMode.staticPlan
        ? await _promoteBaselines(plan.id, strengthSets)
        : const <BaselinePromotion>[];

    return ProgressionOutcome(promotions: promotions, records: records);
  }

  /// Raises baselines for sets that met the prescription at a heavier weight.
  ///
  /// The promotion rule is "heaviest weight completed **at the prescribed rep
  /// count**", so a set that fell short of its target reps never promotes, no
  /// matter how heavy it was.
  Future<List<BaselinePromotion>> _promoteBaselines(
    int planId,
    List<StrengthSetRow> sets,
  ) async {
    final promotions = <BaselinePromotion>[];
    final now = _clock.now();

    for (final set in sets) {
      if (!_countsTowardProgression(set)) continue;

      final plannedReps = set.plannedReps;
      final actualReps = set.actualReps;
      final weight = set.actualWeightKg;

      // Ad-hoc sets inside a planned session have no prescription to beat.
      if (plannedReps == null || actualReps == null || weight == null) continue;

      // Falling short of the target reps is not a promotion.
      if (actualReps < plannedReps) continue;

      final result = await _baselines.raiseIfHeavier(
        planId: planId,
        exerciseId: set.exerciseId,
        reps: plannedReps,
        weightKg: weight,
        achievedAt: now,
        sourceSetId: set.id,
      );
      if (!result.raised) continue;

      promotions.add(
        BaselinePromotion(
          exerciseId: set.exerciseId,
          reps: plannedReps,
          previousWeightKg: result.previousWeightKg,
          newWeightKg: weight,
        ),
      );
    }

    return promotions;
  }

  Future<List<NewRecord>> _recordStrengthPrs(
    List<StrengthSetRow> sets,
    int sessionId,
  ) async {
    final found = <NewRecord>[];
    final now = _clock.now();

    for (final set in sets) {
      if (!_countsTowardProgression(set)) continue;

      final reps = set.actualReps;
      final weight = set.actualWeightKg;
      if (reps == null || weight == null || reps <= 0) continue;

      final candidates = <Future<NewRecord?>>[
        _records.recordIfBetter(
          exerciseId: set.exerciseId,
          recordType: RecordType.maxWeightAtReps,
          reps: reps,
          value: weight,
          achievedAt: now,
          sessionId: sessionId,
        ),
        _records.recordIfBetter(
          exerciseId: set.exerciseId,
          recordType: RecordType.maxWeight,
          value: weight,
          achievedAt: now,
          sessionId: sessionId,
        ),
        _records.recordIfBetter(
          exerciseId: set.exerciseId,
          recordType: RecordType.estimatedOneRepMax,
          value: Units.estimatedOneRepMax(weightKg: weight, reps: reps),
          achievedAt: now,
          sessionId: sessionId,
        ),
      ];

      for (final candidate in candidates) {
        final record = await candidate;
        if (record != null) found.add(record);
      }
    }

    return found;
  }

  Future<List<NewRecord>> _recordCardioPrs(
    List<CardioEntryRow> entries,
    int sessionId,
  ) async {
    final found = <NewRecord>[];
    final now = _clock.now();

    for (final entry in entries) {
      if (entry.status != EntryStatus.completed) continue;

      final duration = entry.actualDurationSeconds;
      final distance = entry.actualDistanceMeters;
      final pace = entry.actualPaceSecPerKm;

      final candidates = <Future<NewRecord?>>[
        if (duration != null && duration > 0)
          _records.recordIfBetter(
            exerciseId: entry.exerciseId,
            recordType: RecordType.longestDuration,
            value: duration.toDouble(),
            achievedAt: now,
            sessionId: sessionId,
          ),
        if (distance != null && distance > 0)
          _records.recordIfBetter(
            exerciseId: entry.exerciseId,
            recordType: RecordType.longestDistance,
            value: distance,
            achievedAt: now,
            sessionId: sessionId,
          ),
        if (pace != null && pace > 0)
          _records.recordIfBetter(
            exerciseId: entry.exerciseId,
            recordType: RecordType.bestPace,
            value: pace,
            achievedAt: now,
            sessionId: sessionId,
          ),
      ];

      for (final candidate in candidates) {
        final record = await candidate;
        if (record != null) found.add(record);
      }
    }

    return found;
  }

  /// Warm-ups and anything not actually completed are excluded from both
  /// promotion and records.
  bool _countsTowardProgression(StrengthSetRow set) =>
      set.status == EntryStatus.completed && !set.isWarmup;

  /// Establishes starting baselines when a static plan is first imported or
  /// created, so day one prescribes real numbers.
  ///
  /// Never overwrites a baseline that already exists — re-importing a plan must
  /// not undo progress the user has made.
  Future<void> seedBaselines(int planId) async {
    final plan = await _plans.findById(planId);
    if (plan == null || plan.mode != PlanMode.staticPlan) return;

    final now = _clock.now();
    for (final day in await _plans.loadPlanDays(planId)) {
      for (final block in day.blocks) {
        for (final item in block.items) {
          final reps = item.targetReps;
          final weight = item.targetWeightKg;
          if (reps == null || weight == null) continue;

          final existing = await _baselines.find(
            planId: planId,
            exerciseId: item.exerciseId,
            reps: reps,
          );
          if (existing != null) continue;

          await _baselines.set(
            planId: planId,
            exerciseId: item.exerciseId,
            reps: reps,
            weightKg: weight,
            achievedAt: now,
          );
        }
      }
    }
  }
}
