import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units/unit_system.dart';

/// What the user entered for one set, in **display** units.
class SetEntryResult {
  const SetEntryResult({
    required this.weight,
    required this.reps,
    required this.isWarmup,
  });

  /// In the user's display unit — convert with [UnitFormatter.weightToKg]
  /// before storing.
  final double weight;
  final int reps;
  final bool isWarmup;
}

/// Prompts for weight and reps.
///
/// Prefilled from the previous performance so logging a repeat set is usually
/// one tap.
Future<SetEntryResult?> showSetEntryDialog(
  BuildContext context, {
  required String exerciseName,
  required UnitFormatter formatter,
  double? initialWeight,
  int? initialReps,
  bool initialWarmup = false,
  String? prescriptionHint,
}) {
  return showDialog<SetEntryResult>(
    context: context,
    builder: (context) => _SetEntryDialog(
      exerciseName: exerciseName,
      formatter: formatter,
      initialWeight: initialWeight,
      initialReps: initialReps,
      initialWarmup: initialWarmup,
      prescriptionHint: prescriptionHint,
    ),
  );
}

class _SetEntryDialog extends StatefulWidget {
  const _SetEntryDialog({
    required this.exerciseName,
    required this.formatter,
    this.initialWeight,
    this.initialReps,
    this.initialWarmup = false,
    this.prescriptionHint,
  });

  final String exerciseName;
  final UnitFormatter formatter;
  final double? initialWeight;
  final int? initialReps;
  final bool initialWarmup;
  final String? prescriptionHint;

  @override
  State<_SetEntryDialog> createState() => _SetEntryDialogState();
}

class _SetEntryDialogState extends State<_SetEntryDialog> {
  late final TextEditingController _weight;
  late final TextEditingController _reps;
  late bool _isWarmup;
  String? _error;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(
      text: widget.initialWeight == null ? '' : _trim(widget.initialWeight!),
    );
    _reps = TextEditingController(text: widget.initialReps?.toString() ?? '');
    _isWarmup = widget.initialWarmup;
  }

  static String _trim(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.contains('.')
        ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
        : fixed;
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exerciseName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.prescriptionHint != null) ...[
            Text(
              widget.prescriptionHint!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weight,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    suffixText: widget.formatter.weightSuffix,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _reps,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            value: _isWarmup,
            // Warm-ups are excluded from personal records and from static-plan
            // baseline promotion, so the distinction matters.
            title: const Text('Warm-up set'),
            onChanged: (value) => setState(() => _isWarmup = value ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Log set')),
      ],
    );
  }

  void _submit() {
    final weight = double.tryParse(_weight.text.trim());
    final reps = int.tryParse(_reps.text.trim());

    if (weight == null || weight < 0) {
      setState(() => _error = 'Enter a weight (0 is fine for bodyweight)');
      return;
    }
    if (reps == null || reps <= 0) {
      setState(() => _error = 'Enter how many reps you completed');
      return;
    }

    Navigator.of(
      context,
    ).pop(SetEntryResult(weight: weight, reps: reps, isWarmup: _isWarmup));
  }
}
