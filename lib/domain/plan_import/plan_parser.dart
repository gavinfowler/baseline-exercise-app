import 'dart:convert';

import '../../core/result.dart';
import '../../core/units/pace.dart';
import '../../core/units/unit_system.dart';
import '../models/enums.dart';
import '../models/run_segment.dart';
import 'plan_dto.dart';

/// The plan-file format version this build understands.
const String kSupportedPlanSchemaVersion = '1.0';

/// Turns plan-file JSON into a [PlanFileDto], or into a list of problems.
///
/// Every problem carries an RFC 6901 JSON Pointer, so the import screen can tell
/// the user exactly which part of their file is wrong. Parsing deliberately
/// collects **all** issues rather than stopping at the first — a person fixing a
/// generated plan should not have to re-upload once per mistake.
///
/// Measurements are converted to canonical units here, using the file's own
/// `units` declaration, so nothing downstream deals with pounds or miles.
class PlanParser {
  const PlanParser();

  Result<PlanFileDto> parse(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      return Err.single(
        ValidationIssue(
          pointer: '',
          message: 'This is not valid JSON: ${e.message}',
        ),
      );
    }

    if (decoded is! Map<String, Object?>) {
      return Err.single(
        const ValidationIssue(
          pointer: '',
          message: 'The file must contain a JSON object at the top level.',
        ),
      );
    }

    final issues = <ValidationIssue>[];
    final version = decoded['schemaVersion'];

    if (version == null) {
      issues.add(
        const ValidationIssue(
          pointer: '/schemaVersion',
          message: 'Missing "schemaVersion". Expected "1.0".',
        ),
      );
    } else if (version != kSupportedPlanSchemaVersion) {
      issues.add(
        ValidationIssue(
          pointer: '/schemaVersion',
          message:
              'Unsupported schemaVersion "$version". This app understands '
              '"$kSupportedPlanSchemaVersion".',
        ),
      );
    }

    final planJson = decoded['plan'];
    if (planJson is! Map<String, Object?>) {
      issues.add(
        const ValidationIssue(
          pointer: '/plan',
          message: 'Missing the "plan" object.',
        ),
      );
      return Err(issues);
    }

    final plan = _parsePlan(planJson, '/plan', issues);
    if (plan == null || issues.any((i) => i.isError)) return Err(issues);

