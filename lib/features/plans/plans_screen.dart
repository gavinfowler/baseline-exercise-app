import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import '../ads/ad_slot.dart';
import 'plan_editor_screen.dart';
import 'plan_import_screen.dart';

/// Lists plans, and is the way into importing one.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans'),
        actions: [
          IconButton(
            tooltip: 'Import a plan file',
            icon: const Icon(Icons.upload_file),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlanImportScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // See the note in ExerciseCatalogScreen: tabs share a Hero subtree.
        heroTag: 'plans-fab',
        onPressed: () => _createPlan(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New plan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: plans.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (rows) => rows.isEmpty
                  ? const _NoPlans()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: rows.length,
                      itemBuilder: (context, i) => _PlanTile(plan: rows[i]),
                    ),
            ),
          ),
          const AdSlot(),
        ],
      ),
    );
  }

  Future<void> _createPlan(BuildContext context, WidgetRef ref) async {
    final draft = await showModalBottomSheet<_PlanDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _NewPlanSheet(),
      ),
    );
    if (draft == null || !context.mounted) return;

    final repo = ref.read(planRepositoryProvider);
    final planId = await repo.createPlan(
      name: draft.name,
      mode: draft.mode,
      durationWeeks: draft.durationWeeks,
    );
    final plan = await repo.findById(planId);
    if (plan == null || !context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PlanEditorScreen(plan: plan)),
    );
  }
}

class _PlanDraft {
  const _PlanDraft({
    required this.name,
    required this.mode,
    this.durationWeeks,
  });

  final String name;
  final PlanMode mode;
  final int? durationWeeks;
}

/// Collects just enough to create a plan; everything else is edited afterwards.
class _NewPlanSheet extends StatefulWidget {
  const _NewPlanSheet();

  @override
  State<_NewPlanSheet> createState() => _NewPlanSheetState();
}

class _NewPlanSheetState extends State<_NewPlanSheet> {
  final _name = TextEditingController();
  final _weeks = TextEditingController(text: '8');
  PlanMode _mode = PlanMode.staticPlan;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _weeks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New plan', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Upper/Lower 4-Day',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),

            // The choice that decides how the plan behaves for its whole life,
            // so it is spelled out rather than labelled with jargon.
            RadioGroup<PlanMode>(
              groupValue: _mode,
              onChanged: (value) =>
                  setState(() => _mode = value ?? PlanMode.staticPlan),
              child: const Column(
                children: [
                  RadioListTile<PlanMode>(
                    value: PlanMode.staticPlan,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Repeat and progress'),
                    subtitle: Text(
                      'The same workouts every time. Beat the target reps at a '
                      'heavier weight and the plan raises its target.',
                    ),
                  ),
                  RadioListTile<PlanMode>(
                    value: PlanMode.periodized,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Fixed program'),
                    subtitle: Text(
                      'Runs for a set number of weeks. The prescribed numbers '
                      'never change; beating them is recorded as a personal '
                      'record instead.',
                    ),
                  ),
                ],
              ),
            ),

            if (_mode == PlanMode.periodized) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _weeks,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Length',
                  suffixText: 'weeks',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Create')),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the plan a name');
      return;
    }

    final weeks = int.tryParse(_weeks.text.trim());
    if (_mode == PlanMode.periodized && (weeks == null || weeks < 1)) {
      setState(() => _error = 'A fixed program needs a length in weeks');
      return;
    }

    Navigator.of(context).pop(
      _PlanDraft(
        name: name,
        mode: _mode,
        durationWeeks: _mode == PlanMode.periodized ? weeks : null,
      ),
    );
  }
}

class _NoPlans extends StatelessWidget {
  const _NoPlans();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, size: 56),
            const SizedBox(height: 16),
            Text(
              'No plans yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Import a plan file to get started. You can have an AI tool '
              'write one for you — the import screen gives you the exact '
              'format to hand it.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan});

  final PlanRow plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStatic = plan.mode == PlanMode.staticPlan;

    final subtitle = [
      isStatic
          ? 'Static — the plan moves up with you'
          : 'Periodized — the prescription never changes',
      if (plan.durationWeeks != null) '${plan.durationWeeks} weeks',
      if (plan.source == PlanSource.imported) 'imported',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ListTile(
        leading: Icon(isStatic ? Icons.trending_up : Icons.event_note),
        title: Text(plan.name),
        subtitle: Text(subtitle),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PlanEditorScreen(plan: plan)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (plan.isActive)
              const Chip(
                label: Text('Active'),
                visualDensity: VisualDensity.compact,
              )
            else
              TextButton(
                onPressed: () =>
                    ref.read(planRepositoryProvider).setActivePlan(plan.id),
                child: const Text('Activate'),
              ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${plan.name}"?'),
        content: const Text(
          'The plan and its workouts are removed. Sessions you have already '
          'completed are kept, along with what they prescribed at the time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(planRepositoryProvider).deletePlan(plan.id);
  }
}
