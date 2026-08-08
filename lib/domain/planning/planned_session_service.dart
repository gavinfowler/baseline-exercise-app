import 'package:collection/collection.dart';

import '../../core/time/clock.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/baseline_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../models/enums.dart';
import '../progression/prescription_resolver.dart';

/// Starts a workout from a plan.
///
/// This is what makes a plan more than a document: it decides which workout is
/// due, and turns that workout's prescription into the pending entries the
/// workout screen shows, so the session opens with the work already laid out
/// instead of empty.
class PlannedSessionService {
  PlannedSessionService({
    required PlanRepository plans,
    required SessionRepository sessions,
    required BaselineRepository baselines,
    required ExerciseRepository exercises,
    Clock clock = const SystemClock(),
  }) : _plans = plans,
       _sessions = sessions,
       _baselines = baselines,
       _exercises = exercises,
       _clock = clock;

  final PlanRepository _plans;
  final SessionRepository _sessions;
  final BaselineRepository _baselines;
  final ExerciseRepository _exercises;
  final Clock _clock;

  /// The workout this plan says to do next, or null if it has no workouts yet.
  Future<PlanDayRow?> nextDay(PlanRow plan) async {
    final days = await _plans.getDays(plan.id);
    if (days.isEmpty) return null;

    // A weekly plan names the day it wants. If one is pinned to today, that is
    // the answer whatever was done last — "every Monday" means Monday, not
    // "one after the previous".
    if (plan.scheduleType == ScheduleType.weekly) {
      final today = _clock.now().weekday;
      final match = days.firstWhereOrNull(
        (d) => d.dayOfWeek?.dateTimeWeekday == today,
      );
      if (match != null) return match;
    }

    // Otherwise rotate past whatever was completed last, wrapping at the end so
    // a plan that has been worked through starts again rather than stopping
    // dead. An unknown or missing last day gives -1, so the rotation begins at
    // the first workout.
    final last = await _sessions.lastCompletedForPlan(plan.id);
    final previous = last == null
        ? -1
        : days.indexWhere((d) => d.id == last.planDayId);
    return days[(previous + 1) % days.length];
  }

  /// Starts [day] and writes everything it prescribes as pending entries.
  ///
  /// Returns the new session id. Entries are `pending`, not `completed`: they
  /// are what the user is about to do, and `completeSession` turns whatever is
  /// left into `skipped`.
  ///
  /// The prescription is snapshotted onto each row rather than read back
  /// through [PlanItemRow] later, so editing or deleting the plan afterwards
  /// cannot rewrite what a finished session says it asked for.
  Future<int> start({required PlanRow plan, required PlanDayRow day}) async {
    final detail = await _plans.loadDay(day.id);

    final sessionId = await _sessions.startSession(
      planId: plan.id,
      planDayId: day.id,
      title: day.label,
    );
    if (detail == null) return sessionId;

    // Archived exercises are included: a plan can legitimately reference one,
    // and dropping it would silently shorten the workout.
    final byId = {
      for (final e in await _exercises.getAll(includeArchived: true)) e.id: e,
    };

    for (var groupIndex = 0; groupIndex < detail.blocks.length; groupIndex++) {
      final block = detail.blocks[groupIndex];

      for (var itemIndex = 0; itemIndex < block.items.length; itemIndex++) {
        final item = block.items[itemIndex];
        final isCardio = byId[item.exerciseId]?.type == ExerciseType.cardio;

        // Resolved once per item rather than once per round: every round of a
        // block prescribes the same thing, and the baseline cannot move
        // mid-session.
        final plannedWeightKg = isCardio
            ? null
            : await _resolveWeightKg(plan, item);

        for (var round = 0; round < block.block.rounds; round++) {
          if (isCardio) {
            await _sessions.addCardioEntry(
              sessionId: sessionId,
              exerciseId: item.exerciseId,
              groupIndex: groupIndex,
              roundIndex: round,
              itemIndex: itemIndex,
              groupKind: block.block.kind,
              groupLabel: block.block.label,
              planItemId: item.id,
              plannedDurationSeconds: item.targetDurationSeconds,
              plannedDistanceMeters: item.targetDistanceMeters,
              plannedPaceSecPerKm: item.targetPaceSecPerKm,
              status: EntryStatus.pending,
            );
          } else {
            await _sessions.addStrengthSet(
              sessionId: sessionId,
              exerciseId: item.exerciseId,
              groupIndex: groupIndex,
              roundIndex: round,
              itemIndex: itemIndex,
              groupKind: block.block.kind,
              groupLabel: block.block.label,
              planItemId: item.id,
              plannedReps: item.targetReps,
              plannedWeightKg: plannedWeightKg,
              status: EntryStatus.pending,
            );
          }
        }
      }
    }

    return sessionId;
  }

  /// The weight this item prescribes today.
  ///
  /// Only a static plan consults a baseline; a periodized plan's numbers are
  /// fixed for the life of the program, so it reads its own targets.
  Future<double?> _resolveWeightKg(PlanRow plan, PlanItemRow item) async {
    final reps = item.targetReps;
    final usesBaseline =
        plan.mode == PlanMode.staticPlan && itemUsesBaseline(item);

    final baseline = (usesBaseline && reps != null)
        ? await _baselines.find(
            planId: plan.id,
            exerciseId: item.exerciseId,
            reps: reps,
          )
        : null;

    return resolvePrescribedWeightKg(
      item: item,
      baselineWeightKg: baseline?.weightKg,
    );
  }
}
