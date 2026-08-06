import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units/unit_system.dart';
import '../../domain/models/cardio_fields.dart';
import '../../domain/models/enums.dart';

/// What the user entered for a cardio effort. Distances are in **display**
/// units; convert with [UnitFormatter.distanceToMeters] before storing.
class CardioEntryResult {
  const CardioEntryResult({
    required this.durationSeconds,
    this.distance,
    this.inclinePercent,
    this.resistanceLevel,
    this.avgHeartRate,
    this.maxHeartRate,
    this.calories,
    this.elevationGain,
    this.notes,
  });

  final int durationSeconds;
  final double? distance;
  final double? inclinePercent;
  final int? resistanceLevel;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? calories;
  final double? elevationGain;
  final String? notes;
}

Future<CardioEntryResult?> showCardioEntrySheet(
  BuildContext context, {
  required String exerciseName,
  required CardioActivity? activity,
  required UnitFormatter formatter,
  int? initialDurationSeconds,
  double? initialDistance,
}) {
  return showModalBottomSheet<CardioEntryResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _CardioEntrySheet(
        exerciseName: exerciseName,
        activity: activity,
        formatter: formatter,
        initialDurationSeconds: initialDurationSeconds,
        initialDistance: initialDistance,
      ),
    ),
  );
}

class _CardioEntrySheet extends StatefulWidget {
  const _CardioEntrySheet({
    required this.exerciseName,
    required this.activity,
    required this.formatter,
    this.initialDurationSeconds,
    this.initialDistance,
  });

  final String exerciseName;
  final CardioActivity? activity;
  final UnitFormatter formatter;
  final int? initialDurationSeconds;
  final double? initialDistance;

  @override
  State<_CardioEntrySheet> createState() => _CardioEntrySheetState();
}

class _CardioEntrySheetState extends State<_CardioEntrySheet> {
  final _hours = TextEditingController();
  final _minutes = TextEditingController();
  final _seconds = TextEditingController();
  final _distance = TextEditingController();
  final _incline = TextEditingController();
  final _resistance = TextEditingController();
  final _avgHr = TextEditingController();
  final _maxHr = TextEditingController();
  final _calories = TextEditingController();
  final _elevation = TextEditingController();
  final _notes = TextEditingController();

  String? _error;

  late final Set<CardioField> _fields = cardioFieldsFor(widget.activity);

  @override
  void initState() {
    super.initState();
    final duration = widget.initialDurationSeconds;
    if (duration != null && duration > 0) {
      _hours.text = duration >= 3600 ? '${duration ~/ 3600}' : '';
      _minutes.text = '${(duration % 3600) ~/ 60}';
      _seconds.text = '${duration % 60}';
    }
    if (widget.initialDistance != null) {
      _distance.text = _trim(widget.initialDistance!);
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
    for (final c in [
      _hours,
      _minutes,
      _seconds,
      _distance,
      _incline,
      _resistance,
      _avgHr,
      _maxHr,
      _calories,
      _elevation,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pace = _livePace();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exerciseName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Text('Duration', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _numberField(_hours, 'hh')),
                const SizedBox(width: 8),
                Expanded(child: _numberField(_minutes, 'mm')),
                const SizedBox(width: 8),
                Expanded(child: _numberField(_seconds, 'ss')),
              ],
            ),

            if (_fields.contains(CardioField.distance)) ...[
              const SizedBox(height: 12),
              _decimalField(
                _distance,
                'Distance',
                suffix: widget.formatter.distanceSuffix,
              ),
            ],

            if (pace != null) ...[
              const SizedBox(height: 8),
              Text(
                'Pace: ${widget.formatter.formatPace(pace)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            if (_fields.contains(CardioField.incline)) ...[
              const SizedBox(height: 12),
              _decimalField(_incline, 'Incline', suffix: '%'),
            ],
            if (_fields.contains(CardioField.resistance)) ...[
              const SizedBox(height: 12),
              _numberField(_resistance, 'Resistance level'),
            ],
            if (_fields.contains(CardioField.elevation)) ...[
              const SizedBox(height: 12),
              _decimalField(
                _elevation,
                'Elevation gain',
                suffix: widget.formatter.isMetric ? 'm' : 'ft',
              ),
            ],
            if (_fields.contains(CardioField.heartRate)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _numberField(_avgHr, 'Avg HR')),
                  const SizedBox(width: 12),
                  Expanded(child: _numberField(_maxHr, 'Max HR')),
                ],
              ),
            ],
            if (_fields.contains(CardioField.calories)) ...[
              const SizedBox(height: 12),
              _numberField(_calories, 'Calories'),
            ],

            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],

            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _decimalField(
    TextEditingController controller,
    String label, {
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  int get _durationSeconds {
    final h = int.tryParse(_hours.text.trim()) ?? 0;
    final m = int.tryParse(_minutes.text.trim()) ?? 0;
    final s = int.tryParse(_seconds.text.trim()) ?? 0;
    return h * 3600 + m * 60 + s;
  }

  /// Shows pace as the user types, so a mistyped distance is obvious before
  /// saving.
  double? _livePace() {
    if (!_fields.contains(CardioField.distance)) return null;
    final distance = double.tryParse(_distance.text.trim());
    if (distance == null || distance <= 0) return null;

    return Units.paceSecPerKm(
      durationSeconds: _durationSeconds,
      distanceMeters: widget.formatter.distanceToMeters(distance),
    );
  }

  void _submit() {
    if (_durationSeconds <= 0) {
      setState(() => _error = 'Enter how long the activity lasted');
      return;
    }

    final elevation = double.tryParse(_elevation.text.trim());

    Navigator.of(context).pop(
      CardioEntryResult(
        durationSeconds: _durationSeconds,
        distance: double.tryParse(_distance.text.trim()),
        inclinePercent: double.tryParse(_incline.text.trim()),
        resistanceLevel: int.tryParse(_resistance.text.trim()),
        avgHeartRate: int.tryParse(_avgHr.text.trim()),
        maxHeartRate: int.tryParse(_maxHr.text.trim()),
        calories: int.tryParse(_calories.text.trim()),
        // Elevation is entered in feet for imperial users but stored in metres.
        elevationGain: elevation == null
            ? null
            : (widget.formatter.isMetric ? elevation : elevation * 0.3048),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }
}
