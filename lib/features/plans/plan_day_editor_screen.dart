import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/plan_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/run_segment.dart';
import '../session/exercise_picker.dart';
import '../session/exercise_type_picker.dart';
import 'cardio_item_screen.dart';
import 'strength_item_screen.dart';

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
        heroTag: 'plan-day-editor-fab',
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

  /// Adds a block, together with the first exercise in it.
  ///
  /// The two are one step because a block with nothing in it prescribes nothing
  /// — and doing it this way is what lets the block type settle the discipline
  /// up front, so the exercise picker is already filtered when it opens.
  Future<void> _addBlock(
    BuildContext context,
    WidgetRef ref,
    PlanDayDetail? detail,
  ) async {
    final choice = await _pickBlockType(context);
    if (choice == null || !context.mounted) return;

    final exercise = await pickExercise(context, type: choice.type);
    if (exercise == null || !context.mounted) return;

    final prescription = await _prescribe(
      context,
      ref,
      exercise: exercise,
      planMode: plan.mode,
    );
    if (prescription == null) return;

    // Written only now, so backing out of the picker or the prescription leaves
    // no empty block behind.
    final repo = ref.read(planRepositoryProvider);
    final blockId = await repo.addBlock(
      planDayId: day.id,
      orderIndex: detail?.blocks.length ?? 0,
      kind: choice.kind,
    );
    await _writeItem(
      repo,
      planBlockId: blockId,
      exerciseId: exercise.id,
      orderIndex: 0,
      prescription: prescription,
    );
    ref.read(planEditRevisionProvider.notifier).bump();
  }
}

/// The block shapes offered when adding one.
///
/// Cardio is a block type of its own rather than a discipline chosen afterwards:
/// it is what the user is setting out to add, and it decides everything that
/// follows. The block kind stored is still `single` — the schema has no cardio
/// kind, and a block's discipline is derived from the exercises in it.
Future<({BlockKind kind, ExerciseType type})?> _pickBlockType(
  BuildContext context,
) {
  return showDialog<({BlockKind kind, ExerciseType type})>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Add a block'),
      children: [
        for (final option in const [
          (
            kind: BlockKind.single,
            type: ExerciseType.strength,
            icon: Icons.fitness_center,
            title: 'Single exercise',
            subtitle: 'Straight sets of one movement',
          ),
          (
            kind: BlockKind.superset,
            type: ExerciseType.strength,
            icon: Icons.swap_calls,
            title: 'Superset',
            subtitle: 'Two or more exercises back to back',
          ),
          (
            kind: BlockKind.circuit,
            type: ExerciseType.strength,
            icon: Icons.loop,
            title: 'Circuit',
            subtitle: 'Several exercises, endurance style',
          ),
          (
            kind: BlockKind.single,
            type: ExerciseType.cardio,
            icon: Icons.directions_run,
            title: 'Cardio',
            subtitle: 'A run, ride or row — steady or structured',
          ),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.of(
              context,
            ).pop((kind: option.kind, type: option.type)),
            child: ListTile(
              leading: Icon(option.icon),
              title: Text(option.title),
              subtitle: Text(option.subtitle),
            ),
          ),
      ],
    ),
  );
}

/// One prescription, of whichever discipline the exercise belongs to.
///
/// Exactly one side is ever set. This exists so the "which editor, then which
/// repository call" branch is written once rather than at each of the three
/// call sites that need it.
class _Prescription {
  const _Prescription.strength(StrengthItemResult this.strength)
    : cardio = null;
  const _Prescription.cardio(CardioItemResult this.cardio) : strength = null;

  final StrengthItemResult? strength;
  final CardioItemResult? cardio;
}

/// Opens the editor matching the exercise's discipline.
Future<_Prescription?> _prescribe(
  BuildContext context,
  WidgetRef ref, {
  required ExerciseRow exercise,
  required PlanMode planMode,
  PlanItemRow? existing,
}) async {
  final formatter = ref.read(unitFormatterProvider);

  if (exercise.type == ExerciseType.cardio) {
    final result = await showCardioItemEditor(
      context,
      exercise: exercise,
      formatter: formatter,
      existing: existing,
    );
    return result == null ? null : _Prescription.cardio(result);
  }

  final result = await showStrengthItemEditor(
    context,
    exercise: exercise,
    planMode: planMode,
    formatter: formatter,
    existing: existing,
  );
  return result == null ? null : _Prescription.strength(result);
}

