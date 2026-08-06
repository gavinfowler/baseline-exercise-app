import 'package:collection/collection.dart';

/// Shared vocabulary for the whole app.
///
/// Each enum carries a stable `wireName` used in the plan-file JSON and in the
/// backup export. Dart identifiers cannot always match the wire form (`static`
/// is a reserved word), and enum *names* must never be load-bearing for a file
/// format anyway — renaming a Dart constant must not break existing plan files.
///
/// Every `fromWire` returns `null` for unknown input rather than throwing, so
/// callers can turn it into a precise validation message pointing at the file.
enum ExerciseType {
  strength('strength'),
  cardio('cardio');

  const ExerciseType(this.wireName);

  final String wireName;

  static ExerciseType? fromWire(String? value) =>
      ExerciseType.values.firstWhereOrNull((e) => e.wireName == value);
}

/// The kinds of cardio the app knows how to prompt for. Each one implies a
/// different set of relevant fields (a swim has no incline).
enum CardioActivity {
  run('run', 'Run'),
  walk('walk', 'Walk'),
  hike('hike', 'Hike'),
  cycle('cycle', 'Cycle'),
  row('row', 'Row'),
  swim('swim', 'Swim'),
  elliptical('elliptical', 'Elliptical'),
  stairs('stairs', 'Stairs'),
  other('other', 'Other');

  const CardioActivity(this.wireName, this.label);

  final String wireName;

  /// What the user sees. Kept separate from [wireName] so the file format stays
  /// lower-case and stable while the UI reads as English.
  final String label;

  /// Distance-and-pace activities, where prescribing a pace makes sense. A
  /// stair climber has no pace worth writing down.
  bool get tracksPace => const {
    CardioActivity.run,
    CardioActivity.walk,
    CardioActivity.hike,
    CardioActivity.cycle,
    CardioActivity.row,
    CardioActivity.swim,
  }.contains(this);

  static CardioActivity? fromWire(String? value) =>
      CardioActivity.values.firstWhereOrNull((e) => e.wireName == value);
}

/// The two planning behaviours that define this app.
enum PlanMode {
  /// Repeat the same workout indefinitely. Beating the prescribed weight at the
  /// prescribed reps *raises the baseline*, so the plan tracks the user upward.
  staticPlan('static'),

  /// A fixed program over a date range. Beating the prescription is recorded as
  /// a personal record but **never** alters the plan.
  periodized('periodized');

  const PlanMode(this.wireName);

  final String wireName;

  static PlanMode? fromWire(String? value) =>
      PlanMode.values.firstWhereOrNull((e) => e.wireName == value);
}

/// How a plan's days map onto the calendar.
enum ScheduleType {
  /// Days are pinned to weekdays ("every Monday").
  weekly('weekly'),

  /// Days rotate in order regardless of date ("Day 1, Day 2, Day 3, repeat").
  sequential('sequential');

  const ScheduleType(this.wireName);

  final String wireName;

  static ScheduleType? fromWire(String? value) =>
      ScheduleType.values.firstWhereOrNull((e) => e.wireName == value);
}

enum PlanSource {
  ui('ui'),
  imported('imported');

  const PlanSource(this.wireName);

  final String wireName;

  static PlanSource? fromWire(String? value) =>
      PlanSource.values.firstWhereOrNull((e) => e.wireName == value);
}

/// How the exercises inside a block relate to each other.
///
/// Every exercise lives in a block; a plain exercise is a [single] block holding
/// one item. That uniformity removes the "is this a superset?" branch from the
/// session runner, the rest timer and the importer.
enum BlockKind {
  single('single', 'Exercise'),

  /// Two or more exercises performed back to back, then rest.
  superset('superset', 'Superset'),

  /// Like a superset but typically longer and endurance-oriented.
  circuit('circuit', 'Circuit');

  const BlockKind(this.wireName, this.label);

  final String wireName;

  /// What the user sees, so a heading never reads as `superset`.
  final String label;

  /// True when the block is expected to hold more than one exercise.
  bool get isGrouped => this != BlockKind.single;

  static BlockKind? fromWire(String? value) =>
      BlockKind.values.firstWhereOrNull((e) => e.wireName == value);
}

/// How a plan item's prescribed weight is determined at session time.
enum WeightMode {
  /// Use the literal weight written in the plan.
  absolute('absolute'),

  /// Use the current baseline for this exercise at these reps.
  baseline('baseline'),

  /// Baseline plus a fixed increment.
  baselinePlus('baselinePlus'),

  /// A percentage of the baseline (e.g. a 70% back-off set).
  baselinePercent('baselinePercent');

  const WeightMode(this.wireName);

  final String wireName;

  bool get usesBaseline => this != WeightMode.absolute;

  static WeightMode? fromWire(String? value) =>
      WeightMode.values.firstWhereOrNull((e) => e.wireName == value);
}

enum SessionStatus {
  inProgress('inProgress'),
  completed('completed'),
  abandoned('abandoned');

  const SessionStatus(this.wireName);

  final String wireName;

  static SessionStatus? fromWire(String? value) =>
      SessionStatus.values.firstWhereOrNull((e) => e.wireName == value);
}

/// Per-entry outcome. `pending` rows are created up front when a planned session
/// starts, so the session screen can show the whole workout before it is done.
enum EntryStatus {
  pending('pending'),
  completed('completed'),
  skipped('skipped');

  const EntryStatus(this.wireName);

  final String wireName;

  static EntryStatus? fromWire(String? value) =>
      EntryStatus.values.firstWhereOrNull((e) => e.wireName == value);
}

/// Categories of personal record. Recorded for **both** plan modes — a periodized
/// plan still celebrates a PR, it just does not change the prescription.
enum RecordType {
  /// Heaviest weight completed at a specific rep count. This is also the metric
  /// that drives static-plan baseline promotion.
  maxWeightAtReps('maxWeightAtReps'),

  /// Heaviest weight at any rep count.
  maxWeight('maxWeight'),

  /// Best Epley-estimated one-rep max.
  estimatedOneRepMax('estimatedOneRepMax'),

  /// Fastest pace (lowest seconds per km) for a cardio activity.
  bestPace('bestPace'),

  longestDistance('longestDistance'),
  longestDuration('longestDuration');

  const RecordType(this.wireName);

  final String wireName;

  /// Lower values win for pace; every other record type is "higher is better".
  bool get lowerIsBetter => this == RecordType.bestPace;

  static RecordType? fromWire(String? value) =>
      RecordType.values.firstWhereOrNull((e) => e.wireName == value);
}

enum Weekday {
  monday('monday'),
  tuesday('tuesday'),
  wednesday('wednesday'),
  thursday('thursday'),
  friday('friday'),
  saturday('saturday'),
  sunday('sunday');

  const Weekday(this.wireName);

  final String wireName;

  /// Matches [DateTime.weekday], which is 1-based starting at Monday.
  int get dateTimeWeekday => index + 1;

  static Weekday? fromWire(String? value) =>
      Weekday.values.firstWhereOrNull((e) => e.wireName == value);
}
