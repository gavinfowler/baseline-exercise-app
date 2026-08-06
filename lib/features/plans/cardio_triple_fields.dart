import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units/pace.dart';
import '../../core/units/unit_system.dart';

/// Duration, distance and pace, wired so that filling in any two fills in the
/// third.
///
/// The field that gets recomputed is always the one the user touched **least**
/// recently. Enter a 10:00 mile pace and 10 minutes and the distance becomes a
/// mile; change the distance afterwards and the duration follows, because pace
/// was the more recent of the two remaining edits. The field being typed in is
/// never the one rewritten, so the cursor is never yanked.
class CardioTripleFields extends StatefulWidget {
  const CardioTripleFields({
    required this.formatter,
    required this.onChanged,
    this.initial = const CardioTriple(),
    this.durationLabel = 'Duration',
    this.distanceLabel = 'Distance',
    this.paceLabel = 'Pace',
    this.showPace = true,
    this.dense = false,
    super.key,
  });

  final CardioTriple initial;
  final UnitFormatter formatter;
  final ValueChanged<CardioTriple> onChanged;

  final String durationLabel;
  final String distanceLabel;
  final String paceLabel;

  /// Hidden for activities where a pace is meaningless, such as a stair
  /// climber. The arithmetic still runs; there is simply nothing to solve for.
  final bool showPace;

  final bool dense;

  @override
  State<CardioTripleFields> createState() => _CardioTripleFieldsState();
}

class _CardioTripleFieldsState extends State<CardioTripleFields> {
  final _duration = TextEditingController();
  final _distance = TextEditingController();
  final _pace = TextEditingController();

  /// Most recently edited first. Seeded in display order so an untouched form
  /// solves for pace, which is what a user filling in duration then distance
  /// expects.
  final List<CardioField> _touched = [
    CardioField.duration,
    CardioField.distance,
    CardioField.pace,
  ];

  @override
  void initState() {
    super.initState();
    _write(widget.initial, skip: null);
  }

  @override
  void dispose() {
    _duration.dispose();
    _distance.dispose();
    _pace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = SizedBox(height: widget.dense ? 8 : 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                controller: _duration,
                label: widget.durationLabel,
                hint: 'mm:ss',
                allowColon: true,
                onChanged: () => _recalculate(CardioField.duration),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                controller: _distance,
                label: widget.distanceLabel,
                suffix: widget.formatter.distanceSuffix,
                onChanged: () => _recalculate(CardioField.distance),
              ),
            ),
          ],
        ),
        if (widget.showPace) ...[
          gap,
          _field(
            controller: _pace,
            label: widget.paceLabel,
            hint: 'mm:ss',
            suffix: widget.formatter.paceSuffix,
            allowColon: true,
            onChanged: () => _recalculate(CardioField.pace),
          ),
          const SizedBox(height: 6),
          Text(
            'Fill in any two and the third is worked out for you.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required VoidCallback onChanged,
    String? hint,
    String? suffix,
    bool allowColon = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowColon ? RegExp(r'[0-9:]') : RegExp(r'[0-9.]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: widget.dense,
      ),
      onChanged: (_) => onChanged(),
    );
  }

  /// Reads every field, solves for the stalest one, and reports the result.
  void _recalculate(CardioField edited) {
    _touched
      ..remove(edited)
      ..insert(0, edited);

    final entered = _read();
    // The stalest field is last in the list, and can never be the one being
    // typed in — that one was just moved to the front.
    final target = _touched.last;
    final solved = target == CardioField.pace && !widget.showPace
        ? entered
        : entered.solveFor(target);

    _write(solved, skip: edited);
    widget.onChanged(solved);
  }

  CardioTriple _read() {
    final pace = UnitFormatter.parseDuration(_pace.text);
    final distance = double.tryParse(_distance.text.trim());

    return CardioTriple(
      durationSeconds: UnitFormatter.parseDuration(_duration.text),
      distanceMeters: distance == null || distance <= 0
          ? null
          : widget.formatter.distanceToMeters(distance),
      // The user types a pace per mile when they are on imperial; storage is
      // always per kilometre.
      paceSecPerKm: pace == null
          ? null
          : (widget.formatter.isMetric
                ? pace.toDouble()
                : Units.secPerMileToSecPerKm(pace.toDouble())),
    );
  }

  /// Writes canonical values into the fields, leaving [skip] alone so a field
  /// mid-edit is never reformatted under the cursor.
  void _write(CardioTriple triple, {required CardioField? skip}) {
    if (skip != CardioField.duration && triple.durationSeconds != null) {
      _duration.text = UnitFormatter.formatDuration(triple.durationSeconds!);
    }
    if (skip != CardioField.distance && triple.distanceMeters != null) {
      _distance.text = widget.formatter.formatDistance(
        triple.distanceMeters!,
        withSuffix: false,
      );
    }
    if (skip != CardioField.pace && triple.paceSecPerKm != null) {
      _pace.text = widget.formatter.formatPace(
        triple.paceSecPerKm!,
        withSuffix: false,
      );
    }
  }
}
