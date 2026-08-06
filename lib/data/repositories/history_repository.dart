import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../db/app_database.dart';

/// One point on a progress chart.
class ProgressPoint {
  const ProgressPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

/// A completed session with enough detail for a history list, without loading
/// every set.
class SessionSummary {
  const SessionSummary({
    required this.session,
    required this.strengthSetCount,
    required this.cardioCount,
    required this.totalVolumeKg,
    required this.exerciseNames,
  });

  final SessionRow session;
  final int strengthSetCount;
  final int cardioCount;
  final double totalVolumeKg;
  final List<String> exerciseNames;

  bool get isEmpty => strengthSetCount == 0 && cardioCount == 0;
}

/// Queries over completed training history.
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  /// Summaries for the history list, newest first.
  ///
  /// Builds the aggregate in Dart from three bulk queries rather than issuing a
  /// query per session, which would be a request storm on a long history.
  Future<List<SessionSummary>> recentSessions({int limit = 50}) async {
    final sessions =
        await (_db.select(_db.sessions)
              ..where((t) => t.status.equalsValue(SessionStatus.completed))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(limit))
            .get();
    if (sessions.isEmpty) return const [];

    final ids = sessions.map((s) => s.id).toList();

    final sets = await (_db.select(
      _db.strengthSets,
    )..where((t) => t.sessionId.isIn(ids))).get();
    final cardio = await (_db.select(
      _db.cardioEntries,
    )..where((t) => t.sessionId.isIn(ids))).get();
    final exercises = await _db.select(_db.exercises).get();
    final nameById = {for (final e in exercises) e.id: e.name};

    return [
      for (final session in sessions)
        _summarize(session, sets, cardio, nameById),
    ];
  }

  SessionSummary _summarize(
    SessionRow session,
    List<StrengthSetRow> allSets,
    List<CardioEntryRow> allCardio,
    Map<int, String> nameById,
  ) {
    final sets = allSets
        .where(
          (s) => s.sessionId == session.id && s.status == EntryStatus.completed,
        )
        .toList();
    final cardio = allCardio
        .where(
          (c) => c.sessionId == session.id && c.status == EntryStatus.completed,
        )
        .toList();

    final volume = sets
        .where((s) => !s.isWarmup)
        .fold<double>(
          0,
          (sum, s) => sum + (s.actualWeightKg ?? 0) * (s.actualReps ?? 0),
        );

    // Ordered by appearance so the list reads like the workout was performed.
    final names = <String>[];
    for (final id in [
      ...sets.map((s) => s.exerciseId),
      ...cardio.map((c) => c.exerciseId),
    ]) {
      final name = nameById[id];
      if (name != null && !names.contains(name)) names.add(name);
    }

    return SessionSummary(
      session: session,
      strengthSetCount: sets.length,
      cardioCount: cardio.length,
      totalVolumeKg: volume,
      exerciseNames: names,
    );
  }

  /// Heaviest working set per day for one exercise, oldest first.
  ///
  /// Warm-ups are excluded — charting them would show progress going backwards
  /// on any day the user warmed up thoroughly.
  Future<List<ProgressPoint>> strengthProgress(int exerciseId) async {
    final rows =
        await (_db.select(_db.strengthSets)
              ..where(
                (t) =>
                    t.exerciseId.equals(exerciseId) &
                    t.status.equalsValue(EntryStatus.completed) &
                    t.isWarmup.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.performedAt)]))
            .get();

    return _bestPerDay(
      rows.where((r) => r.actualWeightKg != null && r.performedAt != null),
      date: (r) => r.performedAt!,
      value: (r) => r.actualWeightKg!,
      better: (a, b) => a > b,
    );
  }

  /// Best estimated one-rep max per day, which reflects progress even when the
  /// rep scheme changes between sessions.
  Future<List<ProgressPoint>> estimatedOneRepMaxProgress(int exerciseId) async {
    final rows =
        await (_db.select(_db.strengthSets)
              ..where(
                (t) =>
                    t.exerciseId.equals(exerciseId) &
                    t.status.equalsValue(EntryStatus.completed) &
                    t.isWarmup.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.performedAt)]))
            .get();

    final usable = rows.where(
      (r) =>
          r.actualWeightKg != null &&
          r.actualReps != null &&
          r.actualReps! > 0 &&
          r.performedAt != null,
    );

    return _bestPerDay(
      usable,
      date: (r) => r.performedAt!,
      value: (r) =>
          r.actualWeightKg! *
          (1 + (r.actualReps! <= 1 ? 0 : r.actualReps! / 30)),
      better: (a, b) => a > b,
    );
  }

  /// Longest distance per day for a cardio exercise.
  Future<List<ProgressPoint>> cardioDistanceProgress(int exerciseId) async {
    final rows = await _completedCardio(exerciseId);
    return _bestPerDay(
      rows.where((r) => r.actualDistanceMeters != null),
      date: (r) => r.performedAt!,
      value: (r) => r.actualDistanceMeters!,
      better: (a, b) => a > b,
    );
  }

  /// Fastest pace per day. Lower is better here, which is why the comparison is
  /// injected rather than hard-coded.
  Future<List<ProgressPoint>> cardioPaceProgress(int exerciseId) async {
    final rows = await _completedCardio(exerciseId);
    return _bestPerDay(
      rows.where((r) => r.actualPaceSecPerKm != null),
      date: (r) => r.performedAt!,
      value: (r) => r.actualPaceSecPerKm!,
      better: (a, b) => a < b,
    );
  }

  Future<List<CardioEntryRow>> _completedCardio(int exerciseId) {
    return (_db.select(_db.cardioEntries)
          ..where(
            (t) =>
                t.exerciseId.equals(exerciseId) &
                t.status.equalsValue(EntryStatus.completed),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.performedAt)]))
        .get();
  }

  /// Collapses multiple efforts on the same calendar day to the best one, so a
  /// chart shows one point per training day rather than a cluster per session.
  List<ProgressPoint> _bestPerDay<T>(
    Iterable<T> rows, {
    required DateTime Function(T) date,
    required double Function(T) value,
    required bool Function(double candidate, double current) better,
  }) {
    final bestByDay = <DateTime, double>{};

    for (final row in rows) {
      final when = date(row);
      final day = DateTime(when.year, when.month, when.day);
      final candidate = value(row);
      final current = bestByDay[day];
      if (current == null || better(candidate, current)) {
        bestByDay[day] = candidate;
      }
    }

    final days = bestByDay.keys.toList()..sort();
    return [
      for (final day in days) ProgressPoint(date: day, value: bestByDay[day]!),
    ];
  }

  /// Exercises that have any completed history, for the progress picker.
  Future<List<ExerciseRow>> exercisesWithHistory() async {
    final strength =
        await (_db.selectOnly(_db.strengthSets)
              ..addColumns([_db.strengthSets.exerciseId])
              ..where(
                _db.strengthSets.status.equalsValue(EntryStatus.completed),
              )
              ..groupBy([_db.strengthSets.exerciseId]))
            .get();
    final cardio =
        await (_db.selectOnly(_db.cardioEntries)
              ..addColumns([_db.cardioEntries.exerciseId])
              ..where(
                _db.cardioEntries.status.equalsValue(EntryStatus.completed),
              )
              ..groupBy([_db.cardioEntries.exerciseId]))
            .get();

    final ids = {
      ...strength.map((r) => r.read(_db.strengthSets.exerciseId)!),
      ...cardio.map((r) => r.read(_db.cardioEntries.exerciseId)!),
    };
    if (ids.isEmpty) return const [];

    return (_db.select(_db.exercises)
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }
}
