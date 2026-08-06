/// A structured cardio workout: intervals, fartlek, tempo repeats, pyramids.
///
/// The whole thing is stored as JSON in `plan_items.intervals_json`, because it
/// is only ever read as a unit — nothing queries "all plans containing a 400 m
/// repeat". Values here are **canonical** (seconds, meters, seconds per
/// kilometre); the plan file may express them in miles, and the parser converts
/// on the way in.
///
/// The decoder also accepts the original flat `{repeat, workSeconds,
/// restSeconds}` shape, so plans written against the first version of the file
/// format still open.
library;

import 'dart:convert';

import '../../core/units/pace.dart';
import '../../core/units/unit_system.dart';

/// One leg of a segment — the hard part, or the recovery between reps.
///
/// A leg is defined by any two of duration, distance and pace; the third is
/// derived. "90 seconds at 4:00/km" and "400 m at 4:00/km" are both complete.
class RunEffort {
  const RunEffort({
    this.durationSeconds,
    this.distanceMeters,
    this.paceSecPerKm,
  }) : assert(
         durationSeconds == null || durationSeconds > 0,
         'A leg with zero duration is not a leg',
       );

  final int? durationSeconds;
  final double? distanceMeters;
  final double? paceSecPerKm;

  /// True when this leg prescribes nothing at all.
  bool get isEmpty =>
      durationSeconds == null && distanceMeters == null && paceSecPerKm == null;

  /// How long this leg takes, derived from distance and pace when no duration
  /// was given. Null when it cannot be known.
  int? get effectiveDurationSeconds {
    if (durationSeconds != null) return durationSeconds;
    if (distanceMeters == null || paceSecPerKm == null) return null;
    return Pace.durationSeconds(
      distanceMeters: distanceMeters!,
      paceSecPerKm: paceSecPerKm!,
    );
  }

  /// How far this leg covers, derived from duration and pace when no distance
  /// was given. Null when it cannot be known.
  double? get effectiveDistanceMeters {
    if (distanceMeters != null) return distanceMeters;
    if (durationSeconds == null || paceSecPerKm == null) return null;
    return Pace.distanceMeters(
      durationSeconds: durationSeconds!,
      paceSecPerKm: paceSecPerKm!,
    );
  }

  /// `400 m @ 4:30 /km`, or `90s` when only a duration is prescribed.
  String describe(UnitFormatter formatter) {
    final parts = <String>[
      if (distanceMeters != null)
        formatter.formatDistance(distanceMeters!)
      else if (durationSeconds != null)
        UnitFormatter.formatDuration(durationSeconds!),
      if (distanceMeters != null && durationSeconds != null)
        'in ${UnitFormatter.formatDuration(durationSeconds!)}',
      if (paceSecPerKm != null) '@ ${formatter.formatPace(paceSecPerKm!)}',
    ];
    return parts.isEmpty ? 'unspecified' : parts.join(' ');
  }

  Map<String, Object?> toJson() => {
    if (durationSeconds != null) 'seconds': durationSeconds,
    if (distanceMeters != null) 'meters': distanceMeters,
    if (paceSecPerKm != null) 'paceSecPerKm': paceSecPerKm,
  };

  static RunEffort? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final effort = RunEffort(
      durationSeconds: _positiveInt(raw['seconds']),
      distanceMeters: _positiveDouble(raw['meters']),
      paceSecPerKm: _positiveDouble(raw['paceSecPerKm']),
    );
    return effort.isEmpty ? null : effort;
  }

  RunEffort copyWith({
    int? durationSeconds,
    double? distanceMeters,
    double? paceSecPerKm,
    bool clearDuration = false,
    bool clearDistance = false,
    bool clearPace = false,
  }) => RunEffort(
    durationSeconds: clearDuration
        ? null
        : (durationSeconds ?? this.durationSeconds),
    distanceMeters: clearDistance
        ? null
        : (distanceMeters ?? this.distanceMeters),
    paceSecPerKm: clearPace ? null : (paceSecPerKm ?? this.paceSecPerKm),
  );
}

/// A repeated work/recovery pair. `6 × (400 m hard, 200 m jog)` is one segment.
class RunSegment {
  const RunSegment({
    required this.work,
    this.recovery,
    this.repeat = 1,
    this.label,
  }) : assert(repeat >= 1, 'A segment runs at least once');

  final String? label;
  final int repeat;
  final RunEffort work;

  /// Null for a straight block such as a 10-minute warm-up.
  final RunEffort? recovery;

  /// Total time for every repetition, including recoveries. Null when any leg's
  /// duration is indeterminate — a partial total would read as fact.
  int? get totalDurationSeconds {
    final workTime = work.effectiveDurationSeconds;
    if (workTime == null) return null;
    if (recovery == null) return workTime * repeat;

    final recoveryTime = recovery!.effectiveDurationSeconds;
    if (recoveryTime == null) return null;
    return (workTime + recoveryTime) * repeat;
  }