Future<void> _writeItem(
  PlanRepository repo, {
  required int planBlockId,
  required int exerciseId,
  required int orderIndex,
  required _Prescription prescription,
}) async {
  final cardio = prescription.cardio;
  if (cardio != null) {
    await repo.addCardioItem(
      planBlockId: planBlockId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      targetDurationSeconds: cardio.durationSeconds,
      targetDistanceMeters: cardio.distanceMeters,
      targetPaceSecPerKm: cardio.paceSecPerKm,
      targetInclinePercent: cardio.inclinePercent,
      targetResistanceLevel: cardio.resistanceLevel,
      intervalsJson: cardio.intervalsJson,
    );
    return;
  }

  final strength = prescription.strength!;
  await repo.addStrengthItem(
    planBlockId: planBlockId,
    exerciseId: exerciseId,
    orderIndex: orderIndex,
    targetReps: strength.reps,
    targetWeightKg: strength.weightKg,
    weightMode: strength.weightMode,
    weightOffsetKg: strength.weightOffsetKg,
    weightPercent: strength.weightPercent,
  );
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
                  child: Text(switch (_blockType(byId)) {
                    ExerciseType.cardio => '${block.block.kind.label} · Cardio',
                    ExerciseType.strength =>
                      '${block.block.kind.label} · Strength',
                    null => block.block.kind.label,
                  }, style: theme.textTheme.titleSmall),
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
                  leading: Icon(
                    iconForExerciseType(
                      byId[item.exerciseId]?.type ?? ExerciseType.strength,
                    ),
                    size: 20,
                  ),
                  title: Text(byId[item.exerciseId]?.name ?? 'Exercise'),
                  subtitle: Text(
                    _describe(item, byId[item.exerciseId]?.type, formatter),
                  ),
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

  /// Summarises one item.
  ///
  /// Driven by the exercise's own type rather than by which columns happen to be
  /// non-null. Sniffing nullability sent an unprescribed strength item down the
  /// cardio branch, where it was described in terms that never applied to it.
  String _describe(
    PlanItemRow item,
    ExerciseType? type,
    UnitFormatter formatter,
  ) {
    if (type == ExerciseType.cardio) {
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
        if (item.targetInclinePercent != null)
          '${_trimZeros(item.targetInclinePercent!)}% incline',
        if (item.targetResistanceLevel != null)
          'level ${item.targetResistanceLevel}',
      ];
      return parts.isEmpty ? 'No prescription set' : parts.join(' · ');
    }

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
    return parts.isEmpty ? 'No prescription set' : parts.join(' · ');
  }

  static String _trimZeros(double value) {
    final fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }

  /// The discipline this block is already committed to, or null while it is
  /// still empty.
  ///
  /// A block is performed as one unit — rounds of it, back to back — so mixing a
  /// bench press and a treadmill run inside one was never coherent. The first
  /// exercise added settles it, and everything after is filtered to match.
  ExerciseType? _blockType(Map<int, ExerciseRow> byId) {
    for (final item in block.items) {
      final type = byId[item.exerciseId]?.type;
      if (type != null) return type;
    }
    return null;
  }

  Future<void> _addExercise(BuildContext context, WidgetRef ref) async {
    // The block's discipline was settled when it was created, so there is
    // normally nothing left to ask and the picker opens already filtered. A
    // block can still be emptied by removing every exercise from it, and then
    // the question is open again.
    final type =
        _blockType(ref.read(exercisesByIdProvider)) ??
        await pickExerciseType(context);
    if (type == null || !context.mounted) return;

    final exercise = await pickExercise(context, type: type);
    if (exercise == null || !context.mounted) return;

    final prescription = await _prescribe(
      context,
      ref,
      exercise: exercise,
      planMode: plan.mode,
    );
    if (prescription == null) return;

    await _writeItem(
      ref.read(planRepositoryProvider),
      planBlockId: block.block.id,
      exerciseId: exercise.id,
      orderIndex: block.items.length,
      prescription: prescription,
    );
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

    final prescription = await _prescribe(
      context,
      ref,
      exercise: exercise,
      planMode: plan.mode,
      existing: item,
    );
    if (prescription == null) return;

    final repo = ref.read(planRepositoryProvider);
    await repo.deleteItem(item.id);
    await _writeItem(
      repo,
      planBlockId: block.block.id,
      exerciseId: exercise.id,
      orderIndex: item.orderIndex,
      prescription: prescription,
    );
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
