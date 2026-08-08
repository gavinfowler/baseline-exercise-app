import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/result.dart';
import '../../core/units/unit_system.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/run_segment.dart';
import '../../domain/plan_import/plan_dto.dart';
import '../../domain/plan_import/plan_parser.dart';
import '../../domain/progress_export/progress_export_service.dart';

/// Upload a plan file, see exactly what it will create, then commit it.
///
/// Nothing is written until the preview is confirmed, and a file with problems
/// shows every one of them at once rather than one per attempt.
class PlanImportScreen extends ConsumerStatefulWidget {
  const PlanImportScreen({super.key});

  @override
  ConsumerState<PlanImportScreen> createState() => _PlanImportScreenState();
}

class _PlanImportScreenState extends ConsumerState<PlanImportScreen> {
  PlanFileDto? _parsed;
  List<ValidationIssue> _issues = const [];
  String? _fileName;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import a plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _HowItWorks(),

          // The order below follows the round trip: hand the AI your training
          // so far, hand it the format, then bring its answer back in.
          const SizedBox(height: 24),
          const _ShareProgress(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _copyProgress,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Copy progress for AI'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _saveProgress,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save progress file'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose file'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copySchema,
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copy format for AI'),
                ),
              ),
            ],
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 16),
            Text(_fileName!, style: Theme.of(context).textTheme.labelLarge),
          ],
          if (_issues.isNotEmpty) ...[
            const SizedBox(height: 16),
            _IssueList(issues: _issues),
          ],
          if (_parsed != null) ...[
            const SizedBox(height: 16),
            _Preview(plan: _parsed!.plan),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _commit,
              icon: const Icon(Icons.check),
              label: Text('Import "${_parsed!.plan.name}"'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copySchema() async {
    final schema = await ref.read(planSchemaProvider.future);
    // A short preamble makes the paste self-contained: the model gets the
    // contract and the instruction in one go.
    final payload =
        '''
Write me a training plan as a single JSON document that validates against the
JSON Schema below. Reply with only the JSON — no commentary, no code fences.

Notes that matter:
- "mode": "static" means the plan raises its own weights as I get stronger.
  "mode": "periodized" means the prescribed numbers stay fixed for the program.
- Reference exercises by their common name; they do not need to exist yet.
- Put two or more exercises in one block with "kind": "superset" to superset them.

$schema
''';

    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Format copied. Paste it into any AI chat tool.'),
      ),
    );
  }

  /// Copies the last three months of training **and** the plan format, so one
  /// paste is a complete request: here is what I have been doing, here is the
  /// shape of the answer, write me the next block.
  Future<void> _copyProgress() async {
    final export = await _buildExport();
    if (export == null || !mounted) return;

    final schema = await ref.read(planSchemaProvider.future);
    final payload =
        '''
Here is my training from the last ${export.to.difference(export.from).inDays} days,
exported from my workout app. Use it to write me a new training plan.

Read it first, then tell me in one short paragraph what you are basing the plan
on. After that, reply with only the plan as a single JSON document that
validates against the JSON Schema at the end of this message — no commentary
around it, no code fences.

How to read the training data:
- All numbers are metric: kilograms, meters, seconds, seconds per kilometer.
  "preferredDisplayUnits" is only how I like them shown to me.
- "strengthExercises" and "cardioExercises" summarise the window;
  "sessions" is the full log those summaries came from.
- "personalRecords" are all-time, not just this window. Do not prescribe below
  one without a deliberate reason, such as a planned deload.

Notes on the plan you write back:
- "mode": "static" means the plan raises its own weights as I get stronger.
  "mode": "periodized" means the prescribed numbers stay fixed for the program.
- Reference exercises by their common name; they do not need to exist yet.
- Put two or more exercises in one block with "kind": "superset" to superset them.

--- MY TRAINING ---
${export.json}

--- PLAN FORMAT ---
$schema
''';

    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${export.sessionCount} workouts. Paste it into any AI chat '
          'tool.',
        ),
      ),
    );
  }

  /// The same document as a file, for tools that take an attachment rather than
  /// a very long paste.
  Future<void> _saveProgress() async {
    final export = await _buildExport();
    if (export == null || !mounted) return;

    final suggested =
        'training-progress-'
        '${DateFormat('yyyy-MM-dd').format(export.to)}.json';
    final location = await getSaveLocation(suggestedName: suggested);
    if (location == null || !mounted) return;

    await File(location.path).writeAsString(export.json);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${export.sessionCount} workouts written to ${location.path}',
        ),
      ),
    );
  }

  /// Builds the export, or explains why there is nothing worth sending.
  ///
  /// An empty export would be worse than no button: the AI would invent a
  /// starting point and present it as tailored.
  Future<ProgressExport?> _buildExport() async {
    setState(() => _busy = true);
    try {
      final export = await ref.read(progressExportServiceProvider).export();
      if (!export.isEmpty) return export;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No completed workouts in the last 3 months yet — there is '
              'nothing to send.',
            ),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    const typeGroup = XTypeGroup(label: 'Plan files', extensions: ['json']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    setState(() => _busy = true);
    try {
      final source = await File(file.path).readAsString();
      final result = const PlanParser().parse(source);

      setState(() {
        _fileName = file.name;
        _parsed = result.valueOrNull;
        _issues = result.issues;
      });
    } on FileSystemException catch (e) {
      setState(() {
        _fileName = file.name;
        _parsed = null;
        _issues = [
          ValidationIssue(
            pointer: '',
            message: 'Could not read the file: ${e.message}',
          ),
        ];
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    final parsed = _parsed;
    if (parsed == null) return;

    setState(() => _busy = true);
    final summary = await ref.read(planImporterProvider).import(parsed);
    if (!mounted) return;

    setState(() => _busy = false);

    final created = summary.createdExerciseNames;
    final message = StringBuffer(
      'Imported "${summary.planName}" — ${summary.dayCount} days, '
      '${summary.exerciseCount} exercises.',
    );
    if (created.isNotEmpty) {
      message.write(
        '\nAdded ${created.length} new exercise'
        '${created.length == 1 ? '' : 's'} to your catalog.',
      );
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message.toString())));
    Navigator.of(context).pop();
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have an AI write your plan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap "Copy progress for AI" and paste it into any chat tool along '
              'with what you want to train next. Save the JSON it gives back, '
              'then choose it here. Nothing is added until you confirm the '
              'preview.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Explains what leaves the device, in the one place it can happen.
///
/// The app is otherwise entirely offline, so an export that a user pastes
/// elsewhere deserves saying out loud rather than burying in a tooltip.
class _ShareProgress extends StatelessWidget {
  const _ShareProgress();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your last 3 months', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'A plan written without your numbers is a guess. This gathers '
              'the last 3 months of completed workouts — what you lifted and '
              'ran, your best sets, and your personal records — so the plan '
              'starts where you actually are.',
            ),
            const SizedBox(height: 8),
            Text(
              'Copying or saving it is the only time your training leaves this '
              'device, and only you decide where it goes.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.issues});

  final List<ValidationIssue> issues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errors = issues.where((i) => i.isError).toList();
    final warnings = issues.where((i) => !i.isError).toList();

    return Card(
      color: errors.isEmpty
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errors.isEmpty
                  ? '${warnings.length} thing${warnings.length == 1 ? '' : 's'} to check'
                  : "${errors.length} problem${errors.length == 1 ? '' : 's'} — nothing was imported",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final issue in issues)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The pointer is what makes a generated file fixable: it
                    // names the exact node that is wrong.
                    Text(
                      issue.location,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(issue.message, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.plan});

  final PlanDto plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStatic = plan.mode == PlanMode.staticPlan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              isStatic
                  ? 'Static plan — beating the prescribed reps at a heavier '
                        'weight raises the target.'
                  : 'Periodized plan over ${plan.durationWeeks} weeks — the '
                        'prescribed numbers will not change.',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 24),
            for (final day in plan.days) ...[
              Text(day.label, style: theme.textTheme.titleSmall),
              for (final block in day.blocks)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (block.kind.isGrouped)
                        Text(
                          '${block.kind.label}'
                          '${block.label == null ? '' : ' ${block.label}'}'
                          ' — ${block.rounds} rounds',
                          style: theme.textTheme.labelSmall,
                        ),
                      for (final exercise in block.exercises)
                        Text(
                          '· ${exercise.name}'
                          '${_prescription(exercise, block.rounds)}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// Renders in metric, matching how the values are stored. The rest of the app
  /// converts for display; this preview deliberately shows what will be saved.
  String _prescription(PlanExerciseDto exercise, int rounds) {
    if (exercise.isStrength) {
      final parts = <String>[
        if (exercise.reps != null) '$rounds × ${exercise.reps}',
        if (exercise.weightKg != null)
          '${exercise.weightKg!.toStringAsFixed(1)} kg',
        if (exercise.weightMode != WeightMode.absolute)
          '(${exercise.weightMode.wireName})',
      ];
      return parts.isEmpty ? '' : '  ${parts.join(' ')}';
    }

    final workout = RunWorkout.decode(exercise.intervalsJson);
    final parts = <String>[
      if (exercise.durationSeconds != null)
        '${(exercise.durationSeconds! / 60).round()} min',
      if (exercise.distanceMeters != null)
        '${(exercise.distanceMeters! / 1000).toStringAsFixed(2)} km',
      if (exercise.paceSecPerKm != null)
        '@ ${UnitFormatter.formatDuration(exercise.paceSecPerKm!.round())} /km',
      if (workout.isNotEmpty)
        '(${workout.segments.length} segment'
            '${workout.segments.length == 1 ? '' : 's'})',
    ];
    return parts.isEmpty ? '' : '  ${parts.join(' · ')}';
  }
}
