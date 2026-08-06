import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units/pace.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/run_segment.dart';
import 'cardio_triple_fields.dart';
import 'run_builder_screen.dart';

/// A prescription entered in the plan editor, already in canonical units.
class PlanItemResult {
  const PlanItemResult({
    this.reps,
    this.weightKg,
    this.weightMode = WeightMode.absolute,
    this.weightOffsetKg,
    this.weightPercent,
    this.durationSeconds,
    this.distanceMeters,
    this.paceSecPerKm,
    this.intervalsJson,
  });

  final int? reps;
  final double? weightKg;
  final WeightMode weightMode;

  /// Increment for [WeightMode.baselinePlus].
  final double? weightOffsetKg;

  final double? weightPercent;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? paceSecPerKm;

  /// The encoded [RunWorkout] for a structured session, or null for a steady
  /// effort.
  final String? intervalsJson;
}

Future<PlanItemResult?> showPlanItemEditor(
  BuildContext context, {
  required ExerciseRow exercise,
  required PlanMode planMode,
  required UnitFormatter formatter,
  PlanItemRow? existing,
}) {
  return showModalBottomSheet<PlanItemResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _PlanItemEditor(
        exercise: exercise,
        planMode: planMode,
        formatter: formatter,
        existing: existing,
      ),
    ),
  );
}

class _PlanItemEditor extends StatefulWidget {
  const _PlanItemEditor({
    required this.exercise,
    required this.planMode,
    required this.formatter,
    this.existing,
  });

  final ExerciseRow exercise;
  final PlanMode planMode;
  final UnitFormatter formatter;
  final PlanItemRow? existing;

  @override
  State<_PlanItemEditor> createState() => _PlanItemEditorState();
}

class _PlanItemEditorState extends State<_PlanItemEditor> {
  final _reps = TextEditingController();
  final _weight = TextEditingController();
  final _percent = TextEditingController();
  final _offset = TextEditingController();

  late WeightMode _weightMode;

  /// The steady-effort prescription: duration, distance and pace, any two of
  /// which determine the third.
  CardioTriple _cardio = const CardioTriple();

  /// The structured prescription. Non-empty means this item is an interval
  /// session and the steady fields are ignored.
  RunWorkout _workout = RunWorkout.empty;

  bool _structured = false;

  bool get _isStrength => widget.exercise.type == ExerciseType.strength;

  /// Baseline modes only progress in a static plan, so offering them in a
  /// periodized one would promise behaviour the plan will never perform.
  bool get _allowBaselineModes => widget.planMode == PlanMode.staticPlan;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _weightMode = _allowBaselineModes
        ? (existing?.weightMode ?? WeightMode.baseline)
        : WeightMode.absolute;

