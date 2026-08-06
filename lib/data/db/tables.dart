/// The complete schema, kept in one file so the shape of the data is readable
/// at a glance.
///
/// Storage conventions, applied everywhere without exception:
///   * weights are **kilograms**, distances are **meters**, durations are
///     **seconds**, pace is **seconds per kilometer**. Imperial is a display
///     concern only, so changing the unit setting never migrates a row.
///   * enum columns persist the Dart constant name via `textEnum`. That is an
///     internal representation; the plan-file and backup formats use the stable
///     `wireName` instead. Renaming a Dart enum constant therefore requires a
///     schema migration, but never breaks an existing plan file.
library;

import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';

/// The exercise catalog. Both strength and cardio movements live here.
@DataClassName('ExerciseRow')
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Lower-cased, whitespace-collapsed [name]. Plan files reference exercises by
  /// name, so imports must match "Barbell Bench Press" to "barbell bench press"
  /// without creating a duplicate. SQLite's default TEXT comparison is
  /// case-sensitive, hence an explicit normalized column rather than a collation.
  TextColumn get nameKey => text()();

  TextColumn get type => textEnum<ExerciseType>()();

  /// Only meaningful when [type] is cardio; drives which fields the log screen
  /// prompts for (a swim has no incline).
  TextColumn get cardioActivity => textEnum<CardioActivity>().nullable()();

  TextColumn get muscleGroup => text().nullable()();

  TextColumn get equipment => text().nullable()();

  TextColumn get notes => text().nullable()();

  /// False for the seeded starter catalog, true for anything the user or an
  /// import created.
  BoolColumn get isCustom => boolean().withDefault(const Constant(true))();

  /// Archived exercises stay in history but are hidden from pickers. Exercises
  /// are never hard-deleted while sessions reference them.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {nameKey},
  ];
}

/// A training program. [mode] selects which progression behaviour applies.
@DataClassName('PlanRow')
class Plans extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 200)();

  TextColumn get description => text().nullable()();

  TextColumn get mode => textEnum<PlanMode>()();

  TextColumn get scheduleType => textEnum<ScheduleType>()();

  /// Periodized plans only.
  DateTimeColumn get startDate => dateTime().nullable()();

  /// Periodized plans only.
  IntColumn get durationWeeks => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  TextColumn get source => textEnum<PlanSource>()();

  /// The `schemaVersion` of the plan file this was imported from, for
  /// diagnosing files produced against an older format.
  TextColumn get schemaVersion => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

/// One workout day within a plan.
@DataClassName('PlanDayRow')
class PlanDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planId =>
      integer().references(Plans, #id, onDelete: KeyAction.cascade)();

  IntColumn get orderIndex => integer()();

  TextColumn get label => text()();

  /// Periodized plans place each day in a specific week.
  IntColumn get weekNumber => integer().nullable()();

  /// Set only when the plan's schedule type is weekly.
  TextColumn get dayOfWeek => textEnum<Weekday>().nullable()();

  TextColumn get notes => text().nullable()();
}

/// A group of exercises performed together, and the superset container.
///
/// Every exercise belongs to a block: a plain exercise is a [BlockKind.single]
/// block holding one item. [rounds] is what would otherwise be called "sets" —
/// three rounds of a single-exercise block is 3x8.
@DataClassName('PlanBlockRow')
class PlanBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planDayId =>
      integer().references(PlanDays, #id, onDelete: KeyAction.cascade)();

  IntColumn get orderIndex => integer()();

  TextColumn get kind => textEnum<BlockKind>()();

  TextColumn get label => text().nullable()();

  IntColumn get rounds => integer().withDefault(const Constant(1))();

  /// Rest between the exercises *inside* a superset. Usually zero — moving
  /// straight to the next movement is the point of a superset.
  IntColumn get restBetweenExercisesSeconds =>
      integer().withDefault(const Constant(0))();

  /// Rest after finishing a full round of the block.
  IntColumn get restAfterRoundSeconds =>
      integer().withDefault(const Constant(90))();
}

/// One prescribed exercise inside a block.
///
/// Strength and cardio prescriptions share this table with nullable columns for
/// the other type. The alternative — child tables — would add joins to every
/// read for no gain; the invariant is enforced in the domain layer and covered
/// by tests instead.
@DataClassName('PlanItemRow')
class PlanItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planBlockId =>
      integer().references(PlanBlocks, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.restrict)();

  IntColumn get orderIndex => integer()();

  // ---- Strength prescription ----

  IntColumn get targetReps => integer().nullable()();

  /// The literal prescribed weight. For [WeightMode.absolute] this is what gets
  /// used; for baseline modes it seeds the baseline on first import.
  RealColumn get targetWeightKg => real().nullable()();

  TextColumn get weightMode => textEnum<WeightMode>().nullable()();

  /// Increment for [WeightMode.baselinePlus].
  RealColumn get weightOffsetKg => real().nullable()();

  /// Percentage for [WeightMode.baselinePercent], where 85 means 85%.
  RealColumn get weightPercent => real().nullable()();

  RealColumn get rpe => real().nullable()();

  /// Free-form tempo notation such as `3-1-1`.
  TextColumn get tempo => text().nullable()();

  BoolColumn get toFailure => boolean().withDefault(const Constant(false))();

  // ---- Cardio prescription ----

  IntColumn get targetDurationSeconds => integer().nullable()();

  RealColumn get targetDistanceMeters => real().nullable()();

  RealColumn get targetPaceSecPerKm => real().nullable()();

  RealColumn get targetInclinePercent => real().nullable()();

  IntColumn get targetResistanceLevel => integer().nullable()();

  /// Interval prescription, stored as the JSON array from the plan file.
  /// Opaque to SQL and only ever read as a whole.
  TextColumn get intervalsJson => text().nullable()();

  TextColumn get notes => text().nullable()();
}

