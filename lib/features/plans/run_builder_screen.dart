import 'package:flutter/material.dart';

import '../../core/units/pace.dart';
import '../../core/units/unit_system.dart';
import '../../domain/models/run_segment.dart';
import 'cardio_triple_fields.dart';

/// Builds a structured cardio workout — fartlek, interval repeats, tempo, or
/// any mix of them — as an ordered list of segments with their own paces.
///
/// Returns the finished workout, or null if the user backed out. An empty list
/// is a valid result: it means "this is a plain steady effort after all".
Future<RunWorkout?> showRunBuilder(
  BuildContext context, {
  required RunWorkout initial,
  required UnitFormatter formatter,
  required String exerciseName,
}) {
  return Navigator.of(context).push<RunWorkout>(
    MaterialPageRoute(
      builder: (_) => RunBuilderScreen(
        initial: initial,
        formatter: formatter,
        exerciseName: exerciseName,
      ),
      fullscreenDialog: true,
    ),
  );
}

class RunBuilderScreen extends StatefulWidget {
  const RunBuilderScreen({
    required this.initial,
    required this.formatter,
    required this.exerciseName,
    super.key,
  });

  final RunWorkout initial;
  final UnitFormatter formatter;
  final String exerciseName;

  @override
  State<RunBuilderScreen> createState() => _RunBuilderScreenState();
}

class _RunBuilderScreenState extends State<RunBuilderScreen> {
  late List<RunSegment> _segments = [...widget.initial.segments];

  RunWorkout get _workout => RunWorkout(_segments);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Structured workout'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_workout),
            child: const Text('Save'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'run-builder-fab',
        onPressed: _addSegment,
        icon: const Icon(Icons.add),
        label: const Text('Segment'),
      ),
      body: Column(
        children: [
          _TotalsBar(workout: _workout, formatter: widget.formatter),
          Expanded(
            child: _segments.isEmpty
                ? _EmptyState(onTemplate: _applyTemplate)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: _segments.length,
                    onReorderItem: _reorder,
                    itemBuilder: (context, i) => _SegmentCard(
                      key: ValueKey(i),
                      index: i,
                      segment: _segments[i],
                      formatter: widget.formatter,
                      onEdit: () => _editSegment(i),
                      onDelete: () => setState(() => _segments.removeAt(i)),
                    ),
                  ),
          ),
          if (_segments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.exerciseName,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showTemplates,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('Templates'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Unlike the older `onReorder`, `onReorderItem` reports the index the
  /// segment should land on *after* its removal, so there is nothing to adjust.
  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final moved = _segments.removeAt(oldIndex);
      _segments.insert(newIndex, moved);
    });
  }

  Future<void> _addSegment() async {
    final segment = await showSegmentEditor(
      context,
      formatter: widget.formatter,
    );
    if (segment == null) return;
    setState(() => _segments = [..._segments, segment]);
  }

  Future<void> _editSegment(int index) async {
    final segment = await showSegmentEditor(
      context,
      formatter: widget.formatter,
      existing: _segments[index],
    );
    if (segment == null) return;
    setState(() => _segments[index] = segment);
  }

  Future<void> _showTemplates() async {
    final template = await showModalBottomSheet<List<RunSegment>>(
      context: context,
      builder: (context) => const _TemplateSheet(),
    );
    if (template == null) return;
    _applyTemplate(template);
  }

