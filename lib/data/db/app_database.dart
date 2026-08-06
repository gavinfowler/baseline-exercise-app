import 'package:drift/drift.dart';
import 'package:drift/native.dart';

// Referenced by the generated part file below, which shares this library's
// import scope: every `textEnum` column resolves to one of these types.
import '../../domain/models/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The application database.
///
/// Construct with [AppDatabase.memory] in tests — every test then gets a real,
/// isolated SQLite instance in a few milliseconds, so query logic is verified
/// against actual SQL rather than against mocks.
@DriftDatabase(
  tables: [
    Exercises,
    Plans,
    PlanDays,
    PlanBlocks,
    PlanItems,
    Sessions,
    StrengthSets,
    CardioEntries,
    CardioSplits,
    ExerciseBaselines,
    PersonalRecords,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// An isolated in-memory database. Used by tests and by the `SEED_DEMO`
  /// throwaway mode.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  /// Store timestamps as ISO-8601 text rather than as unix seconds.
  ///
  /// The integer default truncates to whole seconds and hands back *local*
  /// `DateTime`s regardless of what was written, which makes "when did this set
  /// happen" ambiguous across a timezone change. Text storage keeps the exact
  /// instant. Chosen at schema v1, before any data exists, because changing it
  /// later would require rewriting every timestamp column.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // SQLite disables foreign keys per connection by default, so the
      // cascade rules declared in the schema would silently do nothing.
      // This must run on every open, not just on create.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