/// One workout instance. [planId] is null for ad-hoc workouts, which are fully
/// supported — the app is usable before any plan exists.
@DataClassName('SessionRow')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planId => integer().nullable().references(
    Plans,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get planDayId => integer().nullable().references(
    PlanDays,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get title => text().nullable()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime().nullable()();

  TextColumn get status => textEnum<SessionStatus>()();

  /// Elapsed working time, which can be less than `endedAt - startedAt` if the
  /// session sat open. Stored rather than derived so history stays truthful.
  IntColumn get durationSeconds => integer().nullable()();

  TextColumn get notes => text().nullable()();
}

/// A single logged strength set.
///
/// The `planned*` columns are **snapshots** taken when the session starts.
/// Editing a plan next month must not rewrite what last month's workout claimed
/// to prescribe, and copying two values onto the row achieves that without any
/// separate history tables.
@DataClassName('StrengthSetRow')
class StrengthSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.restrict)();

  IntColumn get planItemId => integer().nullable().references(
    PlanItems,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Which block within the session, preserving superset grouping in history
  /// even after the originating plan changes.
  IntColumn get groupIndex => integer()();

  TextColumn get groupKind => textEnum<BlockKind>()();

  TextColumn get groupLabel => text().nullable()();

  /// Which time through the block (0-based).
  IntColumn get roundIndex => integer()();

  /// Position within the block (0-based).
  IntColumn get itemIndex => integer()();

  IntColumn get plannedReps => integer().nullable()();

  RealColumn get plannedWeightKg => real().nullable()();

  IntColumn get actualReps => integer().nullable()();

  RealColumn get actualWeightKg => real().nullable()();

  RealColumn get rpe => real().nullable()();

  /// Warm-up sets are excluded from baseline promotion and personal records.
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  TextColumn get status => textEnum<EntryStatus>()();

  IntColumn get restTakenSeconds => integer().nullable()();

  DateTimeColumn get performedAt => dateTime().nullable()();

  TextColumn get notes => text().nullable()();
}

/// A single logged cardio effort, following the same snapshot pattern as
/// [StrengthSets].
@DataClassName('CardioEntryRow')
class CardioEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.restrict)();

  IntColumn get planItemId => integer().nullable().references(
    PlanItems,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get groupIndex => integer()();

  TextColumn get groupKind => textEnum<BlockKind>()();

  TextColumn get groupLabel => text().nullable()();

  IntColumn get roundIndex => integer()();

  IntColumn get itemIndex => integer()();

  IntColumn get plannedDurationSeconds => integer().nullable()();

  RealColumn get plannedDistanceMeters => real().nullable()();

  RealColumn get plannedPaceSecPerKm => real().nullable()();

  IntColumn get actualDurationSeconds => integer().nullable()();

  RealColumn get actualDistanceMeters => real().nullable()();

  /// Derived from duration and distance on write, stored so history and chart
  /// queries do not have to recompute it per row.
  RealColumn get actualPaceSecPerKm => real().nullable()();

  RealColumn get inclinePercent => real().nullable()();

  IntColumn get resistanceLevel => integer().nullable()();

  IntColumn get avgHeartRate => integer().nullable()();

  IntColumn get maxHeartRate => integer().nullable()();

  IntColumn get calories => integer().nullable()();

  RealColumn get elevationGainMeters => real().nullable()();

  TextColumn get status => textEnum<EntryStatus>()();

  DateTimeColumn get performedAt => dateTime().nullable()();

  TextColumn get notes => text().nullable()();
}

/// Laps recorded by the in-app cardio timer.
@DataClassName('CardioSplitRow')
class CardioSplits extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get cardioEntryId =>
      integer().references(CardioEntries, #id, onDelete: KeyAction.cascade)();

  IntColumn get splitIndex => integer()();

  IntColumn get durationSeconds => integer()();

  RealColumn get distanceMeters => real().nullable()();
}

/// The current working weight for a static plan.
///
/// Keyed on (plan, exercise, reps) because the promotion rule is "heaviest
/// weight completed **at the prescribed rep count**". Scoping to a plan keeps
/// two static plans from fighting over one number.
@DataClassName('ExerciseBaselineRow')
class ExerciseBaselines extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planId =>
      integer().references(Plans, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();

  IntColumn get reps => integer()();

  RealColumn get weightKg => real()();

  DateTimeColumn get achievedAt => dateTime()();

  IntColumn get sourceSetId => integer().nullable().references(
    StrengthSets,
    #id,
    onDelete: KeyAction.setNull,
  )();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {planId, exerciseId, reps},
  ];
}

/// Best-ever performances, recorded for **both** plan modes.
@DataClassName('PersonalRecordRow')
class PersonalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();

  TextColumn get recordType => textEnum<RecordType>()();

  /// Rep count for rep-specific records. **Zero** means "not applicable"
  /// rather than null: SQLite treats NULLs as distinct in a unique index, so a
  /// nullable column here would silently permit duplicate records.
  IntColumn get reps => integer().withDefault(const Constant(0))();

  /// Interpreted according to [recordType] — kilograms, meters, seconds, or
  /// seconds per kilometer.
  RealColumn get value => real()();

  DateTimeColumn get achievedAt => dateTime()();

  IntColumn get sessionId => integer().nullable().references(
    Sessions,
    #id,
    onDelete: KeyAction.setNull,
  )();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {exerciseId, recordType, reps},
  ];
}

/// Key/value application settings (unit system, default rest, notification
/// preferences, theme). A table rather than shared preferences so that a backup
/// export captures settings along with everything else.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