    if (existing != null) {
      _reps.text = existing.targetReps?.toString() ?? '';
      if (existing.targetWeightKg != null) {
        _weight.text = _trim(
          widget.formatter.weightValue(existing.targetWeightKg!),
        );
      }
      _percent.text = existing.weightPercent?.toStringAsFixed(0) ?? '';
      if (existing.weightOffsetKg != null) {
        _offset.text = _trim(
          widget.formatter.weightValue(existing.weightOffsetKg!),
        );
      }

      _cardio = CardioTriple(
        durationSeconds: existing.targetDurationSeconds,
        distanceMeters: existing.targetDistanceMeters,
        paceSecPerKm: existing.targetPaceSecPerKm,
      );
      _workout = RunWorkout.decode(existing.intervalsJson);
      _structured = _workout.isNotEmpty;
    }
  }

  static String _trim(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.contains('.')
        ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
        : fixed;
  }

  @override
  void dispose() {
    for (final c in [_reps, _weight, _percent, _offset]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercise.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_isStrength)
              ..._strengthFields(context)
            else
              ..._cardioFields(context),
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  List<Widget> _strengthFields(BuildContext context) {
    return [
      TextField(
        controller: _reps,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Target reps',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),

      if (_allowBaselineModes) ...[
        DropdownButtonFormField<WeightMode>(
          initialValue: _weightMode,
          // Without this the menu sizes to its widest entry and overflows a
          // phone-width sheet.
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Weight',
            border: OutlineInputBorder(),
          ),
          // Every WeightMode must appear here. A plan file can prescribe any of
          // them, and the dropdown asserts if it is opened on a value it does
          // not offer.
          items: const [
            DropdownMenuItem(
              value: WeightMode.baseline,
              child: Text('Track my working weight'),
            ),
            DropdownMenuItem(
              value: WeightMode.baselinePlus,
              child: Text('My working weight, plus a bit'),
            ),
            DropdownMenuItem(
              value: WeightMode.baselinePercent,
              child: Text('A percentage of my working weight'),
            ),
            DropdownMenuItem(
              value: WeightMode.absolute,
              child: Text('A fixed weight'),
            ),
          ],
          onChanged: (value) =>
              setState(() => _weightMode = value ?? WeightMode.baseline),
        ),
        const SizedBox(height: 8),
        Text(switch (_weightMode) {
          WeightMode.baseline =>
            'Starts at the weight below and rises whenever you beat it at '
                'the target reps.',
          WeightMode.baselinePlus =>
            'Your current working weight plus the amount below, recalculated '
                'each session.',
          WeightMode.baselinePercent =>
            'Calculated from your current working weight each session.',
          WeightMode.absolute => 'Always prescribes exactly this weight.',
        }, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
      ],

      if (_weightMode == WeightMode.baselinePercent)
        TextField(
          controller: _percent,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Percentage',
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
        )
      else if (_weightMode == WeightMode.baselinePlus)
        TextField(
          controller: _offset,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: 'Amount to add',
            suffixText: widget.formatter.weightSuffix,
            border: const OutlineInputBorder(),
          ),
        )
      else
        TextField(
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: _weightMode == WeightMode.baseline
                ? 'Starting weight'
                : 'Weight',
            suffixText: widget.formatter.weightSuffix,
            border: const OutlineInputBorder(),
          ),
        ),
    ];
  }

  List<Widget> _cardioFields(BuildContext context) {
    final activity = widget.exercise.cardioActivity ?? CardioActivity.other;

    return [
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: false,
            label: Text('Steady'),
            icon: Icon(Icons.trending_flat),
          ),
          ButtonSegment(
            value: true,
            label: Text('Structured'),
            icon: Icon(Icons.timeline),
          ),
        ],
        selected: {_structured},
        onSelectionChanged: (values) =>
            setState(() => _structured = values.first),
      ),
      const SizedBox(height: 16),
      if (_structured)
        ..._structuredFields(context)
      else
        CardioTripleFields(
          formatter: widget.formatter,
          initial: _cardio,
          showPace: activity.tracksPace,
          durationLabel: 'Target duration',
          distanceLabel: 'Target distance',
          paceLabel: 'Target pace',
          onChanged: (value) => _cardio = value,
        ),
    ];
  }

  List<Widget> _structuredFields(BuildContext context) {
    final theme = Theme.of(context);

    return [
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _workout.isEmpty
                    ? 'No segments yet'
                    : _workout.describe(widget.formatter),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                _workout.isEmpty
                    ? 'Intervals, fartlek surges, tempo blocks — each with its '
                          'own pace.'
                    : _workout.segments
                          .map((s) => s.label ?? s.describe(widget.formatter))
                          .join(' → '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _editWorkout,
        icon: const Icon(Icons.edit_outlined),
        label: Text(_workout.isEmpty ? 'Build the workout' : 'Edit segments'),
      ),
    ];
  }

  Future<void> _editWorkout() async {
    final result = await showRunBuilder(
      context,
      initial: _workout,
      formatter: widget.formatter,
      exerciseName: widget.exercise.name,
    );
    if (result == null) return;
    setState(() => _workout = result);
  }

  void _submit() {
    if (_isStrength) {
      final weight = double.tryParse(_weight.text.trim());
      final offset = double.tryParse(_offset.text.trim());
      Navigator.of(context).pop(
        PlanItemResult(
          reps: int.tryParse(_reps.text.trim()),
          weightKg: weight == null ? null : widget.formatter.weightToKg(weight),
          weightMode: _weightMode,
          weightOffsetKg: offset == null
              ? null
              : widget.formatter.weightToKg(offset),
          weightPercent: double.tryParse(_percent.text.trim()),
        ),
      );
      return;
    }

    // A structured workout carries its own totals, so they are written to the
    // steady fields too. History and the plan list can then summarise any
    // cardio item without decoding the segments.
    final workout = _structured ? _workout : RunWorkout.empty;
    final cardio = workout.isEmpty
        ? _cardio
        : CardioTriple(
            durationSeconds: workout.totalDurationSeconds,
            distanceMeters: workout.totalDistanceMeters,
            paceSecPerKm: workout.averagePaceSecPerKm,
          );

    Navigator.of(context).pop(
      PlanItemResult(
        durationSeconds: cardio.durationSeconds,
        distanceMeters: cardio.distanceMeters,
        paceSecPerKm: cardio.paceSecPerKm,
        intervalsJson: workout.encode(),
      ),
    );
  }
}
