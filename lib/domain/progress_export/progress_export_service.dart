import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/settings_repository.dart';
import '../models/enums.dart';

/// Version of the progress-export format.
const String kProgressExportVersion = '1.0';

/// How far back an export reaches.
const int kProgressExportDays = 90;

/// What an export contained, for the confirmation message.
class ProgressExport {
  const ProgressExport({
    required this.json,
    required this.from,
    required this.to,
    required this.sessionCount,
    required this.exerciseCount,
  });

  final String json;
  final DateTime from;
  final DateTime to;
  final int sessionCount;
  final int exerciseCount;

  bool get isEmpty => sessionCount == 0;
}

/// Summarises recent training as a JSON document meant to be handed to an AI
/// alongside the plan schema, so the plan it writes starts from what the user
/// has actually been lifting rather than from guesswork.
///
/// This is **not** a backup: it is lossy on purpose. Row ids, plan structure and
/// settings are all omitted, and only completed work inside the window is
/// included. What it does carry is the two things a coach would ask for — the
/// per-exercise picture (heaviest set, best estimated one-rep max, where the
/// numbers started and where they are now) and the raw session log behind it.
///
/// Every number is in the storage units documented on the tables: kilograms,
/// meters, seconds, seconds per kilometer. The document says so in its own
/// `units` block, and carries the user's display preference separately so the
/// reader can answer in the units they think in.
class ProgressExportService {
  ProgressExportService({
    required AppDatabase db,
    required SettingsRepository settings,
    Clock clock = const SystemClock(),
  }) : _db = db,
       _settings = settings,
       _clock = clock;

  final AppDatabase _db;
  final SettingsRepository _settings;
  final Clock _clock;

