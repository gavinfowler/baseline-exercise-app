import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../branding/baseline_logo.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/session_group.dart';
import '../ads/ad_slot.dart';
import '../cardio/cardio_card.dart';
import '../rest_timer/rest_timer_bar.dart';
import '../rest_timer/rest_timer_controller.dart';
import '../shell/app_drawer.dart';
import 'exercise_picker.dart';
import 'exercise_type_picker.dart';
import 'set_entry_dialog.dart';

/// The workout tab: start a session, log strength sets and cardio, finish.
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSessionProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          if (active.value != null)
            TextButton(
              onPressed: () => _finish(context, ref, active.value!.id),
              child: const Text('Finish'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: active.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (session) => session == null
                  ? const _NoActiveSession()
                  : _ActiveSession(session: session),
            ),
          ),
          const RestTimerBar(),
          const AdSlot(),
        ],
      ),
      floatingActionButton: active.value == null
          ? null
          : FloatingActionButton.extended(
              // See the note in ExerciseCatalogScreen: tabs share a Hero
              // subtree.
              heroTag: 'workout-fab',
              onPressed: () => _addExercise(context, ref, active.value!.id),
              icon: const Icon(Icons.add),
              label: const Text('Exercise'),
            ),
    );
  }

  /// Adds an exercise to the session.
  ///
  /// The discipline is chosen first and then filters the picker, rather than
  /// being inferred from whichever exercise was tapped. Cardio and strength
  /// create entirely different kinds of entry, and the user should be the one
  /// deciding which.
  Future<void> _addExercise(
    BuildContext context,
    WidgetRef ref,
    int sessionId,
  ) async {
    final type = await pickExerciseType(context);
    if (type == null || !context.mounted) return;

    final exercise = await pickExercise(context, type: type);
    if (exercise == null) return;

    final repo = ref.read(sessionRepositoryProvider);
    final groupIndex = await repo.nextGroupIndex(sessionId);

    if (type == ExerciseType.cardio) {
      await repo.addCardioEntry(
        sessionId: sessionId,
        exerciseId: exercise.id,
        groupIndex: groupIndex,
      );
    } else {
      // Seed the block with one pending set so it appears immediately and the
      // user has something to tap.
      await repo.addStrengthSet(
        sessionId: sessionId,
        exerciseId: exercise.id,
        groupIndex: groupIndex,
        roundIndex: 0,
        status: EntryStatus.pending,
      );
    }
  }

  Future<void> _finish(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish workout?'),
        content: const Text(
          'Anything you have not logged will be recorded as skipped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(sessionRepositoryProvider).completeSession(id);
    ref.read(restTimerProvider.notifier).stop();
    ref.read(timedCardioEntryProvider.notifier).clear();

    // Baseline promotion and personal records are applied once, here, after the
    // session is closed — never mid-workout, where an edited set would promote
    // twice.
    final outcome = await ref
        .read(progressionServiceProvider)
        .applyForSession(id);
    if (!context.mounted || !outcome.hasChanges) return;

    final byId = ref.read(exercisesByIdProvider);
    final formatter = ref.read(unitFormatterProvider);

    final messages = <String>[
      for (final promotion in outcome.promotions)
        'New baseline: ${byId[promotion.exerciseId]?.name ?? 'exercise'} '
            '${formatter.formatWeight(promotion.newWeightKg)}'
            ' × ${promotion.reps}',
      if (outcome.records.isNotEmpty)
        '${outcome.records.length} personal record'
            '${outcome.records.length == 1 ? '' : 's'} set',
    ];

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messages.join('\n'))));
  }
}

