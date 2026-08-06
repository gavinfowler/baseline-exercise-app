import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import 'plan_day_editor_screen.dart';

/// Builds a plan by hand: its days, and the way into editing each one.
class PlanEditorScreen extends ConsumerWidget {
  const PlanEditorScreen({required this.plan, super.key});

  final PlanRow plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(planDaysProvider(plan.id));
    final isStatic = plan.mode == PlanMode.staticPlan;

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'plan-editor-fab',
        onPressed: () => _addDay(context, ref, days.value?.length ?? 0),
        icon: const Icon(Icons.add),
        label: const Text('Day'),
      ),
      body: days.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStatic ? 'Static plan' : 'Periodized plan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStatic
                          ? 'Beat the prescribed reps at a heavier weight and '
                                'this plan raises its own target.'
                          : 'Runs for ${plan.durationWeeks ?? '?'} weeks. The '
                                'prescribed numbers stay exactly as written, '
                                'however well you do.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No days yet. Add one to start building the plan.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              for (final day in rows) _DayTile(plan: plan, day: day),
          ],
        ),
      ),
    );
  }

  Future<void> _addDay(
    BuildContext context,
    WidgetRef ref,
    int existingCount,
  ) async {
    final controller = TextEditingController(text: 'Day ${existingCount + 1}');

    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New day'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Label',
            hintText: 'Upper A',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty) return;
    await ref
        .read(planRepositoryProvider)
        .addDay(planId: plan.id, label: label, orderIndex: existingCount);
  }
}

class _DayTile extends ConsumerWidget {
  const _DayTile({required this.plan, required this.day});

  final PlanRow plan;
  final PlanDayRow day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(planDayDetailProvider(day.id));
    final blockCount = detail.value?.blocks.length ?? 0;
    final exerciseCount =
        detail.value?.blocks.fold<int>(0, (s, b) => s + b.items.length) ?? 0;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ListTile(
        title: Text(day.label),
        subtitle: Text(
          blockCount == 0
              ? 'Empty'
              : '$blockCount block${blockCount == 1 ? '' : 's'}'
                    ' · $exerciseCount exercise'
                    '${exerciseCount == 1 ? '' : 's'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Delete day',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref.read(planRepositoryProvider).deleteDay(day.id);
                ref.read(planEditRevisionProvider.notifier).bump();
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PlanDayEditorScreen(plan: plan, day: day),
          ),
        ),
      ),
    );
  }
}
