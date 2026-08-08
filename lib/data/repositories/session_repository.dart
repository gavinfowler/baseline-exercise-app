import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../core/units/unit_system.dart';
import '../../domain/models/enums.dart';
import '../db/app_database.dart';

/// Creates and updates workout sessions and the sets logged inside them.
class SessionRepository {
  SessionRepository(this._db, {Clock clock = const SystemClock()})
    : _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  // ---------------------------------------------------------------- sessions

  /// The session currently being performed, if any.
  ///
  /// At most one session is in progress at a time; if an older one was left
  /// open (the app was killed mid-workout) the most recent wins.
  Future<SessionRow?> getActiveSession() {
    return (_db.select(_db.sessions)
          ..where((t) => t.status.equalsValue(SessionStatus.inProgress))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<SessionRow?> watchActiveSession() {
    return (_db.select(_db.sessions)
          ..where((t) => t.status.equalsValue(SessionStatus.inProgress))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<SessionRow?> findById(int id) => (_db.select(
    _db.sessions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<SessionRow?> watchById(int id) => (_db.select(
    _db.sessions,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Starts a workout. Pass [planId]/[planDayId] for a planned session, or
  /// neither for an ad-hoc one.
  Future<int> startSession({int? planId, int? planDayId, String? title}) {
    return _db
        .into(_db.sessions)
        .insert(
          SessionsCompanion.insert(
            planId: Value(planId),
            planDayId: Value(planDayId),
            title: Value(title),
            startedAt: _clock.now(),
            status: SessionStatus.inProgress,
          ),
        );
  }

  /// Marks the session finished and stamps its duration.
  ///
  /// Any set still `pending` is recorded as `skipped` rather than left dangling,
  /// so history distinguishes "did not do it" from "not yet done".
  Future<void> completeSession(int sessionId) async {
    final session = await findById(sessionId);
    if (session == null) return;

    final endedAt = _clock.now();
    await _db.transaction(() async {
      await (_db.update(_db.strengthSets)..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                t.status.equalsValue(EntryStatus.pending),
          ))
          .write(
            const StrengthSetsCompanion(status: Value(EntryStatus.skipped)),
          );

      await (_db.update(_db.cardioEntries)..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                t.status.equalsValue(EntryStatus.pending),
          ))
          .write(
            const CardioEntriesCompanion(status: Value(EntryStatus.skipped)),
          );

      await (_db.update(
        _db.sessions,
      )..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          status: const Value(SessionStatus.completed),
          endedAt: Value(endedAt),
          durationSeconds: Value(
            endedAt.difference(session.startedAt).inSeconds,
          ),
        ),
      );
    });
  }

  Future<void> abandonSession(int sessionId) async {
    await (_db.update(
      _db.sessions,
    )..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        status: const Value(SessionStatus.abandoned),
        endedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> deleteSession(int sessionId) async {
    await (_db.delete(_db.sessions)..where((t) => t.id.equals(sessionId))).go();
  }

  Future<void> setSessionNotes(int sessionId, String? notes) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
        .write(SessionsCompanion(notes: Value(notes)));
  }

  /// The last workout completed from this plan, used to work out which one
  /// comes next.
  ///
  /// Sessions with no `planDayId` are ignored: an ad-hoc workout logged against
  /// the plan says nothing about where the rotation got to.
  Future<SessionRow?> lastCompletedForPlan(int planId) {
    return (_db.select(_db.sessions)
          ..where(
            (t) =>
                t.planId.equals(planId) &
                t.planDayId.isNotNull() &
                t.status.equalsValue(SessionStatus.completed),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Completed sessions, newest first.
  Stream<List<SessionRow>> watchHistory({int limit = 100}) {
    return (_db.select(_db.sessions)
          ..where((t) => t.status.equalsValue(SessionStatus.completed))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .watch();
  }

  // ----------------------------------------------------------- strength sets

  Stream<List<StrengthSetRow>> watchStrengthSets(int sessionId) {
    return (_db.select(_db.strengthSets)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.groupIndex),
            (t) => OrderingTerm.asc(t.roundIndex),
            (t) => OrderingTerm.asc(t.itemIndex),
          ]))
        .watch();
  }

  Future<List<StrengthSetRow>> getStrengthSets(int sessionId) {
    return (_db.select(_db.strengthSets)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.groupIndex),
            (t) => OrderingTerm.asc(t.roundIndex),
            (t) => OrderingTerm.asc(t.itemIndex),
          ]))
        .get();
  }

  /// The next free group slot in a session, used when the user adds another
  /// exercise to an ad-hoc workout.
  Future<int> nextGroupIndex(int sessionId) async {
    final strength = await getStrengthSets(sessionId);
    final cardio = await getCardioEntries(sessionId);

    final indices = <int>[
      ...strength.map((s) => s.groupIndex),
      ...cardio.map((c) => c.groupIndex),
    ];
    if (indices.isEmpty) return 0;
    return indices.reduce((a, b) => a > b ? a : b) + 1;
  }

  /// How many rounds have already been logged in a group — the round index the
  /// next set should get.
  Future<int> nextRoundIndex(int sessionId, int groupIndex) async {
    final rows =
        await (_db.select(_db.strengthSets)..where(
              (t) =>
                  t.sessionId.equals(sessionId) &
                  t.groupIndex.equals(groupIndex),
            ))
            .get();
    if (rows.isEmpty) return 0;
    return rows.map((r) => r.roundIndex).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<int> addStrengthSet({
    required int sessionId,
    required int exerciseId,
    required int groupIndex,
    required int roundIndex,
    int itemIndex = 0,
    BlockKind groupKind = BlockKind.single,
    String? groupLabel,
    int? planItemId,
    int? plannedReps,
    double? plannedWeightKg,
    int? actualReps,
    double? actualWeightKg,
    double? rpe,
    bool isWarmup = false,
    EntryStatus status = EntryStatus.completed,
    int? restTakenSeconds,
    String? notes,
  }) {
    return _db
        .into(_db.strengthSets)
        .insert(
          StrengthSetsCompanion.insert(
            sessionId: sessionId,
            exerciseId: exerciseId,
            planItemId: Value(planItemId),
            groupIndex: groupIndex,
            groupKind: groupKind,
            groupLabel: Value(groupLabel),
            roundIndex: roundIndex,
            itemIndex: itemIndex,
            plannedReps: Value(plannedReps),
            plannedWeightKg: Value(plannedWeightKg),
            actualReps: Value(actualReps),
            actualWeightKg: Value(actualWeightKg),
            rpe: Value(rpe),
            isWarmup: Value(isWarmup),
            status: status,
            restTakenSeconds: Value(restTakenSeconds),
            performedAt: Value(
              status == EntryStatus.completed ? _clock.now() : null,
            ),
            notes: Value(notes),
          ),
        );
  }

  /// Records the result of a set that was created up front by a planned session.
  Future<void> completeStrengthSet(
    int setId, {
    required int actualReps,
    required double actualWeightKg,
    double? rpe,
    int? restTakenSeconds,
  }) async {
    await (_db.update(
      _db.strengthSets,
    )..where((t) => t.id.equals(setId))).write(
      StrengthSetsCompanion(
        actualReps: Value(actualReps),
        actualWeightKg: Value(actualWeightKg),
        rpe: Value(rpe),
        restTakenSeconds: Value(restTakenSeconds),
        status: const Value(EntryStatus.completed),
        performedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> updateStrengthSet(
    int setId, {
    Value<int?> actualReps = const Value.absent(),
    Value<double?> actualWeightKg = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    Value<bool> isWarmup = const Value.absent(),
    Value<EntryStatus> status = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) async {
    await (_db.update(
      _db.strengthSets,
    )..where((t) => t.id.equals(setId))).write(
      StrengthSetsCompanion(
        actualReps: actualReps,
        actualWeightKg: actualWeightKg,
        rpe: rpe,
        isWarmup: isWarmup,
        status: status,
        notes: notes,
      ),
    );
  }

  Future<void> skipStrengthSet(int setId) =>
      updateStrengthSet(setId, status: const Value(EntryStatus.skipped));

  Future<void> deleteStrengthSet(int setId) async {
    await (_db.delete(_db.strengthSets)..where((t) => t.id.equals(setId))).go();
  }

  /// The most recent completed set for an exercise, used to prefill the weight
  /// and rep fields so logging a repeat workout is a couple of taps.
  Future<StrengthSetRow?> lastCompletedSet(
    int exerciseId, {
    int? excludingSessionId,
  }) {
    final query = _db.select(_db.strengthSets)
      ..where(
        (t) =>
            t.exerciseId.equals(exerciseId) &
            t.status.equalsValue(EntryStatus.completed) &
            t.isWarmup.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.performedAt)])
      ..limit(1);
    if (excludingSessionId != null) {
      query.where((t) => t.sessionId.equals(excludingSessionId).not());
    }
    return query.getSingleOrNull();
  }

  // --------------------------------------------------------- cardio entries

  Stream<List<CardioEntryRow>> watchCardioEntries(int sessionId) {
    return (_db.select(_db.cardioEntries)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.groupIndex),
            (t) => OrderingTerm.asc(t.roundIndex),
          ]))
        .watch();
  }

  Future<List<CardioEntryRow>> getCardioEntries(int sessionId) {
    return (_db.select(_db.cardioEntries)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.groupIndex),
            (t) => OrderingTerm.asc(t.roundIndex),
          ]))
        .get();
  }

  Future<int> addCardioEntry({
    required int sessionId,
    required int exerciseId,
    required int groupIndex,
    int roundIndex = 0,
    int itemIndex = 0,
    BlockKind groupKind = BlockKind.single,
    String? groupLabel,
    int? planItemId,
    int? plannedDurationSeconds,
    double? plannedDistanceMeters,
    double? plannedPaceSecPerKm,
    EntryStatus status = EntryStatus.pending,
  }) {
    return _db
        .into(_db.cardioEntries)
        .insert(
          CardioEntriesCompanion.insert(
            sessionId: sessionId,
            exerciseId: exerciseId,
            planItemId: Value(planItemId),
            groupIndex: groupIndex,
            groupKind: groupKind,
            groupLabel: Value(groupLabel),
            roundIndex: roundIndex,
            itemIndex: itemIndex,
            plannedDurationSeconds: Value(plannedDurationSeconds),
            plannedDistanceMeters: Value(plannedDistanceMeters),
            plannedPaceSecPerKm: Value(plannedPaceSecPerKm),
            status: status,
          ),
        );
  }

  /// Records the result of a cardio effort.
  ///
  /// Pace is derived here rather than at read time, so history and chart queries
  /// never have to recompute it and a zero-distance entry can never produce an
  /// infinite pace.
  Future<void> completeCardioEntry(
    int entryId, {
    required int durationSeconds,
    double? distanceMeters,
    double? inclinePercent,
    int? resistanceLevel,
    int? avgHeartRate,
    int? maxHeartRate,
    int? calories,
    double? elevationGainMeters,
    String? notes,
  }) async {
    final pace = distanceMeters == null
        ? null
        : Units.paceSecPerKm(
            durationSeconds: durationSeconds,
            distanceMeters: distanceMeters,
          );

    await (_db.update(
      _db.cardioEntries,
    )..where((t) => t.id.equals(entryId))).write(
      CardioEntriesCompanion(
        actualDurationSeconds: Value(durationSeconds),
        actualDistanceMeters: Value(distanceMeters),
        actualPaceSecPerKm: Value(pace),
        inclinePercent: Value(inclinePercent),
        resistanceLevel: Value(resistanceLevel),
        avgHeartRate: Value(avgHeartRate),
        maxHeartRate: Value(maxHeartRate),
        calories: Value(calories),
        elevationGainMeters: Value(elevationGainMeters),
        notes: Value(notes),
        status: const Value(EntryStatus.completed),
        performedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> skipCardioEntry(int entryId) async {
    await (_db.update(
      _db.cardioEntries,
    )..where((t) => t.id.equals(entryId))).write(
      const CardioEntriesCompanion(status: Value(EntryStatus.skipped)),
    );
  }

  Future<void> deleteCardioEntry(int entryId) async {
    await (_db.delete(
      _db.cardioEntries,
    )..where((t) => t.id.equals(entryId))).go();
  }

  Future<CardioEntryRow?> findCardioEntry(int entryId) => (_db.select(
    _db.cardioEntries,
  )..where((t) => t.id.equals(entryId))).getSingleOrNull();

  /// The most recent completed effort for a cardio exercise, used to prefill.
  Future<CardioEntryRow?> lastCompletedCardio(int exerciseId) {
    return (_db.select(_db.cardioEntries)
          ..where(
            (t) =>
                t.exerciseId.equals(exerciseId) &
                t.status.equalsValue(EntryStatus.completed),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.performedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------- cardio splits

  /// Replaces the split list for an entry.
  ///
  /// Splits come from the in-app lap timer as a complete set, so writing them
  /// wholesale avoids partial-update bugs when a session is edited.
  Future<void> replaceSplits(
    int cardioEntryId,
    List<({int durationSeconds, double? distanceMeters})> splits,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.cardioSplits,
      )..where((t) => t.cardioEntryId.equals(cardioEntryId))).go();

      await _db.batch((batch) {
        batch.insertAll(_db.cardioSplits, [
          for (var i = 0; i < splits.length; i++)
            CardioSplitsCompanion.insert(
              cardioEntryId: cardioEntryId,
              splitIndex: i,
              durationSeconds: splits[i].durationSeconds,
              distanceMeters: Value(splits[i].distanceMeters),
            ),
        ]);
      });
    });
  }

  Future<List<CardioSplitRow>> getSplits(int cardioEntryId) {
    return (_db.select(_db.cardioSplits)
          ..where((t) => t.cardioEntryId.equals(cardioEntryId))
          ..orderBy([(t) => OrderingTerm.asc(t.splitIndex)]))
        .get();
  }
}
