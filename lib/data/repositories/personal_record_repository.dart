import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../db/app_database.dart';

/// A record that was just beaten.
class NewRecord {
  const NewRecord({
    required this.exerciseId,
    required this.recordType,
    required this.reps,
    required this.value,
    required this.previousValue,
  });

  final int exerciseId;
  final RecordType recordType;
  final int reps;
  final double value;

  /// Null when this is the first result ever recorded for the category.
  final double? previousValue;

  bool get isFirstEver => previousValue == null;
}

/// Best-ever performances, tracked for **both** plan modes.
///
/// A periodized plan still celebrates a personal record; it just does not let
/// that record change the prescription.
class PersonalRecordRepository {
  PersonalRecordRepository(this._db);

  final AppDatabase _db;

  Future<PersonalRecordRow?> find({
    required int exerciseId,
    required RecordType recordType,
    int reps = 0,
  }) {
    return (_db.select(_db.personalRecords)..where(
          (t) =>
              t.exerciseId.equals(exerciseId) &
              t.recordType.equalsValue(recordType) &
              t.reps.equals(reps),
        ))
        .getSingleOrNull();
  }

  Future<List<PersonalRecordRow>> forExercise(int exerciseId) {
    return (_db.select(
      _db.personalRecords,
    )..where((t) => t.exerciseId.equals(exerciseId))).get();
  }

  Stream<List<PersonalRecordRow>> watchForExercise(int exerciseId) {
    return (_db.select(
      _db.personalRecords,
    )..where((t) => t.exerciseId.equals(exerciseId))).watch();
  }

  /// Records [value] if it beats the stored record for this category.
  ///
  /// "Beats" respects direction: pace wins by being lower, everything else by
  /// being higher. Returns the [NewRecord] on success, or null if the existing
  /// record stands.
  Future<NewRecord?> recordIfBetter({
    required int exerciseId,
    required RecordType recordType,
    required double value,
    required DateTime achievedAt,
    int reps = 0,
    int? sessionId,
  }) async {
    final existing = await find(
      exerciseId: exerciseId,
      recordType: recordType,
      reps: reps,
    );

    if (existing != null) {
      final beaten = recordType.lowerIsBetter
          ? value < existing.value
          : value > existing.value;
      if (!beaten) return null;
    }

    await _db
        .into(_db.personalRecords)
        .insert(
          PersonalRecordsCompanion.insert(
            exerciseId: exerciseId,
            recordType: recordType,
            reps: Value(reps),
            value: value,
            achievedAt: achievedAt,
            sessionId: Value(sessionId),
          ),
          // Upsert against the (exercise, type, reps) unique index rather than
          // the surrogate primary key — see the note in BaselineRepository.
          onConflict: DoUpdate(
            (_) => PersonalRecordsCompanion(
              value: Value(value),
              achievedAt: Value(achievedAt),
              sessionId: Value(sessionId),
            ),
            target: [
              _db.personalRecords.exerciseId,
              _db.personalRecords.recordType,
              _db.personalRecords.reps,
            ],
          ),
        );

    return NewRecord(
      exerciseId: exerciseId,
      recordType: recordType,
      reps: reps,
      value: value,
      previousValue: existing?.value,
    );
  }
}