  Future<ProgressExport> export({int days = kProgressExportDays}) async {
    final to = _clock.now();
    final from = to.subtract(Duration(days: days));

    final sessions =
        await (_db.select(_db.sessions)
              ..where(
                (t) =>
                    t.status.equalsValue(SessionStatus.completed) &
                    t.startedAt.isBiggerOrEqualValue(from),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
            .get();

    final sessionIds = sessions.map((s) => s.id).toList();
    final sets = sessionIds.isEmpty
        ? <StrengthSetRow>[]
        : await (_db.select(_db.strengthSets)..where(
                (t) =>
                    t.sessionId.isIn(sessionIds) &
                    t.status.equalsValue(EntryStatus.completed),
              ))
              .get();
    final cardio = sessionIds.isEmpty
        ? <CardioEntryRow>[]
        : await (_db.select(_db.cardioEntries)..where(
                (t) =>
                    t.sessionId.isIn(sessionIds) &
                    t.status.equalsValue(EntryStatus.completed),
              ))
              .get();

    final exercises = {
      for (final row in await _db.select(_db.exercises).get()) row.id: row,
    };
    final plans = {
      for (final row in await _db.select(_db.plans).get()) row.id: row,
    };
    final activePlan = plans.values.where((p) => p.isActive).firstOrNull;

    final trainedIds = {
      ...sets.map((s) => s.exerciseId),
      ...cardio.map((c) => c.exerciseId),
    };
    final records = trainedIds.isEmpty
        ? <PersonalRecordRow>[]
        : await (_db.select(
            _db.personalRecords,
          )..where((t) => t.exerciseId.isIn(trainedIds.toList()))).get();

    final unitSystem = await _settings.getUnitSystem();

    final data = <String, Object?>{
      'progressExportVersion': kProgressExportVersion,
      'exportedAt': _iso(to),
      'window': {'days': days, 'from': _iso(from), 'to': _iso(to)},
      'units': const {
        'weight': 'kg',
        'distance': 'meters',
        'duration': 'seconds',
        'pace': 'seconds per kilometer',
      },
      'preferredDisplayUnits': unitSystem.name,
      'summary': _summary(sessions, sets, cardio, from, to),
      'activePlan': activePlan == null
          ? null
          : {
              'name': activePlan.name,
              'mode': activePlan.mode.wireName,
              'durationWeeks': activePlan.durationWeeks,
            },
      'strengthExercises': _strengthExercises(sets, exercises),
      'cardioExercises': _cardioExercises(cardio, exercises),
      'personalRecords': _records(records, exercises, from),
      'sessions': _sessions(sessions, sets, cardio, exercises, plans),
    };

    return ProgressExport(
      json: const JsonEncoder.withIndent('  ').convert(data),
      from: from,
      to: to,
      sessionCount: sessions.length,
      exerciseCount: trainedIds.length,
    );
  }

  // --------------------------------------------------------------- summary

  Map<String, Object?> _summary(
    List<SessionRow> sessions,
    List<StrengthSetRow> sets,
    List<CardioEntryRow> cardio,
    DateTime from,
    DateTime to,
  ) {
    final working = sets.where((s) => !s.isWarmup).toList();
    final volume = working.fold<double>(
      0,
      (sum, s) => sum + (s.actualWeightKg ?? 0) * (s.actualReps ?? 0),
    );

    // Measured from the first session rather than from the start of the window,
    // so someone six weeks into training is not reported as training half as
    // often as they really do.
    final start = sessions.isEmpty ? from : sessions.first.startedAt;
    final weeks = to.difference(start).inMinutes / (7 * 24 * 60);

    return {
      'sessions': sessions.length,
      'sessionsPerWeek': weeks < 1
          ? sessions.length
          : _round(sessions.length / weeks, 1),
      'strengthSets': working.length,
      'warmupSets': sets.length - working.length,
      'cardioEfforts': cardio.length,
      'totalVolumeKg': _round(volume, 1),
      'trainingDays': sessions
          .map((s) => _dayString(s.startedAt))
          .toSet()
          .length,
    };
  }

  // ------------------------------------------------------------- exercises

  /// Per-exercise strength picture, busiest first. Warm-ups are excluded
  /// throughout — they would drag every "where did I start" figure downwards.
  List<Map<String, Object?>> _strengthExercises(
    List<StrengthSetRow> allSets,
    Map<int, ExerciseRow> exercises,
  ) {
    final byExercise = <int, List<StrengthSetRow>>{};
    for (final set in allSets.where(
      (s) => !s.isWarmup && s.actualWeightKg != null && s.actualReps != null,
    )) {
      byExercise.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    final result = <Map<String, Object?>>[];
    for (final entry in byExercise.entries) {
      final exercise = exercises[entry.key];
      if (exercise == null) continue;

      final sets = entry.value
        ..sort(
          (a, b) => (a.performedAt ?? DateTime(0)).compareTo(
            b.performedAt ?? DateTime(0),
          ),
        );

      final heaviest = sets.reduce(
        (a, b) => b.actualWeightKg! > a.actualWeightKg! ? b : a,
      );
      final topSetPerDay = _topSetPerDay(sets);

      result.add({
        'name': exercise.name,
        'muscleGroup': exercise.muscleGroup,
        'equipment': exercise.equipment,
        'sets': sets.length,
        'days': topSetPerDay.length,
        'heaviestSet': {
          'weightKg': _round(heaviest.actualWeightKg!, 2),
          'reps': heaviest.actualReps,
          'date': _dayOrNull(heaviest.performedAt),
        },
        'bestEstimatedOneRepMaxKg': _round(
          sets.map(_epley).reduce((a, b) => a > b ? a : b),
          1,
        ),
        // The pair that shows direction of travel at a glance: what the top set
        // was on the first day in the window, and on the most recent one.
        'topSetFirstDayKg': _round(topSetPerDay.values.first, 2),
        'topSetLatestDayKg': _round(topSetPerDay.values.last, 2),
        'latestSession': _latestStrengthSession(sets),
      });
    }

    result.sort((a, b) => (b['sets']! as int).compareTo(a['sets']! as int));
    return result;
  }

  /// Heaviest set on each training day, in date order.
  Map<DateTime, double> _topSetPerDay(List<StrengthSetRow> sets) {
    final best = <DateTime, double>{};
    for (final set in sets) {
      final day = _day(set.performedAt ?? DateTime(0));
      final current = best[day];
      if (current == null || set.actualWeightKg! > current) {
        best[day] = set.actualWeightKg!;
      }
    }
    final days = best.keys.toList()..sort();
    return {for (final day in days) day: best[day]!};
  }

  /// Every set from the most recent day this exercise was trained, which is
  /// what a plan should progress from.
  Map<String, Object?> _latestStrengthSession(List<StrengthSetRow> sets) {
    final latest = _day(sets.last.performedAt ?? DateTime(0));
    final onDay = sets.where(
      (s) => _day(s.performedAt ?? DateTime(0)) == latest,
    );

    return {
      'date': _dayString(latest),
      'sets': [
        for (final set in onDay)
          {
            'reps': set.actualReps,
            'weightKg': _round(set.actualWeightKg!, 2),
            if (set.rpe != null) 'rpe': set.rpe,
          },
      ],
    };
  }

  double _epley(StrengthSetRow set) {
    final reps = set.actualReps!;
    return set.actualWeightKg! * (1 + (reps <= 1 ? 0 : reps / 30));
  }

  List<Map<String, Object?>> _cardioExercises(
    List<CardioEntryRow> allEntries,
    Map<int, ExerciseRow> exercises,
  ) {
    final byExercise = <int, List<CardioEntryRow>>{};
    for (final entry in allEntries) {
      byExercise.putIfAbsent(entry.exerciseId, () => []).add(entry);
    }

    final result = <Map<String, Object?>>[];
    for (final entry in byExercise.entries) {
      final exercise = exercises[entry.key];
      if (exercise == null) continue;

      final efforts = entry.value
        ..sort(
          (a, b) => (a.performedAt ?? DateTime(0)).compareTo(
            b.performedAt ?? DateTime(0),
          ),
        );
      final distances = efforts
          .map((e) => e.actualDistanceMeters)
          .nonNulls
          .toList();
      final durations = efforts
          .map((e) => e.actualDurationSeconds)
          .nonNulls
          .toList();
      final paces = efforts.map((e) => e.actualPaceSecPerKm).nonNulls.toList();
      final last = efforts.last;

      result.add({
        'name': exercise.name,
        'activity': exercise.cardioActivity?.wireName,
        'efforts': efforts.length,
        'totalDistanceMeters': distances.isEmpty
            ? null
            : _round(distances.reduce((a, b) => a + b), 0),
        'totalDurationSeconds': durations.isEmpty
            ? null
            : durations.reduce((a, b) => a + b),
        'longestDistanceMeters': distances.isEmpty
            ? null
            : _round(distances.reduce((a, b) => a > b ? a : b), 0),
        // Lowest wins for pace, unlike every other figure in this document.
        'bestPaceSecPerKm': paces.isEmpty
            ? null
            : _round(paces.reduce((a, b) => a < b ? a : b), 0),
        'latestEffort': {
          'date': _dayOrNull(last.performedAt),
          'durationSeconds': last.actualDurationSeconds,
          'distanceMeters': _roundOrNull(last.actualDistanceMeters, 0),
          'paceSecPerKm': _roundOrNull(last.actualPaceSecPerKm, 0),
        },
      });
    }

    result.sort(
      (a, b) => (b['efforts']! as int).compareTo(a['efforts']! as int),
    );
    return result;
  }

  /// Personal records are all-time by design — a plan should not prescribe
  /// below a number the user has already hit, even if that was four months ago.
  /// [inWindow] says which ones are recent, so the reader can tell the
  /// difference.
  List<Map<String, Object?>> _records(
    List<PersonalRecordRow> records,
    Map<int, ExerciseRow> exercises,
    DateTime from,
  ) {
    final sorted = records.toList()
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));

    return [
      for (final record in sorted)
        if (exercises[record.exerciseId] case final exercise?)
          {
            'exercise': exercise.name,
            'type': record.recordType.wireName,
            if (record.reps > 0) 'reps': record.reps,
            'value': _round(record.value, 2),
            'achievedAt': _dayString(record.achievedAt),
            'inWindow': !record.achievedAt.isBefore(from),
          },
    ];
  }

  // -------------------------------------------------------------- sessions

  List<Map<String, Object?>> _sessions(
    List<SessionRow> sessions,
    List<StrengthSetRow> allSets,
    List<CardioEntryRow> allCardio,
    Map<int, ExerciseRow> exercises,
    Map<int, PlanRow> plans,
  ) {
    final setsBySession = <int, List<StrengthSetRow>>{};
    for (final set in allSets) {
      setsBySession.putIfAbsent(set.sessionId, () => []).add(set);
    }
    final cardioBySession = <int, List<CardioEntryRow>>{};
    for (final entry in allCardio) {
      cardioBySession.putIfAbsent(entry.sessionId, () => []).add(entry);
    }

    return [
      for (final session in sessions)
        {
          'date': _dayString(session.startedAt),
          'title': session.title,
          'plan': plans[session.planId]?.name,
          'durationSeconds': session.durationSeconds,
          'strength': _sessionStrength(
            setsBySession[session.id] ?? const <StrengthSetRow>[],
            exercises,
          ),
          'cardio': [
            for (final entry
                in cardioBySession[session.id] ?? const <CardioEntryRow>[])
              {
                'exercise': exercises[entry.exerciseId]?.name,
                'durationSeconds': entry.actualDurationSeconds,
                'distanceMeters': _roundOrNull(entry.actualDistanceMeters, 0),
                'paceSecPerKm': _roundOrNull(entry.actualPaceSecPerKm, 0),
                if (entry.avgHeartRate != null)
                  'avgHeartRate': entry.avgHeartRate,
              },
          ],
          if (session.notes != null) 'notes': session.notes,
        },
    ];
  }

  /// Sets grouped under their exercise, in the order they were performed, so a
  /// session reads the way it was done rather than as a flat list of rows.
  List<Map<String, Object?>> _sessionStrength(
    List<StrengthSetRow> sets,
    Map<int, ExerciseRow> exercises,
  ) {
    final ordered = sets.toList()
      ..sort((a, b) {
        final byGroup = a.groupIndex.compareTo(b.groupIndex);
        if (byGroup != 0) return byGroup;
        final byRound = a.roundIndex.compareTo(b.roundIndex);
        return byRound != 0 ? byRound : a.itemIndex.compareTo(b.itemIndex);
      });

    final grouped = <int, List<StrengthSetRow>>{};
    for (final set in ordered) {
      grouped.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    return [
      for (final entry in grouped.entries)
        {
          'exercise': exercises[entry.key]?.name,
          'sets': [
            for (final set in entry.value)
              {
                'reps': set.actualReps,
                'weightKg': _roundOrNull(set.actualWeightKg, 2),
                if (set.rpe != null) 'rpe': set.rpe,
                if (set.isWarmup) 'warmup': true,
              },
          ],
        },
    ];
  }

  // --------------------------------------------------------------- helpers

  String _iso(DateTime value) => value.toUtc().toIso8601String();

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  /// Local calendar date, `YYYY-MM-DD`. Sessions are grouped and compared by
  /// the day the user trained, which is a local-time question.
  String _dayString(DateTime value) {
    final day = _day(value);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  String? _dayOrNull(DateTime? value) =>
      value == null ? null : _dayString(value);

  /// Keeps the document readable: floating-point noise like `62.50000000000001`
  /// reads as precision that is not there.
  num _round(double value, int places) {
    final factor = _pow10(places);
    final rounded = (value * factor).round() / factor;
    return places == 0 ? rounded.round() : rounded;
  }

  num? _roundOrNull(double? value, int places) =>
      value == null ? null : _round(value, places);

  int _pow10(int places) {
    var result = 1;
    for (var i = 0; i < places; i++) {
      result *= 10;
    }
    return result;
  }
}