  void _applyTemplate(List<RunSegment> segments) =>
      setState(() => _segments = [..._segments, ...segments]);
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.workout, required this.formatter});

  final RunWorkout workout;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = workout.totalDurationSeconds;
    final distance = workout.totalDistanceMeters;
    final pace = workout.averagePaceSecPerKm;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Total(
              label: 'Total time',
              value: duration == null
                  ? '—'
                  : UnitFormatter.formatDuration(duration),
            ),
            _Total(
              label: 'Distance',
              value: distance == null
                  ? '—'
                  : formatter.formatDistance(distance),
            ),
            _Total(
              label: 'Avg pace',
              value: pace == null ? '—' : formatter.formatPace(pace),
            ),
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTemplate});

  final ValueChanged<List<RunSegment>> onTemplate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.timeline, size: 48),
          const SizedBox(height: 12),
          Text(
            'Build the workout in segments',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'A segment is one repeated effort: "6 × 400 m hard with 200 m jog". '
            'Stack a warm-up, the work, and a cool-down to make a full session.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Start from a template',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final template in runTemplates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => onTemplate(template.build()),
                child: Text(template.name),
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplateSheet extends StatelessWidget {
  const _TemplateSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Add a template',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final template in runTemplates)
            ListTile(
              title: Text(template.name),
              subtitle: Text(template.description),
              onTap: () => Navigator.of(context).pop(template.build()),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// A named starting point. Paces are deliberately left unset except where the
/// shape of the workout depends on them — the user's own paces are the point,
/// and a prefilled guess would be wrong for almost everyone.
class RunTemplate {
  const RunTemplate({
    required this.name,
    required this.description,
    required this.build,
  });

  final String name;
  final String description;
  final List<RunSegment> Function() build;
}

const List<RunTemplate> runTemplates = [
  RunTemplate(name: 'Warm-up', description: '10 minutes easy', build: _warmUp),
  RunTemplate(
    name: 'Fartlek surges',
    description: '8 × 1:00 hard with 2:00 easy',
    build: _fartlek,
  ),
  RunTemplate(
    name: 'Interval repeats',
    description: '6 × 400 m with 200 m recovery',
    build: _repeats,
  ),
  RunTemplate(
    name: 'Tempo block',
    description: '20 minutes at threshold',
    build: _tempo,
  ),
  RunTemplate(
    name: 'Pyramid',
    description: '1:00, 2:00, 3:00, 2:00, 1:00 with equal recovery',
    build: _pyramid,
  ),
  RunTemplate(
    name: 'Cool-down',
    description: '10 minutes easy',
    build: _coolDown,
  ),
];

List<RunSegment> _warmUp() => const [
  RunSegment(label: 'Warm-up', work: RunEffort(durationSeconds: 600)),
];

List<RunSegment> _coolDown() => const [
  RunSegment(label: 'Cool-down', work: RunEffort(durationSeconds: 600)),
];

List<RunSegment> _fartlek() => const [
  RunSegment(
    label: 'Surges',
    repeat: 8,
    work: RunEffort(durationSeconds: 60),
    recovery: RunEffort(durationSeconds: 120),
  ),
];

List<RunSegment> _repeats() => const [
  RunSegment(
    label: '400 m repeats',
    repeat: 6,
    work: RunEffort(distanceMeters: 400),
    recovery: RunEffort(distanceMeters: 200),
  ),
];

List<RunSegment> _tempo() => const [
  RunSegment(label: 'Tempo', work: RunEffort(durationSeconds: 1200)),
];

List<RunSegment> _pyramid() => const [
  RunSegment(
    label: 'Up 1:00',
    work: RunEffort(durationSeconds: 60),
    recovery: RunEffort(durationSeconds: 60),
  ),
  RunSegment(
    label: 'Up 2:00',
    work: RunEffort(durationSeconds: 120),
    recovery: RunEffort(durationSeconds: 120),
  ),
  RunSegment(
    label: 'Peak 3:00',
    work: RunEffort(durationSeconds: 180),
    recovery: RunEffort(durationSeconds: 180),
  ),
  RunSegment(
    label: 'Down 2:00',
    work: RunEffort(durationSeconds: 120),
    recovery: RunEffort(durationSeconds: 120),
  ),
  RunSegment(
    label: 'Down 1:00',
    work: RunEffort(durationSeconds: 60),
    recovery: RunEffort(durationSeconds: 60),
  ),
];

class _SegmentCard extends StatelessWidget {
  const _SegmentCard({
    required this.index,
    required this.segment,
    required this.formatter,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final int index;
  final RunSegment segment;
  final UnitFormatter formatter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = segment.totalDurationSeconds;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(segment.label ?? 'Segment ${index + 1}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(segment.describe(formatter)),
            if (duration != null)
              Text(
                'Takes ${UnitFormatter.formatDuration(duration)}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        isThreeLine: duration != null,
        onTap: onEdit,
        trailing: IconButton(
          tooltip: 'Remove segment',
          icon: const Icon(Icons.close),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- segment

/// Edits one segment: how many times it repeats, the effort, and the recovery.
Future<RunSegment?> showSegmentEditor(
  BuildContext context, {
  required UnitFormatter formatter,
  RunSegment? existing,
}) {
  return showModalBottomSheet<RunSegment>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _SegmentEditor(formatter: formatter, existing: existing),
    ),
  );
}

class _SegmentEditor extends StatefulWidget {
  const _SegmentEditor({required this.formatter, this.existing});

  final UnitFormatter formatter;
  final RunSegment? existing;

  @override
  State<_SegmentEditor> createState() => _SegmentEditorState();
}

class _SegmentEditorState extends State<_SegmentEditor> {
  late final TextEditingController _label;
  late final TextEditingController _repeat;

  late CardioTriple _work;
  late CardioTriple _recovery;
  late bool _hasRecovery;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _label = TextEditingController(text: existing?.label ?? '');
    _repeat = TextEditingController(text: '${existing?.repeat ?? 1}');
    _work = _toTriple(existing?.work);
    _recovery = _toTriple(existing?.recovery);
    _hasRecovery = existing?.recovery != null;
  }

  static CardioTriple _toTriple(RunEffort? effort) => CardioTriple(
    durationSeconds: effort?.durationSeconds,
    distanceMeters: effort?.distanceMeters,
    paceSecPerKm: effort?.paceSecPerKm,
  );

  static RunEffort _toEffort(CardioTriple triple) => RunEffort(
    durationSeconds: triple.durationSeconds,
    distanceMeters: triple.distanceMeters,
    paceSecPerKm: triple.paceSecPerKm,
  );

  @override
  void dispose() {
    _label.dispose();
    _repeat.dispose();
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
            Text(
              widget.existing == null ? 'New segment' : 'Edit segment',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _label,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: '400 m repeats',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repeat,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Repeat',
                      suffixText: '×',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Work', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            CardioTripleFields(
              formatter: widget.formatter,
              initial: _work,
              onChanged: (value) => _work = value,
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recovery between reps'),
              subtitle: const Text('The easy part between efforts'),
              value: _hasRecovery,
              onChanged: (value) => setState(() => _hasRecovery = value),
            ),
            if (_hasRecovery)
              CardioTripleFields(
                formatter: widget.formatter,
                initial: _recovery,
                onChanged: (value) => _recovery = value,
              ),

            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Save segment')),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final work = _toEffort(_work);
    if (work.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Give the work a duration, a distance, or a pace.'),
        ),
      );
      return;
    }

    final label = _label.text.trim();
    final recovery = _hasRecovery ? _toEffort(_recovery) : null;

    Navigator.of(context).pop(
      RunSegment(
        label: label.isEmpty ? null : label,
        repeat: int.tryParse(_repeat.text.trim())?.clamp(1, 100) ?? 1,
        work: work,
        recovery: recovery == null || recovery.isEmpty ? null : recovery,
      ),
    );
  }
}
