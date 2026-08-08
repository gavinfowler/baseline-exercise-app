import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units/pace.dart' show CardioTriple;
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/cardio_fields.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/run_segment.dart';
import 'cardio_triple_fields.dart';
import 'run_builder_screen.dart';

/// A cardio prescription entered in the plan editor, already in canonical units.
///
/// See [StrengthItemResult] in `strength_item_screen.dart` for why the two are
/// separate types.
class CardioItemResult {
  const CardioItemResult({
    this.durationSeconds,
    this.distanceMeters,
    this.paceSecPerKm,
    this.inclinePercent,
    this.resistanceLevel,
    this.intervalsJson,
  });

  final int? durationSeconds;
  final double? distanceMeters;
  final double? paceSecPerKm;
  final double? inclinePercent;
  final int? resistanceLevel;

  /// The encoded [RunWorkout] for a structured session, or null for a steady
  /// effort.
  final String? intervalsJson;
}

/// Opens the cardio prescription editor as a full screen.
Future<CardioItemResult?> showCardioItemEditor(
  BuildContext context, {
  required ExerciseRow exercise,
  required UnitFormatter formatter,
  PlanItemRow? existing,
}) {
  return Navigator.of(context).push<CardioItemResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => CardioItemScreen(
        exercise: exercise,
        formatter: formatter,
        existing: existing,
      ),
    ),
  );
}

/// Prescribes one cardio effort: either a steady piece, or a structured session
/// built from segments.
///
/// A full screen rather than a bottom sheet, which is what makes room for the
/// incline and resistance targets. Those columns have existed on `PlanItems`
/// since the first schema and the plan-file parser has always read them, but the
/// shared sheet had nowhere to put them, so no plan built in the app could ever
/// set one.
class CardioItemScreen extends StatefulWidget {
  const CardioItemScreen({
    required this.exercise,
    required this.formatter,
    this.existing,
    super.key,
  });

  final ExerciseRow exercise;
  final UnitFormatter formatter;
  final PlanItemRow? existing;

  @override
  State<CardioItemScreen> createState() => _CardioItemScreenState();
}

class _CardioItemScreenState extends State<CardioItemScreen> {
  final _incline = TextEditingController();
  final _resistance = TextEditingController();

  /// The steady-effort prescription: duration, distance and pace, any two of
  /// which determine the third.
  CardioTriple _cardio = const CardioTriple();

  /// The structured prescription. Non-empty means this item is an interval
  /// session and the steady fields are ignored.
  RunWorkout _workout = RunWorkout.empty;

  bool _structured = false;

  CardioActivity get _activity =>
      widget.exercise.cardioActivity ?? CardioActivity.other;

  late final Set<CardioField> _fields = cardioFieldsFor(_activity);

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing == null) return;

    _cardio = CardioTriple(
      durationSeconds: existing.targetDurationSeconds,
      distanceMeters: existing.targetDistanceMeters,
      paceSecPerKm: existing.targetPaceSecPerKm,
    );
    _workout = RunWorkout.decode(existing.intervalsJson);
    _structured = _workout.isNotEmpty;

    _incline.text = existing.targetInclinePercent?.toString() ?? '';
    _resistance.text = existing.targetResistanceLevel?.toString() ?? '';
  }

  @override
  void dispose() {
    _incline.dispose();
    _resistance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FilledButton(onPressed: _submit, child: const Text('Save')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run, size: 20),
              const SizedBox(width: 8),
              Text(_activity.label, style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 20),

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
          const SizedBox(height: 20),

          if (_structured)
            ..._structuredFields(theme)
          else
            CardioTripleFields(
              formatter: widget.formatter,
              initial: _cardio,
              showPace: _activity.tracksPace,
              durationLabel: 'Target duration',
              distanceLabel: 'Target distance',
              paceLabel: 'Target pace',
              onChanged: (value) => _cardio = value,
            ),

          // Shown for whichever of the two the activity actually has, so a
          // swimmer is never asked for a treadmill incline.
          if (_fields.contains(CardioField.incline) ||
              _fields.contains(CardioField.resistance)) ...[
            const SizedBox(height: 24),
            Text('Machine settings', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Optional. Recorded with the prescription so the same session can '
              'be repeated exactly.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_fields.contains(CardioField.incline))
              TextField(
                controller: _incline,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Target incline',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_fields.contains(CardioField.incline) &&
                _fields.contains(CardioField.resistance))
              const SizedBox(height: 12),
            if (_fields.contains(CardioField.resistance))
              TextField(
                controller: _resistance,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Target resistance level',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  List<Widget> _structuredFields(ThemeData theme) {
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
    // A structured workout carries its own totals, so they are written to the
    // steady fields too. History and the plan list can then summarise any cardio
    // item without decoding the segments.
    final workout = _structured ? _workout : RunWorkout.empty;
    final cardio = workout.isEmpty
        ? _cardio
        : CardioTriple(
            durationSeconds: workout.totalDurationSeconds,
            distanceMeters: workout.totalDistanceMeters,
            paceSecPerKm: workout.averagePaceSecPerKm,
          );

    Navigator.of(context).pop(
      CardioItemResult(
        durationSeconds: cardio.durationSeconds,
        distanceMeters: cardio.distanceMeters,
        paceSecPerKm: cardio.paceSecPerKm,
        inclinePercent: _fields.contains(CardioField.incline)
            ? double.tryParse(_incline.text.trim())
            : null,
        resistanceLevel: _fields.contains(CardioField.resistance)
            ? int.tryParse(_resistance.text.trim())
            : null,
        intervalsJson: workout.encode(),
      ),
    );
  }
}
