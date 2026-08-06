import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../data/db/app_database.dart';
import '../models/enums.dart';

/// Version of the backup file format.
const String kBackupVersion = '1.0';

/// What a restore brought back, for the confirmation message.
class RestoreSummary {
  const RestoreSummary({
    required this.exercises,
    required this.plans,
    required this.sessions,
    required this.strengthSets,
    required this.cardioEntries,
  });

  final int exercises;
  final int plans;
  final int sessions;
  final int strengthSets;
  final int cardioEntries;
}

/// Exports and restores the entire database as a single JSON document.
///
/// This is the only protection against a lost or wiped device, since nothing is
/// ever sent anywhere. The format is written by hand rather than generated so
/// it stays stable across schema changes: renaming a Dart enum constant or a
/// column must not silently invalidate a user's existing backup.
///
/// Rows keep their primary keys so foreign keys stay intact across a restore.
class BackupService {
  BackupService(this._db, {Clock clock = const SystemClock()}) : _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  // -------------------------------------------------------------- exporting

  Future<String> exportToJson() async {
    final data = <String, Object?>{
      'backupVersion': kBackupVersion,
      'exportedAt': _clock.now().toUtc().toIso8601String(),
      'exercises': (await _db.select(_db.exercises).get())
          .map(_exercise)
          .toList(),
      'plans': (await _db.select(_db.plans).get()).map(_plan).toList(),
      'planDays': (await _db.select(_db.planDays).get()).map(_planDay).toList(),
      'planBlocks': (await _db.select(_db.planBlocks).get())
          .map(_planBlock)
          .toList(),
      'planItems': (await _db.select(_db.planItems).get())
          .map(_planItem)
          .toList(),
      'sessions': (await _db.select(_db.sessions).get()).map(_session).toList(),
      'strengthSets': (await _db.select(_db.strengthSets).get())
          .map(_strengthSet)
          .toList(),
      'cardioEntries': (await _db.select(_db.cardioEntries).get())
          .map(_cardioEntry)
          .toList(),
      'cardioSplits': (await _db.select(_db.cardioSplits).get())
          .map(_cardioSplit)
          .toList(),
      'exerciseBaselines': (await _db.select(_db.exerciseBaselines).get())
          .map(_baseline)
          .toList(),
      'personalRecords': (await _db.select(_db.personalRecords).get())
          .map(_record)
          .toList(),
      'settings': {
        for (final row in await _db.select(_db.appSettings).get())
          row.key: row.value,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Map<String, Object?> _exercise(ExerciseRow r) => {
    'id': r.id,
    'name': r.name,
    'nameKey': r.nameKey,
    'type': r.type.wireName,
    'cardioActivity': r.cardioActivity?.wireName,
    'muscleGroup': r.muscleGroup,
    'equipment': r.equipment,
    'notes': r.notes,
    'isCustom': r.isCustom,
    'isArchived': r.isArchived,
    'createdAt': _date(r.createdAt),
    'updatedAt': _date(r.updatedAt),
  };

  Map<String, Object?> _plan(PlanRow r) => {
    'id': r.id,
    'name': r.name,
    'description': r.description,
    'mode': r.mode.wireName,
    'scheduleType': r.scheduleType.wireName,
    'startDate': _dateOrNull(r.startDate),
    'durationWeeks': r.durationWeeks,
    'isActive': r.isActive,
    'source': r.source.wireName,
    'schemaVersion': r.schemaVersion,
    'createdAt': _date(r.createdAt),
    'updatedAt': _date(r.updatedAt),
  };

  Map<String, Object?> _planDay(PlanDayRow r) => {
    'id': r.id,
    'planId': r.planId,
    'orderIndex': r.orderIndex,
    'label': r.label,
    'weekNumber': r.weekNumber,
    'dayOfWeek': r.dayOfWeek?.wireName,
    'notes': r.notes,
  };

  Map<String, Object?> _planBlock(PlanBlockRow r) => {
    'id': r.id,
    'planDayId': r.planDayId,
    'orderIndex': r.orderIndex,
    'kind': r.kind.wireName,
    'label': r.label,
    'rounds': r.rounds,
    'restBetweenExercisesSeconds': r.restBetweenExercisesSeconds,
    'restAfterRoundSeconds': r.restAfterRoundSeconds,
  };

  Map<String, Object?> _planItem(PlanItemRow r) => {
    'id': r.id,
    'planBlockId': r.planBlockId,
    'exerciseId': r.exerciseId,
    'orderIndex': r.orderIndex,
    'targetReps': r.targetReps,
    'targetWeightKg': r.targetWeightKg,
    'weightMode': r.weightMode?.wireName,
    'weightOffsetKg': r.weightOffsetKg,
    'weightPercent': r.weightPercent,
    'rpe': r.rpe,
    'tempo': r.tempo,
    'toFailure': r.toFailure,
    'targetDurationSeconds': r.targetDurationSeconds,
    'targetDistanceMeters': r.targetDistanceMeters,
    'targetPaceSecPerKm': r.targetPaceSecPerKm,
    'targetInclinePercent': r.targetInclinePercent,
    'targetResistanceLevel': r.targetResistanceLevel,
    'intervalsJson': r.intervalsJson,
    'notes': r.notes,
  };

  Map<String, Object?> _session(SessionRow r) => {
    'id': r.id,
    'planId': r.planId,
    'planDayId': r.planDayId,
    'title': r.title,
    'startedAt': _date(r.startedAt),
    'endedAt': _dateOrNull(r.endedAt),
    'status': r.status.wireName,
    'durationSeconds': r.durationSeconds,
    'notes': r.notes,
  };

  Map<String, Object?> _strengthSet(StrengthSetRow r) => {
    'id': r.id,
    'sessionId': r.sessionId,
    'exerciseId': r.exerciseId,
    'planItemId': r.planItemId,
    'groupIndex': r.groupIndex,
    'groupKind': r.groupKind.wireName,
    'groupLabel': r.groupLabel,
    'roundIndex': r.roundIndex,
    'itemIndex': r.itemIndex,
    'plannedReps': r.plannedReps,
    'plannedWeightKg': r.plannedWeightKg,
    'actualReps': r.actualReps,
    'actualWeightKg': r.actualWeightKg,
    'rpe': r.rpe,
    'isWarmup': r.isWarmup,
    'status': r.status.wireName,
    'restTakenSeconds': r.restTakenSeconds,
    'performedAt': _dateOrNull(r.performedAt),
    'notes': r.notes,
  };

  Map<String, Object?> _cardioEntry(CardioEntryRow r) => {
    'id': r.id,
    'sessionId': r.sessionId,
    'exerciseId': r.exerciseId,
    'planItemId': r.planItemId,
    'groupIndex': r.groupIndex,
    'groupKind': r.groupKind.wireName,
    'groupLabel': r.groupLabel,
    'roundIndex': r.roundIndex,
    'itemIndex': r.itemIndex,
    'plannedDurationSeconds': r.plannedDurationSeconds,
    'plannedDistanceMeters': r.plannedDistanceMeters,
    'plannedPaceSecPerKm': r.plannedPaceSecPerKm,
    'actualDurationSeconds': r.actualDurationSeconds,
    'actualDistanceMeters': r.actualDistanceMeters,
    'actualPaceSecPerKm': r.actualPaceSecPerKm,
    'inclinePercent': r.inclinePercent,
    'resistanceLevel': r.resistanceLevel,
    'avgHeartRate': r.avgHeartRate,
    'maxHeartRate': r.maxHeartRate,
    'calories': r.calories,
    'elevationGainMeters': r.elevationGainMeters,
    'status': r.status.wireName,
    'performedAt': _dateOrNull(r.performedAt),
    'notes': r.notes,
  };

  Map<String, Object?> _cardioSplit(CardioSplitRow r) => {
    'id': r.id,
    'cardioEntryId': r.cardioEntryId,
    'splitIndex': r.splitIndex,
    'durationSeconds': r.durationSeconds,
    'distanceMeters': r.distanceMeters,
  };

  Map<String, Object?> _baseline(ExerciseBaselineRow r) => {
    'id': r.id,
    'planId': r.planId,
    'exerciseId': r.exerciseId,
    'reps': r.reps,
    'weightKg': r.weightKg,
    'achievedAt': _date(r.achievedAt),
    'sourceSetId': r.sourceSetId,
  };

  Map<String, Object?> _record(PersonalRecordRow r) => {
    'id': r.id,
    'exerciseId': r.exerciseId,
    'recordType': r.recordType.wireName,
    'reps': r.reps,
    'value': r.value,
    'achievedAt': _date(r.achievedAt),
    'sessionId': r.sessionId,
  };

  String _date(DateTime value) => value.toUtc().toIso8601String();

  String? _dateOrNull(DateTime? value) => value == null ? null : _date(value);

  // -------------------------------------------------------------- restoring

  /// Replaces the entire database with the contents of a backup.
  ///
  /// Destructive by design — this is "restore this device to that backup", not
  /// a merge. Everything happens in one transaction, so a malformed file leaves
  /// the existing data untouched rather than half-deleted.
  Future<RestoreSummary> restoreFromJson(String source) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw BackupFormatException(
        'This is not a valid backup file: ${e.message}',
      );
    }

    if (decoded is! Map<String, Object?>) {
      throw const BackupFormatException(
        'A backup file must contain a JSON object.',
      );
    }

    // Bound to a new local because type promotion of `decoded` does not reach
    // inside the transaction closure below.
    final Map<String, Object?> json = decoded;

    final version = json['backupVersion'];
    if (version != kBackupVersion) {
      throw BackupFormatException(
        'Unsupported backup version "$version". This app reads '
        '"$kBackupVersion".',
      );
    }

    final exercises = _rows(json, 'exercises');
    final plans = _rows(json, 'plans');
    final sessions = _rows(json, 'sessions');
    final strengthSets = _rows(json, 'strengthSets');
    final cardioEntries = _rows(json, 'cardioEntries');

    await _db.transaction(() async {
      // Children first, so foreign keys never dangle mid-delete.
      await _db.delete(_db.cardioSplits).go();
      await _db.delete(_db.personalRecords).go();
      await _db.delete(_db.exerciseBaselines).go();
      await _db.delete(_db.strengthSets).go();
      await _db.delete(_db.cardioEntries).go();
      await _db.delete(_db.sessions).go();
      await _db.delete(_db.planItems).go();
      await _db.delete(_db.planBlocks).go();
      await _db.delete(_db.planDays).go();
      await _db.delete(_db.plans).go();
      await _db.delete(_db.exercises).go();
      await _db.delete(_db.appSettings).go();

      // Parents first on the way back in, for the same reason.
      for (final row in exercises) {
        await _db.into(_db.exercises).insert(_readExercise(row));
      }
      for (final row in plans) {
        await _db.into(_db.plans).insert(_readPlan(row));
      }
      for (final row in _rows(json, 'planDays')) {
        await _db.into(_db.planDays).insert(_readPlanDay(row));
      }
      for (final row in _rows(json, 'planBlocks')) {
        await _db.into(_db.planBlocks).insert(_readPlanBlock(row));
      }
      for (final row in _rows(json, 'planItems')) {
        await _db.into(_db.planItems).insert(_readPlanItem(row));
      }
      for (final row in sessions) {
        await _db.into(_db.sessions).insert(_readSession(row));
      }
      for (final row in strengthSets) {
        await _db.into(_db.strengthSets).insert(_readStrengthSet(row));
      }
      for (final row in cardioEntries) {
        await _db.into(_db.cardioEntries).insert(_readCardioEntry(row));
      }
      for (final row in _rows(json, 'cardioSplits')) {
        await _db.into(_db.cardioSplits).insert(_readCardioSplit(row));
      }
      for (final row in _rows(json, 'exerciseBaselines')) {
        await _db.into(_db.exerciseBaselines).insert(_readBaseline(row));
      }
      for (final row in _rows(json, 'personalRecords')) {
        await _db.into(_db.personalRecords).insert(_readRecord(row));
      }

      final settings = json['settings'];
      if (settings is Map<String, Object?>) {
        for (final entry in settings.entries) {
          await _db
              .into(_db.appSettings)
              .insert(
                AppSettingRow(key: entry.key, value: entry.value.toString()),
              );
        }
      }
    });

    return RestoreSummary(
      exercises: exercises.length,
      plans: plans.length,
      sessions: sessions.length,
      strengthSets: strengthSets.length,
      cardioEntries: cardioEntries.length,
    );
  }

  List<Map<String, Object?>> _rows(Map<String, Object?> json, String key) {
    final raw = json[key];
    if (raw == null) return const [];
    if (raw is! List) {
      throw BackupFormatException('"$key" must be a list.');
    }
    return raw.whereType<Map<String, Object?>>().toList();
  }

  ExercisesCompanion _readExercise(Map<String, Object?> r) =>
      ExercisesCompanion.insert(
        id: Value(_int(r, 'id')!),
        name: _string(r, 'name')!,
        nameKey: _string(r, 'nameKey')!,
        type:
            ExerciseType.fromWire(_string(r, 'type')) ?? ExerciseType.strength,
        cardioActivity: Value(
          CardioActivity.fromWire(_string(r, 'cardioActivity')),
        ),
        muscleGroup: Value(_string(r, 'muscleGroup')),
        equipment: Value(_string(r, 'equipment')),
        notes: Value(_string(r, 'notes')),
        isCustom: Value(r['isCustom'] == true),
        isArchived: Value(r['isArchived'] == true),
        createdAt: _dateValue(r, 'createdAt')!,
        updatedAt: _dateValue(r, 'updatedAt')!,
      );

  PlansCompanion _readPlan(Map<String, Object?> r) => PlansCompanion.insert(
    id: Value(_int(r, 'id')!),
    name: _string(r, 'name')!,
    description: Value(_string(r, 'description')),
    mode: PlanMode.fromWire(_string(r, 'mode')) ?? PlanMode.staticPlan,
    scheduleType:
        ScheduleType.fromWire(_string(r, 'scheduleType')) ??
        ScheduleType.sequential,
    startDate: Value(_dateValue(r, 'startDate')),
    durationWeeks: Value(_int(r, 'durationWeeks')),
    isActive: Value(r['isActive'] == true),
    source: PlanSource.fromWire(_string(r, 'source')) ?? PlanSource.ui,
    schemaVersion: Value(_string(r, 'schemaVersion')),
    createdAt: _dateValue(r, 'createdAt')!,
    updatedAt: _dateValue(r, 'updatedAt')!,
  );

  PlanDaysCompanion _readPlanDay(Map<String, Object?> r) =>
      PlanDaysCompanion.insert(
        id: Value(_int(r, 'id')!),
        planId: _int(r, 'planId')!,
        orderIndex: _int(r, 'orderIndex')!,
        label: _string(r, 'label')!,
        weekNumber: Value(_int(r, 'weekNumber')),
        dayOfWeek: Value(Weekday.fromWire(_string(r, 'dayOfWeek'))),
        notes: Value(_string(r, 'notes')),
      );

  PlanBlocksCompanion _readPlanBlock(Map<String, Object?> r) =>
      PlanBlocksCompanion.insert(
        id: Value(_int(r, 'id')!),
        planDayId: _int(r, 'planDayId')!,
        orderIndex: _int(r, 'orderIndex')!,
        kind: BlockKind.fromWire(_string(r, 'kind')) ?? BlockKind.single,
        label: Value(_string(r, 'label')),
        rounds: Value(_int(r, 'rounds') ?? 1),
        restBetweenExercisesSeconds: Value(
          _int(r, 'restBetweenExercisesSeconds') ?? 0,
        ),
        restAfterRoundSeconds: Value(_int(r, 'restAfterRoundSeconds') ?? 90),
      );

  PlanItemsCompanion _readPlanItem(Map<String, Object?> r) =>
      PlanItemsCompanion.insert(
        id: Value(_int(r, 'id')!),
        planBlockId: _int(r, 'planBlockId')!,
        exerciseId: _int(r, 'exerciseId')!,
        orderIndex: _int(r, 'orderIndex')!,
        targetReps: Value(_int(r, 'targetReps')),
        targetWeightKg: Value(_double(r, 'targetWeightKg')),
        weightMode: Value(WeightMode.fromWire(_string(r, 'weightMode'))),
        weightOffsetKg: Value(_double(r, 'weightOffsetKg')),
        weightPercent: Value(_double(r, 'weightPercent')),
        rpe: Value(_double(r, 'rpe')),
        tempo: Value(_string(r, 'tempo')),
        toFailure: Value(r['toFailure'] == true),
        targetDurationSeconds: Value(_int(r, 'targetDurationSeconds')),
        targetDistanceMeters: Value(_double(r, 'targetDistanceMeters')),
        targetPaceSecPerKm: Value(_double(r, 'targetPaceSecPerKm')),
        targetInclinePercent: Value(_double(r, 'targetInclinePercent')),
        targetResistanceLevel: Value(_int(r, 'targetResistanceLevel')),
        intervalsJson: Value(_string(r, 'intervalsJson')),
        notes: Value(_string(r, 'notes')),
      );

  SessionsCompanion _readSession(Map<String, Object?> r) =>
      SessionsCompanion.insert(
        id: Value(_int(r, 'id')!),
        planId: Value(_int(r, 'planId')),
        planDayId: Value(_int(r, 'planDayId')),
        title: Value(_string(r, 'title')),
        startedAt: _dateValue(r, 'startedAt')!,
        endedAt: Value(_dateValue(r, 'endedAt')),
        status:
            SessionStatus.fromWire(_string(r, 'status')) ??
            SessionStatus.completed,
        durationSeconds: Value(_int(r, 'durationSeconds')),
        notes: Value(_string(r, 'notes')),
      );

  StrengthSetsCompanion _readStrengthSet(
    Map<String, Object?> r,
  ) => StrengthSetsCompanion.insert(
    id: Value(_int(r, 'id')!),
    sessionId: _int(r, 'sessionId')!,
    exerciseId: _int(r, 'exerciseId')!,
    planItemId: Value(_int(r, 'planItemId')),
    groupIndex: _int(r, 'groupIndex')!,
    groupKind: BlockKind.fromWire(_string(r, 'groupKind')) ?? BlockKind.single,
    groupLabel: Value(_string(r, 'groupLabel')),
    roundIndex: _int(r, 'roundIndex')!,
    itemIndex: _int(r, 'itemIndex')!,
    plannedReps: Value(_int(r, 'plannedReps')),
    plannedWeightKg: Value(_double(r, 'plannedWeightKg')),
    actualReps: Value(_int(r, 'actualReps')),
    actualWeightKg: Value(_double(r, 'actualWeightKg')),
    rpe: Value(_double(r, 'rpe')),
    isWarmup: Value(r['isWarmup'] == true),
    status: EntryStatus.fromWire(_string(r, 'status')) ?? EntryStatus.completed,
    restTakenSeconds: Value(_int(r, 'restTakenSeconds')),
    performedAt: Value(_dateValue(r, 'performedAt')),
    notes: Value(_string(r, 'notes')),
  );

  CardioEntriesCompanion _readCardioEntry(
    Map<String, Object?> r,
  ) => CardioEntriesCompanion.insert(
    id: Value(_int(r, 'id')!),
    sessionId: _int(r, 'sessionId')!,
    exerciseId: _int(r, 'exerciseId')!,
    planItemId: Value(_int(r, 'planItemId')),
    groupIndex: _int(r, 'groupIndex')!,
    groupKind: BlockKind.fromWire(_string(r, 'groupKind')) ?? BlockKind.single,
    groupLabel: Value(_string(r, 'groupLabel')),
    roundIndex: _int(r, 'roundIndex')!,
    itemIndex: _int(r, 'itemIndex')!,
    plannedDurationSeconds: Value(_int(r, 'plannedDurationSeconds')),
    plannedDistanceMeters: Value(_double(r, 'plannedDistanceMeters')),
    plannedPaceSecPerKm: Value(_double(r, 'plannedPaceSecPerKm')),
    actualDurationSeconds: Value(_int(r, 'actualDurationSeconds')),
    actualDistanceMeters: Value(_double(r, 'actualDistanceMeters')),
    actualPaceSecPerKm: Value(_double(r, 'actualPaceSecPerKm')),
    inclinePercent: Value(_double(r, 'inclinePercent')),
    resistanceLevel: Value(_int(r, 'resistanceLevel')),
    avgHeartRate: Value(_int(r, 'avgHeartRate')),
    maxHeartRate: Value(_int(r, 'maxHeartRate')),
    calories: Value(_int(r, 'calories')),
    elevationGainMeters: Value(_double(r, 'elevationGainMeters')),
    status: EntryStatus.fromWire(_string(r, 'status')) ?? EntryStatus.completed,
    performedAt: Value(_dateValue(r, 'performedAt')),
    notes: Value(_string(r, 'notes')),
  );

  CardioSplitsCompanion _readCardioSplit(Map<String, Object?> r) =>
      CardioSplitsCompanion.insert(
        id: Value(_int(r, 'id')!),
        cardioEntryId: _int(r, 'cardioEntryId')!,
        splitIndex: _int(r, 'splitIndex')!,
        durationSeconds: _int(r, 'durationSeconds')!,
        distanceMeters: Value(_double(r, 'distanceMeters')),
      );

  ExerciseBaselinesCompanion _readBaseline(Map<String, Object?> r) =>
      ExerciseBaselinesCompanion.insert(
        id: Value(_int(r, 'id')!),
        planId: _int(r, 'planId')!,
        exerciseId: _int(r, 'exerciseId')!,
        reps: _int(r, 'reps')!,
        weightKg: _double(r, 'weightKg')!,
        achievedAt: _dateValue(r, 'achievedAt')!,
        sourceSetId: Value(_int(r, 'sourceSetId')),
      );

  PersonalRecordsCompanion _readRecord(Map<String, Object?> r) =>
      PersonalRecordsCompanion.insert(
        id: Value(_int(r, 'id')!),
        exerciseId: _int(r, 'exerciseId')!,
        recordType:
            RecordType.fromWire(_string(r, 'recordType')) ??
            RecordType.maxWeight,
        reps: Value(_int(r, 'reps') ?? 0),
        value: _double(r, 'value')!,
        achievedAt: _dateValue(r, 'achievedAt')!,
        sessionId: Value(_int(r, 'sessionId')),
      );

  String? _string(Map<String, Object?> r, String key) => r[key]?.toString();

  int? _int(Map<String, Object?> r, String key) {
    final value = r[key];
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString());
  }

  double? _double(Map<String, Object?> r, String key) {
    final value = r[key];
    if (value == null) return null;
    return value is num ? value.toDouble() : double.tryParse(value.toString());
  }

  DateTime? _dateValue(Map<String, Object?> r, String key) {
    final value = _string(r, key);
    return value == null ? null : DateTime.tryParse(value);
  }
}

/// Thrown when a backup file cannot be read.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}