    return Ok(
      PlanFileDto(schemaVersion: kSupportedPlanSchemaVersion, plan: plan),
    );
  }

  PlanDto? _parsePlan(
    Map<String, Object?> json,
    String at,
    List<ValidationIssue> issues,
  ) {
    final name = _string(json['name'], '$at/name', issues, required: true);
    final mode = PlanMode.fromWire(json['mode'] as String?);
    if (mode == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/mode',
          message:
              'mode must be "static" or "periodized" (got '
              '${_describe(json['mode'])}).',
        ),
      );
    }

    final unitsRaw = json['units'] as String? ?? 'metric';
    if (unitsRaw != 'metric' && unitsRaw != 'imperial') {
      issues.add(
        ValidationIssue(
          pointer: '$at/units',
          message: 'units must be "metric" or "imperial" (got "$unitsRaw").',
        ),
      );
    }
    final units = unitsRaw == 'imperial'
        ? UnitSystem.imperial
        : UnitSystem.metric;

    final scheduleType =
        ScheduleType.fromWire(json['scheduleType'] as String?) ??
        ScheduleType.sequential;
    if (json['scheduleType'] != null &&
        ScheduleType.fromWire(json['scheduleType'] as String?) == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/scheduleType',
          message: 'scheduleType must be "weekly" or "sequential".',
        ),
      );
    }

    final durationWeeks = _int(
      json['durationWeeks'],
      '$at/durationWeeks',
      issues,
    );
    // The defining constraint of a periodized plan is that it spans a fixed
    // period, so this is not optional for that mode.
    if (mode == PlanMode.periodized && durationWeeks == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/durationWeeks',
          message:
              'A periodized plan must declare durationWeeks — it is what makes '
              'the program finite.',
        ),
      );
    }

    DateTime? startDate;
    final startRaw = json['startDate'];
    if (startRaw != null) {
      startDate = DateTime.tryParse(startRaw.toString());
      if (startDate == null) {
        issues.add(
          ValidationIssue(
            pointer: '$at/startDate',
            message: 'startDate must be an ISO date such as "2026-08-03".',
          ),
        );
      }
    }

    final daysJson = json['days'];
    if (daysJson is! List || daysJson.isEmpty) {
      issues.add(
        ValidationIssue(
          pointer: '$at/days',
          message: 'A plan needs at least one day.',
        ),
      );
      return null;
    }

    final days = <PlanDayDto>[];
    for (var i = 0; i < daysJson.length; i++) {
      final dayJson = daysJson[i];
      final pointer = '$at/days/$i';
      if (dayJson is! Map<String, Object?>) {
        issues.add(
          ValidationIssue(
            pointer: pointer,
            message: 'Each day must be an object.',
          ),
        );
        continue;
      }
      final day = _parseDay(dayJson, pointer, units, issues);
      if (day != null) days.add(day);
    }

    if (name == null || mode == null || days.isEmpty) return null;

    return PlanDto(
      name: name,
      description: json['description'] as String?,
      mode: mode,
      scheduleType: scheduleType,
      startDate: startDate,
      durationWeeks: durationWeeks,
      days: days,
    );
  }

  PlanDayDto? _parseDay(
    Map<String, Object?> json,
    String at,
    UnitSystem units,
    List<ValidationIssue> issues,
  ) {
    final label = _string(json['label'], '$at/label', issues, required: true);

    final dayOfWeekRaw = json['dayOfWeek'] as String?;
    final dayOfWeek = Weekday.fromWire(dayOfWeekRaw);
    if (dayOfWeekRaw != null && dayOfWeek == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/dayOfWeek',
          message: 'dayOfWeek must be a lowercase weekday such as "monday".',
        ),
      );
    }

    final blocksJson = json['blocks'];
    if (blocksJson is! List || blocksJson.isEmpty) {
      issues.add(
        ValidationIssue(
          pointer: '$at/blocks',
          message: 'A day needs at least one block of exercises.',
        ),
      );
      return null;
    }

    final blocks = <PlanBlockDto>[];
    for (var i = 0; i < blocksJson.length; i++) {
      final blockJson = blocksJson[i];
      final pointer = '$at/blocks/$i';
      if (blockJson is! Map<String, Object?>) {
        issues.add(
          ValidationIssue(
            pointer: pointer,
            message: 'Each block must be an object.',
          ),
        );
        continue;
      }
      final block = _parseBlock(blockJson, pointer, units, issues);
      if (block != null) blocks.add(block);
    }

    if (label == null || blocks.isEmpty) return null;

    return PlanDayDto(
      label: label,
      weekNumber: _int(json['weekNumber'], '$at/weekNumber', issues),
      dayOfWeek: dayOfWeek,
      notes: json['notes'] as String?,
      blocks: blocks,
    );
  }

  PlanBlockDto? _parseBlock(
    Map<String, Object?> json,
    String at,
    UnitSystem units,
    List<ValidationIssue> issues,
  ) {
    final kindRaw = json['kind'] as String?;
    final kind = BlockKind.fromWire(kindRaw) ?? BlockKind.single;
    if (kindRaw != null && BlockKind.fromWire(kindRaw) == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/kind',
          message: 'kind must be "single", "superset" or "circuit".',
        ),
      );
    }

    final rounds = _int(json['rounds'], '$at/rounds', issues, min: 1) ?? 1;
    final restBetween =
        _int(
          json['restBetweenExercisesSeconds'],
          '$at/restBetweenExercisesSeconds',
          issues,
          min: 0,
        ) ??
        0;
    final restAfter =
        _int(
          json['restAfterRoundSeconds'],
          '$at/restAfterRoundSeconds',
          issues,
          min: 0,
        ) ??
        90;

    final exercisesJson = json['exercises'];
    if (exercisesJson is! List || exercisesJson.isEmpty) {
      issues.add(
        ValidationIssue(
          pointer: '$at/exercises',
          message: 'A block needs at least one exercise.',
        ),
      );
      return null;
    }

    final exercises = <PlanExerciseDto>[];
    for (var i = 0; i < exercisesJson.length; i++) {
      final exerciseJson = exercisesJson[i];
      final pointer = '$at/exercises/$i';
      if (exerciseJson is! Map<String, Object?>) {
        issues.add(
          ValidationIssue(
            pointer: pointer,
            message: 'Each exercise must be an object.',
          ),
        );
        continue;
      }
      final exercise = _parseExercise(exerciseJson, pointer, units, issues);
      if (exercise != null) exercises.add(exercise);
    }

    // A "superset" of one is a contradiction, and almost always means the
    // generator emitted the wrong kind.
    if (kind.isGrouped && exercises.length < 2) {
      issues.add(
        ValidationIssue(
          pointer: '$at/exercises',
          message:
              'A ${kind.wireName} must contain at least two exercises. Use '
              '"single" for one exercise.',
        ),
      );
    }

    if (exercises.isEmpty) return null;

    return PlanBlockDto(
      kind: kind,
      label: json['label'] as String?,
      rounds: rounds,
      restBetweenExercisesSeconds: restBetween,
      restAfterRoundSeconds: restAfter,
      exercises: exercises,
    );
  }

  PlanExerciseDto? _parseExercise(
    Map<String, Object?> json,
    String at,
    UnitSystem units,
    List<ValidationIssue> issues,
  ) {
    final name = _string(json['name'], '$at/name', issues, required: true);

    final type = ExerciseType.fromWire(json['type'] as String?);
    if (type == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/type',
          message:
              'type must be "strength" or "cardio" (got '
              '${_describe(json['type'])}).',
        ),
      );
      return null;
    }

    final formatter = UnitFormatter(units);

    if (type == ExerciseType.strength) {
      return _parseStrength(json, at, name, formatter, issues);
    }
    return _parseCardio(json, at, name, formatter, issues);
  }

  PlanExerciseDto? _parseStrength(
    Map<String, Object?> json,
    String at,
    String? name,
    UnitFormatter formatter,
    List<ValidationIssue> issues,
  ) {
    for (final field in const ['activity', 'durationSeconds', 'distance']) {
      if (json[field] != null) {
        issues.add(
          ValidationIssue(
            pointer: '$at/$field',
            message:
                '"$field" is a cardio field but this exercise is strength.',
          ),
        );
      }
    }

    final reps = _int(json['reps'], '$at/reps', issues, min: 1);
    final weightRaw = _double(json['weight'], '$at/weight', issues, min: 0);

    final modeRaw = json['weightMode'] as String?;
    final weightMode = WeightMode.fromWire(modeRaw) ?? WeightMode.absolute;
    if (modeRaw != null && WeightMode.fromWire(modeRaw) == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/weightMode',
          message:
              'weightMode must be one of absolute, baseline, baselinePlus, '
              'baselinePercent.',
        ),
      );
    }

    if (weightMode == WeightMode.absolute &&
        weightRaw == null &&
        reps != null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/weight',
          message:
              'An absolute-weight exercise needs a "weight". Use weightMode '
              '"baseline" to track the user\'s own working weight instead.',
          severity: IssueSeverity.warning,
        ),
      );
    }

    if (weightMode == WeightMode.baselinePercent &&
        json['weightPercent'] == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/weightPercent',
          message: 'weightMode "baselinePercent" requires weightPercent.',
        ),
      );
    }

    if (name == null) return null;

    final offsetRaw = _double(json['weightOffset'], '$at/weightOffset', issues);

    return PlanExerciseDto(
      name: name,
      type: ExerciseType.strength,
      notes: json['notes'] as String?,
      reps: reps,
      weightKg: weightRaw == null ? null : formatter.weightToKg(weightRaw),
      weightMode: weightMode,
      weightOffsetKg: offsetRaw == null
          ? null
          : formatter.weightToKg(offsetRaw),
      weightPercent: _double(
        json['weightPercent'],
        '$at/weightPercent',
        issues,
        min: 0,
      ),
      rpe: _double(json['rpe'], '$at/rpe', issues, min: 1, max: 10),
      tempo: json['tempo'] as String?,
      toFailure: json['toFailure'] == true,
    );
  }

  PlanExerciseDto? _parseCardio(
    Map<String, Object?> json,
    String at,
    String? name,
    UnitFormatter formatter,
    List<ValidationIssue> issues,
  ) {
    for (final field in const ['reps', 'weight', 'tempo']) {
      if (json[field] != null) {
        issues.add(
          ValidationIssue(
            pointer: '$at/$field',
            message:
                '"$field" is a strength field but this exercise is cardio.',
          ),
        );
      }
    }

    final activityRaw = json['activity'] as String?;
    final activity = CardioActivity.fromWire(activityRaw);
    if (activityRaw != null && activity == null) {
      issues.add(
        ValidationIssue(
          pointer: '$at/activity',
          message:
              'Unknown activity "$activityRaw". Use one of: '
              '${CardioActivity.values.map((a) => a.wireName).join(', ')}.',
        ),
      );
    }

    final duration = _int(
      json['durationSeconds'],
      '$at/durationSeconds',
      issues,
      min: 1,
    );
    final distanceRaw = _double(
      json['distance'],
      '$at/distance',
      issues,
      min: 0,
    );

    if (duration == null && distanceRaw == null) {
      issues.add(
        ValidationIssue(
          pointer: at,
          message:
              'A cardio exercise needs at least a durationSeconds or a distance '
              'to prescribe anything.',
        ),
      );
    }

    final pace = _parsePace(json['targetPace'], '$at/targetPace', issues);

    if (name == null) return null;

    return PlanExerciseDto(
      name: name,
      type: ExerciseType.cardio,
      notes: json['notes'] as String?,
      activity: activity ?? CardioActivity.other,
      durationSeconds: duration,
      distanceMeters: distanceRaw == null
          ? null
          : formatter.distanceToMeters(distanceRaw),
      paceSecPerKm: pace == null
          ? null
          : (formatter.isMetric ? pace : Units.secPerMileToSecPerKm(pace)),
      inclinePercent: _double(
        json['inclinePercent'],
        '$at/inclinePercent',
        issues,
      ),
      resistanceLevel: _int(
        json['resistanceLevel'],
        '$at/resistanceLevel',
        issues,
        min: 0,
      ),
      intervalsJson: _parseIntervals(
        json['intervals'],
        '$at/intervals',
        formatter,
        issues,
      ),
    );
  }

  /// `"5:30"` becomes 330 seconds, in whatever distance unit the file uses.
  double? _parsePace(Object? raw, String at, List<ValidationIssue> issues) {
    if (raw == null) return null;
    final seconds = Pace.parse(raw.toString());
    if (seconds == null) {
      issues.add(
        ValidationIssue(
          pointer: at,
          message: 'Pace must look like "5:30" (minutes:seconds).',
        ),
      );
    }
    return seconds;
  }

  /// Converts the file's interval list into the canonical [RunWorkout] form.
  ///
  /// The file speaks the plan's own units — a `workDistance` of `0.25` is a
  /// quarter mile in an imperial plan — so this is where structured workouts
  /// become meters and seconds like everything else.
  ///
  /// The original flat `{repeat, workSeconds, restSeconds}` shape is still
  /// accepted, so files written against the first version of the format import
  /// unchanged.
  String? _parseIntervals(
    Object? raw,
    String at,
    UnitFormatter formatter,
    List<ValidationIssue> issues,
  ) {
    if (raw == null) return null;
    if (raw is! List) {
      issues.add(
        ValidationIssue(pointer: at, message: 'intervals must be an array.'),
      );
      return null;
    }

    final segments = <RunSegment>[];

    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map<String, Object?>) {
        issues.add(
          ValidationIssue(
            pointer: '$at/$i',
            message: 'Each interval must be an object.',
          ),
        );
        continue;
      }

      final repeat =
          _int(
            item['repeat'],
            '$at/$i/repeat',
            issues,
            min: 1,
            required: true,
          ) ??
          1;

      final work = _parseEffort(item, '$at/$i', 'work', formatter, issues);
      if (work == null || work.isEmpty) {
        issues.add(
          ValidationIssue(
            pointer: '$at/$i',
            message:
                'Each interval needs a workSeconds or a workDistance to '
                'prescribe anything.',
          ),
        );
        continue;
      }

      final recovery = _parseEffort(
        item,
        '$at/$i',
        'recovery',
        formatter,
        issues,
      );

      segments.add(
        RunSegment(
          label: item['label'] as String?,
          repeat: repeat,
          work: work,
          recovery: recovery != null && recovery.isEmpty ? null : recovery,
        ),
      );
    }

    return RunWorkout(segments).encode();
  }

  /// Reads one leg of an interval.
  ///
  /// The two legs use different key prefixes for readability in the file —
  /// `workSeconds`/`workDistance`/`workPace` against
  /// `restSeconds`/`recoveryDistance`/`recoveryPace`. `restSeconds` keeps its
  /// original name because files in the wild already use it.
  RunEffort? _parseEffort(
    Map<String, Object?> item,
    String at,
    String leg,
    UnitFormatter formatter,
    List<ValidationIssue> issues,
  ) {
    final isWork = leg == 'work';
    final secondsKey = isWork ? 'workSeconds' : 'restSeconds';
    final distanceKey = isWork ? 'workDistance' : 'recoveryDistance';
    final paceKey = isWork ? 'workPace' : 'recoveryPace';

    final seconds = _int(
      item[secondsKey],
      '$at/$secondsKey',
      issues,
      min: 1,
      max: 86400,
    );
    final distance = _double(
      item[distanceKey],
      '$at/$distanceKey',
      issues,
      min: 0,
    );
    final pace = _parsePace(item[paceKey], '$at/$paceKey', issues);

    if (seconds == null && distance == null && pace == null) return null;

    return RunEffort(
      durationSeconds: seconds,
      distanceMeters: distance == null || distance <= 0
          ? null
          : formatter.distanceToMeters(distance),
      paceSecPerKm: pace == null
          ? null
          : (formatter.isMetric ? pace : Units.secPerMileToSecPerKm(pace)),
    );
  }

  // ------------------------------------------------------------- primitives

  String? _string(
    Object? raw,
    String at,
    List<ValidationIssue> issues, {
    bool required = false,
  }) {
    if (raw == null) {
      if (required) {
        issues.add(
          ValidationIssue(pointer: at, message: 'This field is required.'),
        );
      }
      return null;
    }
    if (raw is! String || raw.trim().isEmpty) {
      issues.add(
        ValidationIssue(pointer: at, message: 'Must be a non-empty string.'),
      );
      return null;
    }
    return raw.trim();
  }

  int? _int(
    Object? raw,
    String at,
    List<ValidationIssue> issues, {
    int? min,
    int? max,
    bool required = false,
  }) {
    if (raw == null) {
      if (required) {
        issues.add(
          ValidationIssue(pointer: at, message: 'This field is required.'),
        );
      }
      return null;
    }
    final value = raw is int ? raw : int.tryParse(raw.toString());
    if (value == null) {
      issues.add(
        ValidationIssue(
          pointer: at,
          message: 'Must be a whole number (got ${_describe(raw)}).',
        ),
      );
      return null;
    }
    if (min != null && value < min) {
      issues.add(
        ValidationIssue(pointer: at, message: 'Must be at least $min.'),
      );
      return null;
    }
    if (max != null && value > max) {
      issues.add(
        ValidationIssue(pointer: at, message: 'Must be at most $max.'),
      );
      return null;
    }
    return value;
  }

  double? _double(
    Object? raw,
    String at,
    List<ValidationIssue> issues, {
    double? min,
    double? max,
  }) {
    if (raw == null) return null;
    final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
    if (value == null) {
      issues.add(
        ValidationIssue(
          pointer: at,
          message: 'Must be a number (got ${_describe(raw)}).',
        ),
      );
      return null;
    }
    if (min != null && value < min) {
      issues.add(
        ValidationIssue(pointer: at, message: 'Must be at least $min.'),
      );
      return null;
    }
    if (max != null && value > max) {
      issues.add(
        ValidationIssue(pointer: at, message: 'Must be at most $max.'),
      );
      return null;
    }
    return value;
  }

  String _describe(Object? value) =>
      value == null ? 'nothing' : '"${value.toString()}"';
}