  /// Total distance for every repetition, including recoveries.
  double? get totalDistanceMeters {
    final workDistance = work.effectiveDistanceMeters;
    if (workDistance == null) return null;
    if (recovery == null) return workDistance * repeat;

    final recoveryDistance = recovery!.effectiveDistanceMeters;
    if (recoveryDistance == null) return null;
    return (workDistance + recoveryDistance) * repeat;
  }

  /// `6 × 400 m @ 4:30 /km, 2:00 recovery`.
  String describe(UnitFormatter formatter) {
    final buffer = StringBuffer();
    if (repeat > 1) buffer.write('$repeat × ');
    buffer.write(work.describe(formatter));
    if (recovery != null) {
      buffer.write(', ${recovery!.describe(formatter)} recovery');
    }
    return buffer.toString();
  }

  Map<String, Object?> toJson() => {
    if (label != null) 'label': label,
    'repeat': repeat,
    'work': work.toJson(),
    if (recovery != null) 'recovery': recovery!.toJson(),
  };

  /// Accepts both the canonical shape and the original flat one.
  static RunSegment? fromJson(Object? raw) {
    if (raw is! Map) return null;

    final label = raw['label'] is String ? raw['label'] as String : null;
    final repeat = _positiveInt(raw['repeat']) ?? 1;

    // The original format: {repeat, workSeconds, restSeconds}.
    if (raw['work'] == null && raw['workSeconds'] != null) {
      final workSeconds = _positiveInt(raw['workSeconds']);
      if (workSeconds == null) return null;
      final restSeconds = _positiveInt(raw['restSeconds']);
      return RunSegment(
        label: label,
        repeat: repeat,
        work: RunEffort(durationSeconds: workSeconds),
        recovery: restSeconds == null
            ? null
            : RunEffort(durationSeconds: restSeconds),
      );
    }

    final work = RunEffort.fromJson(raw['work']);
    if (work == null) return null;
    return RunSegment(
      label: label,
      repeat: repeat,
      work: work,
      recovery: RunEffort.fromJson(raw['recovery']),
    );
  }

  RunSegment copyWith({
    String? label,
    int? repeat,
    RunEffort? work,
    RunEffort? recovery,
    bool clearLabel = false,
    bool clearRecovery = false,
  }) => RunSegment(
    label: clearLabel ? null : (label ?? this.label),
    repeat: repeat ?? this.repeat,
    work: work ?? this.work,
    recovery: clearRecovery ? null : (recovery ?? this.recovery),
  );
}

/// An ordered list of segments, plus the totals the editor shows as you build.
class RunWorkout {
  const RunWorkout(this.segments);

  static const RunWorkout empty = RunWorkout([]);

  final List<RunSegment> segments;

  bool get isEmpty => segments.isEmpty;

  bool get isNotEmpty => segments.isNotEmpty;

  /// Total time across every segment, or null if any segment is indeterminate.
  int? get totalDurationSeconds {
    var total = 0;
    for (final segment in segments) {
      final duration = segment.totalDurationSeconds;
      if (duration == null) return null;
      total += duration;
    }
    return segments.isEmpty ? null : total;
  }

  /// Total distance across every segment, or null if any is indeterminate.
  double? get totalDistanceMeters {
    var total = 0.0;
    for (final segment in segments) {
      final distance = segment.totalDistanceMeters;
      if (distance == null) return null;
      total += distance;
    }
    return segments.isEmpty ? null : total;
  }

  /// The average pace implied by the totals, when both are known.
  double? get averagePaceSecPerKm {
    final duration = totalDurationSeconds;
    final distance = totalDistanceMeters;
    if (duration == null || distance == null) return null;
    return Pace.secPerKm(durationSeconds: duration, distanceMeters: distance);
  }

  /// `5 segments · 42:00 · 8.4 km`, for a one-line prescription summary.
  String describe(UnitFormatter formatter) {
    if (isEmpty) return 'No segments';
    final duration = totalDurationSeconds;
    final distance = totalDistanceMeters;
    return [
      '${segments.length} segment${segments.length == 1 ? '' : 's'}',
      if (duration != null) UnitFormatter.formatDuration(duration),
      if (distance != null) formatter.formatDistance(distance),
    ].join(' · ');
  }

  /// The stored representation, or null when there is nothing to store — so an
  /// emptied builder clears the column rather than writing `[]`.
  String? encode() => isEmpty ? null : jsonEncode(toJson());

  List<Object?> toJson() => [for (final s in segments) s.toJson()];

  /// Never throws: malformed or unreadable JSON decodes to an empty workout, on
  /// the grounds that a plan that will not open is worse than one missing its
  /// interval detail.
  static RunWorkout decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return empty;

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return empty;
    }
    if (decoded is! List) return empty;

    // Unreadable segments are dropped rather than failing the whole workout.
    return RunWorkout([for (final item in decoded) ?RunSegment.fromJson(item)]);
  }
}

int? _positiveInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value <= 0 ? null : value;
}

double? _positiveDouble(Object? raw) {
  final value = raw is num
      ? raw.toDouble()
      : double.tryParse(raw?.toString() ?? '');
  return value == null || value <= 0 || !value.isFinite ? null : value;
}
