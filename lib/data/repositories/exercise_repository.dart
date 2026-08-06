import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../domain/models/enums.dart';
import '../db/app_database.dart';

/// Collapses a display name to its lookup key.
///
/// Plan files reference exercises by name, so "Barbell  Bench Press" from a
/// generated file must resolve to an existing "barbell bench press" rather than
/// creating a near-duplicate catalog entry.
String normalizeExerciseName(String raw) =>
    raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Reads and writes the exercise catalog.
class ExerciseRepository {
  ExerciseRepository(this._db, {Clock clock = const SystemClock()})
    : _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  /// Active exercises, alphabetical. Archived entries are hidden from pickers
  /// but never deleted, so history that references them stays intact.
  Stream<List<ExerciseRow>> watchAll({
    bool includeArchived = false,
    ExerciseType? type,
    String? muscleGroup,
    String? equipment,
  }) => _filtered(
    includeArchived: includeArchived,
    type: type,
    muscleGroup: muscleGroup,
    equipment: equipment,
  ).watch();

  Future<List<ExerciseRow>> getAll({
    bool includeArchived = false,
    ExerciseType? type,
    String? muscleGroup,
    String? equipment,
  }) => _filtered(
    includeArchived: includeArchived,
    type: type,
    muscleGroup: muscleGroup,
    equipment: equipment,
  ).get();

  /// The one place the catalog's filters are expressed, so the live and
  /// one-shot reads can never drift apart.
  ///
  /// [muscleGroup] and [equipment] match case-insensitively: the values are
  /// free text, and an imported plan may well have written "barbell".
  SimpleSelectStatement<$ExercisesTable, ExerciseRow> _filtered({
    required bool includeArchived,
    ExerciseType? type,
    String? muscleGroup,
    String? equipment,
  }) {
    final query = _db.select(_db.exercises)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);

    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    if (type != null) {
      query.where((t) => t.type.equalsValue(type));
    }
    if (muscleGroup != null && muscleGroup.trim().isNotEmpty) {
      final needle = muscleGroup.trim().toLowerCase();
      query.where((t) => t.muscleGroup.lower().equals(needle));
    }
    if (equipment != null && equipment.trim().isNotEmpty) {
      final needle = equipment.trim().toLowerCase();
      query.where((t) => t.equipment.lower().equals(needle));
    }
    return query;
  }

  Future<ExerciseRow?> findById(int id) => (_db.select(
    _db.exercises,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Case- and whitespace-insensitive lookup.
  Future<ExerciseRow?> findByName(String name) {
    final key = normalizeExerciseName(name);
    return (_db.select(
      _db.exercises,
    )..where((t) => t.nameKey.equals(key))).getSingleOrNull();
  }

  Future<ExerciseRow> create({
    required String name,
    required ExerciseType type,
    CardioActivity? cardioActivity,
    String? muscleGroup,
    String? equipment,
    String? notes,
    bool isCustom = true,
  }) async {
    final now = _clock.now();
    final id = await _db
        .into(_db.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: name.trim(),
            nameKey: normalizeExerciseName(name),
            type: type,
            cardioActivity: Value(cardioActivity),
            muscleGroup: Value(muscleGroup),
            equipment: Value(equipment),
            notes: Value(notes),
            isCustom: Value(isCustom),
            createdAt: now,
            updatedAt: now,
          ),
        );
    final created = await findById(id);
    return created!;
  }

  /// Returns the existing exercise with this name, or creates it.
  ///
  /// This is how plan import resolves exercise references: a generated plan
  /// names movements without knowing what is already in the user's catalog.
  Future<ExerciseRow> ensure({
    required String name,
    required ExerciseType type,
    CardioActivity? cardioActivity,
  }) async {
    final existing = await findByName(name);
    if (existing != null) return existing;
    return create(name: name, type: type, cardioActivity: cardioActivity);
  }

  Future<void> rename(int id, String name) async {
    await (_db.update(_db.exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        name: Value(name.trim()),
        nameKey: Value(normalizeExerciseName(name)),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> updateDetails(
    int id, {
    Value<CardioActivity?> cardioActivity = const Value.absent(),
    Value<String?> muscleGroup = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) async {
    await (_db.update(_db.exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        cardioActivity: cardioActivity,
        muscleGroup: muscleGroup,
        equipment: equipment,
        notes: notes,
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> setArchived(int id, {required bool archived}) async {
    await (_db.update(_db.exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        isArchived: Value(archived),
        updatedAt: Value(_clock.now()),
      ),
    );
  }
}
