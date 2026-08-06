import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/plan_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/run_segment.dart';
import '../session/exercise_picker.dart';
import 'plan_item_editor_sheet.dart';

/// Edits one day of a plan: its blocks, and the exercises inside them.
class PlanDayEditorScreen extends ConsumerWidget {
  const PlanDayEditorScreen({required this.plan, required this.day, super.key});

  final PlanRow plan;
  final PlanDayRow day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(planDayDetailProvider(day.id));

    return Scaffold(
      appBar: AppBar(title: Text(day.label)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addBlock(context, ref, detail.value),
        icon: const Icon(Icons.add),
        label: const Text('Block'),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (loaded) {
          if (loaded == null || loaded.blocks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No blocks yet.\n\n'
                  'A block is one exercise, or several performed back to back '
                  'as a superset.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final block in loaded.blocks)
                _BlockCard(plan: plan, block: block),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addBlock(
    BuildContext context,
    WidgetRef ref,
    PlanDayDetail? detail,
  ) async {
    final kind = await showDialog<BlockKind>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add a block'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(BlockKind.single),
            child: const ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('Single exercise'),
              subtitle: Text('Straight sets of one movement'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(BlockKind.superset),
            child: const ListTile(
              leading: Icon(Icons.swap_calls),
              title: Text('Superset'),
              subtitle: Text('Two or more exercises back to back'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(BlockKind.circuit),
            child: const ListTile(
              leading: Icon(Icons.loop),
              title: Text('Circuit'),
              subtitle: Text('Several exercises, endurance style'),
            ),
          ),
        ],
      ),
    );
    if (kind == null) return;

    await ref
        .read(planRepositoryProvider)
        .addBlock(
          planDayId: day.id,
          orderIndex: detail?.blocks.length ?? 0,
          kind: kind,
        );
    ref.read(planEditRevisionProvider.notifier).bump();
  }
}

class _BlockCard extends ConsumerWidget {
  const _BlockCard({required this.plan, required this.block});

  final PlanRow plan;
  final PlanBlockDetail block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(exercisesByIdProvider);
    final formatter = ref.watch(unitFormatterProvider);
    final theme = Theme.of(context);
    final repo = ref.read(planRepositoryProvider);

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
                    block.block.kind.label,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete block',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await repo.deleteBlock(block.block.id);
                    ref.read(planEditRevisionProvider.notifier).bump();
                  },
                ),
              ],
            ),
            Text(
              '${block.block.rounds} round'
              '${block.block.rounds == 1 ? '' : 's'}'
              ' · rest ${UnitFormatter.formatDuration(block.block.restAfterRoundSeconds)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            if (block.items.isEmpty)
              Text(
                'No exercises in this block yet.',
                style: theme.textTheme.bodySmall,
              )
            else
              for (final item in block.items)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(byId[item.exerciseId]?.name ?? 'Exercise'),
                  subtitle: Text(_describe(item, formatter)),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      await repo.deleteItem(item.id);
                      ref.read(planEditRevisionProvider.notifier).bump();
                    },
                  ),
                  onTap: () => _editItem(context, ref, item),
                ),

            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _addExercise(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Exercise'),
                ),
                TextButton.icon(
                  onPressed: () => _editBlockSettings(context, ref),
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Rounds & rest'),
                ),
              ],
            ),

            if (block.block.kind.isGrouped && block.items.length < 2)
              Text(
                'A ${block.block.kind.label.toLowerCase()} needs at least two '
                'exercises.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _describe(PlanItemRow item, UnitFormatter formatter) {
    if (item.targetReps != null || item.targetWeightKg != null) {
      final parts = <String>[
        if (item.targetReps != null) '${item.targetReps} reps',
        if (item.weightMode == WeightMode.baseline)
          'at your current baseline'
        else if (item.weightMode == WeightMode.baselinePercent)
          '${item.weightPercent?.round()}% of baseline'
        else if (item.weightMode == WeightMode.baselinePlus)
          'baseline + ${formatter.formatWeight(item.weightOffsetKg ?? 0)}'
        else if (item.targetWeightKg != null)
          formatter.formatWeight(item.targetWeightKg!),
      ];
      return parts.join(' · ');
    }

    // A structured workout describes itself; its totals are already mirrored
    // onto the target fields, so showing both would just repeat.
    final workout = RunWorkout.decode(item.intervalsJson);
    if (workout.isNotEmpty) {
      return 'Structured · ${workout.describe(formatter)}';
    }

    final parts = <String>[
      if (item.targetDurationSeconds != null)
        UnitFormatter.formatDuration(item.targetDurationSeconds!),
      if (item.targetDistanceMeters != null)
        formatter.formatDistance(item.targetDistanceMeters!),
      if (item.targetPaceSecPerKm != null)
        formatter.formatPace(item.targetPaceSecPerKm!),
    ];
    return parts.isEmpty ? 'No prescription set' : parts.join(' · ');
  }

  Future<void> _addExercise(BuildContext context, WidgetRef ref) async {
    final exercise = await pickExercise(context);
    if (exercise == null || !context.mounted) return;

    final result = await showPlanItemEditor(
      context,
      exercise: exercise,
      planMode: plan.mode,
      formatter: ref.read(unitFormatterProvider),
    );
    if (result == null) return;

    final repo = ref.read(planRepositoryProvider);
    if (exercise.type == ExerciseType.cardio) {
      await repo.addCardioItem(
        planBlockId: block.block.id,
        exerciseId: exercise.id,
        orderIndex: block.items.length,
        targetDurationSeconds: result.durationSeconds,
        targetDistanceMeters: result.distanceMeters,
        targetPaceSecPerKm: result.paceSecPerKm,
        intervalsJson: result.intervalsJson,
      );
    } else {
      await repo.addStrengthItem(
        planBlockId: block.block.id,
        exerciseId: exercise.id,
        orderIndex: block.items.length,
        targetReps: result.reps,
        targetWeightKg: result.weightKg,
        weightMode: result.weightMode,
        weightOffsetKg: result.weightOffsetKg,
        weightPercent: result.weightPercent,
      );
    }
    ref.read(planEditRevisionProvider.notifier).bump();
  }

  /// Editing replaces the item, which keeps the write path identical to adding
  /// one and avoids a second set of partial-update branches.
  Future<void> _editItem(
    BuildContext context,
    WidgetRef ref,
    PlanItemRow item,
  ) async {
    final exercise = ref.read(exercisesByIdProvider)[item.exerciseId];
    if (exercise == null) return;

    final result = await showPlanItemEditor(
      context,
      exercise: exercise,
      planMode: plan.mode,
      formatter: ref.read(unitFormatterProvider),
      existing: item,
    );
    if (result == null) return;

    final repo = ref.read(planRepositoryProvider);
    await repo.deleteItem(item.id);
    if (exercise.type == ExerciseType.cardio) {
      await repo.addCardioItem(
        planBlockId: block.block.id,
        exerciseId: exercise.id,
        orderIndex: item.orderIndex,
        targetDurationSeconds: result.durationSeconds,
        targetDistanceMeters: result.distanceMeters,
        targetPaceSecPerKm: result.paceSecPerKm,
        intervalsJson: result.intervalsJson,
      );
    } else {
      await repo.addStrengthItem(
        planBlockId: block.block.id,
        exerciseId: exercise.id,
        orderIndex: item.orderIndex,
        targetReps: result.reps,
        targetWeightKg: result.weightKg,
        weightMode: result.weightMode,
        weightOffsetKg: result.weightOffsetKg,
        weightPercent: result.weightPercent,
      );
    }
    ref.read(planEditRevisionProvider.notifier).bump();
  }

  Future<void> _editBlockSettings(BuildContext context, WidgetRef ref) async {
    final rounds = TextEditingController(text: block.block.rounds.toString());
    final rest = TextEditingController(
      text: block.block.restAfterRoundSeconds.toString(),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rounds & rest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rounds,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rounds (sets)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rest,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rest after each round (seconds)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;

    // Blocks are replaced rather than patched, for the same reason items are.
    final repo = ref.read(planRepositoryProvider);
    final newRounds = int.tryParse(rounds.text.trim()) ?? block.block.rounds;
    final newRest =
        int.tryParse(rest.text.trim()) ?? block.block.restAfterRoundSeconds;

    await repo.updateBlockSettings(
      block.block.id,
      rounds: newRounds,
      restAfterRoundSeconds: newRest,
    );
    ref.read(planEditRevisionProvider.notifier).bump();
  }
}