class _NoActiveSession extends ConsumerWidget {
  const _NoActiveSession();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Null while it loads, which is the same as "nothing planned" as far as
    // this screen is concerned: the empty-session button is always offered, so
    // there is nothing to wait for.
    final planned = ref.watch(nextPlannedWorkoutProvider).value;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BaselineLogo(size: 72),
            const SizedBox(height: 16),
            Text('No workout in progress', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              planned == null
                  ? 'Start an empty session and add exercises as you go.'
                  : 'Up next in ${planned.plan.name}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (planned == null)
              FilledButton.icon(
                onPressed: () =>
                    ref.read(sessionRepositoryProvider).startSession(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start workout'),
              )
            else ...[
              // The planned workout is the primary action and the empty one
              // steps down to a text button: with a plan active, starting from
              // it is the normal thing to do.
              FilledButton.icon(
                onPressed: () => ref
                    .read(plannedSessionServiceProvider)
                    .start(plan: planned.plan, day: planned.day),
                icon: const Icon(Icons.play_arrow),
                label: Text('Start ${planned.day.label}'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(sessionRepositoryProvider).startSession(),
                child: const Text('Start an empty session instead'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveSession extends ConsumerWidget {
  const _ActiveSession({required this.session});

  final SessionRow session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(sessionStrengthSetsProvider(session.id));
    final cardio = ref.watch(sessionCardioEntriesProvider(session.id));

    if (sets.isLoading || cardio.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final strengthGroups = groupStrengthSets(sets.value ?? const []);
    final cardioEntries = cardio.value ?? const <CardioEntryRow>[];

    if (strengthGroups.isEmpty && cardioEntries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Workout started.\nAdd your first exercise below.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Both kinds share one group-index sequence, so merging on it preserves the
    // order the user actually added things in.
    final items = <({int groupIndex, Widget widget})>[
      for (final group in strengthGroups)
        (
          groupIndex: group.groupIndex,
          widget: _StrengthGroupCard(sessionId: session.id, group: group),
        ),
      for (final entry in cardioEntries)
        (groupIndex: entry.groupIndex, widget: CardioCard(entry: entry)),
    ]..sort((a, b) => a.groupIndex.compareTo(b.groupIndex));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      itemBuilder: (context, i) => items[i].widget,
    );
  }
}

class _StrengthGroupCard extends ConsumerWidget {
  const _StrengthGroupCard({required this.sessionId, required this.group});

  final int sessionId;
  final SessionGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(exercisesByIdProvider);
    final formatter = ref.watch(unitFormatterProvider);

    final title = group.exerciseIds
        .map((id) => byId[id]?.name ?? 'Exercise $id')
        .join(' + ');

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (group.isSuperset)
                  Chip(
                    label: Text(group.kind.label),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final set in group.sets)
              _SetRow(
                set: set,
                exerciseName: byId[set.exerciseId]?.name ?? 'Exercise',
                formatter: formatter,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addSet(ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add set'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSet(WidgetRef ref) async {
    final repo = ref.read(sessionRepositoryProvider);
    final roundIndex = await repo.nextRoundIndex(sessionId, group.groupIndex);

    await repo.addStrengthSet(
      sessionId: sessionId,
      exerciseId: group.exerciseIds.first,
      groupIndex: group.groupIndex,
      groupKind: group.kind,
      groupLabel: group.label,
      roundIndex: roundIndex,
      status: EntryStatus.pending,
    );
  }
}

class _SetRow extends ConsumerWidget {
  const _SetRow({
    required this.set,
    required this.exerciseName,
    required this.formatter,
  });

  final StrengthSetRow set;
  final String exerciseName;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = set.status == EntryStatus.completed;
    final skipped = set.status == EntryStatus.skipped;
    final theme = Theme.of(context);

    final String label;
    if (done) {
      final weight = formatter.formatWeight(set.actualWeightKg ?? 0);
      label = '$weight × ${set.actualReps} reps';
    } else {
      label = skipped ? 'Skipped' : 'Not logged';
    }

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: done
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Text('${set.roundIndex + 1}', style: theme.textTheme.labelSmall),
      ),
      title: Text(
        label,
        style: skipped
            ? theme.textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.disabledColor,
              )
            : null,
      ),
      subtitle: set.isWarmup ? const Text('Warm-up') : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: done ? 'Edit' : 'Log set',
            icon: Icon(done ? Icons.edit_outlined : Icons.check),
            onPressed: () => _log(context, ref),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close),
            onPressed: () =>
                ref.read(sessionRepositoryProvider).deleteStrengthSet(set.id),
          ),
        ],
      ),
    );
  }

  Future<void> _log(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(sessionRepositoryProvider);

    // Prefill from this set if it already has values, otherwise from the last
    // time this exercise was trained.
    double? weight = set.actualWeightKg ?? set.plannedWeightKg;
    int? reps = set.actualReps ?? set.plannedReps;
    if (weight == null || reps == null) {
      final previous = await repo.lastCompletedSet(set.exerciseId);
      weight ??= previous?.actualWeightKg;
      reps ??= previous?.actualReps;
    }
    if (!context.mounted) return;

    final result = await showSetEntryDialog(
      context,
      exerciseName: exerciseName,
      formatter: formatter,
      initialWeight: weight == null ? null : formatter.weightValue(weight),
      initialReps: reps,
      initialWarmup: set.isWarmup,
    );
    if (result == null) return;

    await repo.completeStrengthSet(
      set.id,
      actualReps: result.reps,
      actualWeightKg: formatter.weightToKg(result.weight),
    );
    await repo.updateStrengthSet(set.id, isWarmup: Value(result.isWarmup));

    // Warm-ups do not start a rest countdown; they are not the working set.
    if (result.isWarmup) return;
    final rest = await ref.read(defaultRestSecondsProvider.future);
    ref.read(restTimerProvider.notifier).start(rest, label: exerciseName);
  }
}
