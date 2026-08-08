import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import 'save_bar.dart';

/// A strength prescription entered in the plan editor, already in canonical
/// units.
///
/// Separate from [CardioItemResult] so each one maps onto the repository call it
/// feeds. A single class covering both left most of its fields null on every
/// use, and nothing said which half was meaningful.
class StrengthItemResult {
  const StrengthItemResult({
    this.reps,
    this.weightKg,
    this.weightMode = WeightMode.absolute,
    this.weightOffsetKg,
    this.weightPercent,
  });

  final int? reps;
  final double? weightKg;
  final WeightMode weightMode;

  /// Increment for [WeightMode.baselinePlus].
  final double? weightOffsetKg;

  final double? weightPercent;
}

/// Opens the strength prescription editor as a full screen.
Future<StrengthItemResult?> showStrengthItemEditor(
  BuildContext context, {
  required ExerciseRow exercise,
  required PlanMode planMode,
  required UnitFormatter formatter,
  PlanItemRow? existing,
}) {
  return Navigator.of(context).push<StrengthItemResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => StrengthItemScreen(
        exercise: exercise,
        planMode: planMode,
        formatter: formatter,
        existing: existing,
      ),
    ),
  );
}

/// Prescribes one strength exercise: how many reps, and how the weight is
/// decided.
class StrengthItemScreen extends StatefulWidget {
  const StrengthItemScreen({
    required this.exercise,
    required this.planMode,
    required this.formatter,
    this.existing,
    super.key,
  });

  final ExerciseRow exercise;
  final PlanMode planMode;
  final UnitFormatter formatter;
  final PlanItemRow? existing;

  @override
  State<StrengthItemScreen> createState() => _StrengthItemScreenState();
}

class _StrengthItemScreenState extends State<StrengthItemScreen> {
  final _reps = TextEditingController();
  final _weight = TextEditingController();
  final _percent = TextEditingController();
  final _offset = TextEditingController();

  late WeightMode _weightMode;

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.name)),
      bottomNavigationBar: SaveBar(onSave: _submit),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, size: 20),
              const SizedBox(width: 8),
              Text(
                'Strength'
                '${widget.exercise.muscleGroup == null ? '' : ' · ${widget.exercise.muscleGroup}'}',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _reps,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Target reps',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          if (_allowBaselineModes) ...[
            DropdownButtonFormField<WeightMode>(
              initialValue: _weightMode,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
              // Every WeightMode must appear here. A plan file can prescribe any
              // of them, and the dropdown asserts if it is opened on a value it
              // does not offer.
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
                'Your current working weight plus the amount below, '
                    'recalculated each session.',
              WeightMode.baselinePercent =>
                'Calculated from your current working weight each session.',
              WeightMode.absolute => 'Always prescribes exactly this weight.',
            }, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
        ],
      ),
    );
  }

  void _submit() {
    final weight = double.tryParse(_weight.text.trim());
    final offset = double.tryParse(_offset.text.trim());

    Navigator.of(context).pop(
      StrengthItemResult(
        reps: int.tryParse(_reps.text.trim()),
        weightKg: weight == null ? null : widget.formatter.weightToKg(weight),
        weightMode: _weightMode,
        weightOffsetKg: offset == null
            ? null
            : widget.formatter.weightToKg(offset),
        weightPercent: double.tryParse(_percent.text.trim()),
      ),
    );
  }
}
