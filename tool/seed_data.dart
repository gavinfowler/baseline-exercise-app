/// Generates realistic training data as a backup file.
///
/// Run it, then load the result through Settings → Restore from backup:
///
/// ```
/// dart run tool/seed_data.dart
/// ```
///
/// The output is in the app's own backup format rather than a SQLite file, for
/// three reasons: `BackupService.restoreFromJson` already validates and applies
/// it inside one transaction, the same file loads on Android and on Windows, and
/// nothing in `lib/` has to gain a debug-only code path to support it.
///
/// Only pure-Dart parts of the app are imported — the enums, so wire names stay
/// in step, and [RunWorkout], so structured cardio is encoded exactly the way
/// the app reads it. Reaching for `AppDatabase` would drag in `path_provider`
/// and this would no longer run under plain `dart`.
///
/// Options:
///   `--out <dir>`        where to write (default tool/seed)
///   `--end-date <date>`  ISO date the history ends on (default today)
///   `--weeks <n>`        how many weeks of history (default 18)
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/models/run_segment.dart';

/// Must match `kBackupVersion` in `lib/domain/backup/backup_service.dart`.
/// The restore refuses anything else.
const String backupVersion = '1.0';

/// Fixed so a re-run produces a reviewable diff rather than fresh noise.
const int randomSeed = 42;

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);

  final full = buildSeedDocument(
    endDate: options.endDate,
    weeks: options.weeks,
  );
  final starter = buildSeedDocument(
    endDate: options.endDate,
    weeks: 0,
    plansWanted: 1,
  );

  final dir = Directory(options.outDir);
  await dir.create(recursive: true);

  await _write(dir, 'baseline-seed-full.json', full);
  await _write(dir, 'baseline-seed-starter.json', starter);

  stdout.writeln('\nLoad one through Settings → Restore from backup.');
}

Future<void> _write(
  Directory dir,
  String name,
  Map<String, Object?> document,
) async {
  final file = File('${dir.path}/$name');
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(document),
  );

  String count(String key) =>
      (document[key] as List<Object?>).length.toString().padLeft(5);

  stdout.writeln(file.path);
  stdout.writeln('  ${count('exercises')} exercises');
  stdout.writeln('  ${count('plans')} plans');
  stdout.writeln('  ${count('sessions')} sessions');
  stdout.writeln('  ${count('strengthSets')} strength sets');
  stdout.writeln('  ${count('cardioEntries')} cardio entries');
  stdout.writeln('  ${count('personalRecords')} personal records');
}

class _Options {
  const _Options({
    required this.outDir,
    required this.endDate,
    required this.weeks,
  });

  final String outDir;
  final DateTime endDate;
  final int weeks;

  static _Options parse(List<String> args) {
    var outDir = 'tool/seed';
    var weeks = 18;
    var endDate = DateTime.now();

    for (var i = 0; i < args.length - 1; i++) {
      final value = args[i + 1];
      switch (args[i]) {
        case '--out':
          outDir = value;
        case '--weeks':
          weeks = int.tryParse(value) ?? weeks;
        case '--end-date':
          endDate = DateTime.tryParse(value) ?? endDate;
      }
    }

    return _Options(
      outDir: outDir,
      // Anchored to midday so a timezone shift on export cannot move a session
      // onto the previous or next day.
      endDate: DateTime(endDate.year, endDate.month, endDate.day, 12),
      weeks: weeks,
    );
  }
}

/// Builds one whole backup document.
///
/// [weeks] of zero produces a catalog and plans with no history, which is what
/// the starter file is for. [plansWanted] trims the plan list from the front.
Map<String, Object?> buildSeedDocument({
  required DateTime endDate,
  int weeks = 18,
  int plansWanted = 3,
}) {
  final builder = _SeedBuilder(
    endDate: endDate,
    weeks: weeks,
    plansWanted: plansWanted,
  );
  return builder.build();
}

// ---------------------------------------------------------------- the catalog

class _Ex {
  const _Ex(
    this.id,
    this.name,
    this.type, {
    this.activity,
    this.muscleGroup,
    this.equipment,
    this.isCustom = false,
    this.isArchived = false,
  });

  final int id;
  final String name;
  final ExerciseType type;
  final CardioActivity? activity;
  final String? muscleGroup;
  final String? equipment;
  final bool isCustom;
  final bool isArchived;
}

/// Deliberately its own list rather than an import of `seed_exercises.dart`,
/// which cannot be reached without pulling drift and `path_provider` in with it.
/// A restore replaces the catalog wholesale, so this has to stand on its own.
const List<_Ex> _catalog = [
  // ---- Chest ----
  _Ex(
    1,
    'Barbell Bench Press',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Barbell',
  ),
  _Ex(
    2,
    'Incline Barbell Bench Press',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Barbell',
  ),
  _Ex(
    3,
    'Dumbbell Bench Press',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Dumbbell',
  ),
  _Ex(
    4,
    'Cable Chest Fly',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Cable',
  ),
  _Ex(
    5,
    'Push-Up',
    ExerciseType.strength,
    muscleGroup: 'Chest',
    equipment: 'Bodyweight',
  ),

  // ---- Back ----
  _Ex(
    6,
    'Deadlift',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Barbell',
  ),
  _Ex(
    7,
    'Barbell Row',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Barbell',
  ),
  _Ex(
    8,
    'Pull-Up',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Bodyweight',
  ),
  _Ex(
    9,
    'Lat Pulldown',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),
  _Ex(
    10,
    'Seated Cable Row',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),
  _Ex(
    11,
    'Face Pull',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),

  // ---- Legs ----
  _Ex(
    12,
    'Back Squat',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  _Ex(
    13,
    'Front Squat',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  _Ex(
    14,
    'Romanian Deadlift',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  _Ex(
    15,
    'Leg Press',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  _Ex(
    16,
    'Walking Lunge',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Dumbbell',
  ),
  _Ex(
    17,
    'Leg Curl',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  _Ex(
    18,
    'Standing Calf Raise',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  _Ex(
    19,
    'Hip Thrust',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),

  // ---- Shoulders ----
  _Ex(
    20,
    'Overhead Press',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Barbell',
  ),
  _Ex(
    21,
    'Dumbbell Shoulder Press',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Dumbbell',
  ),
  _Ex(
    22,
    'Lateral Raise',
    ExerciseType.strength,
    muscleGroup: 'Shoulders',
    equipment: 'Dumbbell',
  ),

  // ---- Arms ----
  _Ex(
    23,
    'Barbell Curl',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Barbell',
  ),
  _Ex(
    24,
    'Dumbbell Curl',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Dumbbell',
  ),
  _Ex(
    25,
    'Triceps Pushdown',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Cable',
  ),
  _Ex(
    26,
    'Dip',
    ExerciseType.strength,
    muscleGroup: 'Arms',
    equipment: 'Bodyweight',
  ),

  // ---- Core ----
  _Ex(
    27,
    'Plank',
    ExerciseType.strength,
    muscleGroup: 'Core',
    equipment: 'Bodyweight',
  ),
  _Ex(
    28,
    'Hanging Leg Raise',
    ExerciseType.strength,
    muscleGroup: 'Core',
    equipment: 'Bodyweight',
  ),
  _Ex(
    29,
    'Cable Crunch',
    ExerciseType.strength,
    muscleGroup: 'Core',
    equipment: 'Cable',
  ),

  // ---- Cardio ----
  _Ex(30, 'Outdoor Run', ExerciseType.cardio, activity: CardioActivity.run),
  _Ex(
    31,
    'Treadmill Run',
    ExerciseType.cardio,
    activity: CardioActivity.run,
    equipment: 'Treadmill',
  ),
  _Ex(32, 'Walk', ExerciseType.cardio, activity: CardioActivity.walk),
  _Ex(33, 'Hike', ExerciseType.cardio, activity: CardioActivity.hike),
  _Ex(34, 'Outdoor Cycle', ExerciseType.cardio, activity: CardioActivity.cycle),
  _Ex(
    35,
    'Stationary Bike',
    ExerciseType.cardio,
    activity: CardioActivity.cycle,
    equipment: 'Stationary Bike',
  ),
  _Ex(
    36,
    'Rowing Machine',
    ExerciseType.cardio,
    activity: CardioActivity.row,
    equipment: 'Rower',
  ),
  _Ex(
    37,
    'Elliptical',
    ExerciseType.cardio,
    activity: CardioActivity.elliptical,
    equipment: 'Elliptical',
  ),
  _Ex(
    38,
    'Stair Climber',
    ExerciseType.cardio,
    activity: CardioActivity.stairs,
    equipment: 'Stair Climber',
  ),
  _Ex(39, 'Swim', ExerciseType.cardio, activity: CardioActivity.swim),

  // ---- The user's own additions, so isCustom is exercised ----
  _Ex(
    40,
    'Trap Bar Deadlift',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Trap Bar',
    isCustom: true,
  ),
  _Ex(
    41,
    'Weighted Pull-Up',
    ExerciseType.strength,
    muscleGroup: 'Back',
    equipment: 'Bodyweight',
    isCustom: true,
  ),
  _Ex(
    42,
    'Sled Push',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Sled',
    isCustom: true,
  ),
  // Archived, so the catalog's archive filter has something to find.
  _Ex(
    43,
    'Smith Machine Squat',
    ExerciseType.strength,
    muscleGroup: 'Legs',
    equipment: 'Machine',
    isCustom: true,
    isArchived: true,
  ),
];

// ------------------------------------------------------------ plan structures

/// One prescribed exercise, plus the numbers used to invent a plausible history
/// for it. Keeping both on one object is what stops the logged sets drifting
/// away from what the plan actually asked for.
class _Item {
  const _Item.strength(
    this.exerciseId, {
    required this.reps,
    required this.startWeightKg,
    this.weightMode = WeightMode.baseline,
    this.weightOffsetKg,
    this.weightPercent,
    this.gainPerFortnightKg = 2.5,
  }) : type = ExerciseType.strength,
       durationSeconds = null,
       distanceMeters = null,
       paceSecPerKm = null,
       inclinePercent = null,
       resistanceLevel = null,
       intervals = null;

  const _Item.cardio(
    this.exerciseId, {
    this.durationSeconds,
    this.distanceMeters,
    this.paceSecPerKm,
    this.inclinePercent,
    this.resistanceLevel,
    this.intervals,
  }) : type = ExerciseType.cardio,
       reps = 0,
       startWeightKg = 0,
       weightMode = WeightMode.absolute,
       weightOffsetKg = null,
       weightPercent = null,
       gainPerFortnightKg = 0;

  final ExerciseType type;
  final int exerciseId;

  final int reps;
  final double startWeightKg;
  final WeightMode weightMode;
  final double? weightOffsetKg;
  final double? weightPercent;
  final double gainPerFortnightKg;

  final int? durationSeconds;
  final double? distanceMeters;
  final double? paceSecPerKm;
  final double? inclinePercent;
  final int? resistanceLevel;
  final RunWorkout? intervals;
}

class _Block {
  const _Block(
    this.items, {
    this.kind = BlockKind.single,
    this.label,
    this.rounds = 3,
    this.restBetweenExercisesSeconds = 0,
    this.restAfterRoundSeconds = 120,
  });

  final List<_Item> items;
  final BlockKind kind;
  final String? label;
  final int rounds;
  final int restBetweenExercisesSeconds;
  final int restAfterRoundSeconds;
}

class _Day {
  const _Day(this.label, this.blocks, {this.dayOfWeek, this.weekNumber});

  final String label;
  final List<_Block> blocks;
  final Weekday? dayOfWeek;
  final int? weekNumber;
}

class _Plan {
  const _Plan({
    required this.name,
    required this.description,
    required this.mode,
    required this.scheduleType,
    required this.days,
    this.durationWeeks,
    this.isActive = false,
  });

  final String name;
  final String description;
  final PlanMode mode;
  final ScheduleType scheduleType;
  final List<_Day> days;
  final int? durationWeeks;
  final bool isActive;
}

/// A slot in the training week: which plan day is performed, and on which
/// weekday.
class _Scheduled {
  const _Scheduled(
    this.planIndex,
    this.dayIndex,
    this.weekday,
    this.hour, {
    this.parity,
  });

  final int planIndex;
  final int dayIndex;

  /// 1 = Monday, matching `DateTime.weekday`.
  final int weekday;
  final int hour;

  /// Null for every week. Otherwise the slot runs only on weeks whose index is
  /// even (0) or odd (1), which is how two different sessions share one weekday.
  final int? parity;

  bool runsIn(int week) => parity == null || week.isEven == (parity == 0);
}

// -------------------------------------------------------------- the generator

class _SeedBuilder {
  _SeedBuilder({
    required this.endDate,
    required this.weeks,
    required this.plansWanted,
  });

  final DateTime endDate;
  final int weeks;
  final int plansWanted;

  final _random = Random(randomSeed);

  final _plans = <Map<String, Object?>>[];
  final _planDays = <Map<String, Object?>>[];
  final _planBlocks = <Map<String, Object?>>[];
  final _planItems = <Map<String, Object?>>[];
  final _sessions = <Map<String, Object?>>[];
  final _strengthSets = <Map<String, Object?>>[];
  final _cardioEntries = <Map<String, Object?>>[];
  final _cardioSplits = <Map<String, Object?>>[];
  final _baselines = <Map<String, Object?>>[];
  final _records = <Map<String, Object?>>[];

  var _nextPlanId = 1;
  var _nextDayId = 1;
  var _nextBlockId = 1;
  var _nextItemId = 1;
  var _nextSessionId = 1;
  var _nextSetId = 1;
  var _nextCardioId = 1;
  var _nextSplitId = 1;
  var _nextBaselineId = 1;
  var _nextRecordId = 1;

  /// planIndex → dayIndex → blockIndex → itemIndex → the written planItem id,
  /// so a logged row can point back at exactly what prescribed it.
  final _itemIds = <int, List<List<List<int>>>>{};

  /// planIndex → the written plan id.
  final _planIds = <int, int>{};

  /// Best completed set per exercise, for deriving records rather than
  /// inventing them.
  final _bestByReps = <(int, int), _Achievement>{};
  final _bestOverall = <int, _Achievement>{};
  final _bestCardio = <int, _CardioBest>{};

  Map<String, Object?> build() {
    final plans = _definePlans().take(plansWanted).toList();

    for (var i = 0; i < plans.length; i++) {
      _writePlan(i, plans[i]);
    }
    if (weeks > 0) {
      _writeHistory(plans);
      _writeBaselines(plans);
      _writeRecords();
    }

    return {
      'backupVersion': backupVersion,
      'exportedAt': endDate.toUtc().toIso8601String(),
      'exercises': [for (final e in _catalog) _exercise(e)],
      'plans': _plans,
      'planDays': _planDays,
      'planBlocks': _planBlocks,
      'planItems': _planItems,
      'sessions': _sessions,
      'strengthSets': _strengthSets,
      'cardioEntries': _cardioEntries,
      'cardioSplits': _cardioSplits,
      'exerciseBaselines': _baselines,
      'personalRecords': _records,
      'settings': {
        'unitSystem': 'metric',
        'defaultRestSeconds': '120',
        'restSoundEnabled': 'true',
        'restVibrationEnabled': 'true',
        'restNotificationEnabled': 'false',
      },
    };
  }

  // ------------------------------------------------------------- definitions

  List<_Plan> _definePlans() => [
    const _Plan(
      name: 'Upper/Lower Strength',
      description:
          'Four days a week, the same movements every week. Working weights '
          'climb whenever the target reps are beaten.',
      mode: PlanMode.staticPlan,
      scheduleType: ScheduleType.weekly,
      isActive: true,
      days: [
        _Day('Upper A', [
          _Block(
            [_Item.strength(1, reps: 5, startWeightKg: 70)],
            label: 'Bench press',
            rounds: 4,
            restAfterRoundSeconds: 180,
          ),
          _Block(
            [
              _Item.strength(7, reps: 8, startWeightKg: 60),
              _Item.strength(
                11,
                reps: 15,
                startWeightKg: 20,
                weightMode: WeightMode.absolute,
                gainPerFortnightKg: 0,
              ),
            ],
            kind: BlockKind.superset,
            label: 'Row and face pull',
            restBetweenExercisesSeconds: 15,
            restAfterRoundSeconds: 120,
          ),
          _Block([
            _Item.strength(
              25,
              reps: 12,
              startWeightKg: 30,
              weightMode: WeightMode.baselinePlus,
              weightOffsetKg: 2.5,
            ),
          ], restAfterRoundSeconds: 90),
        ], dayOfWeek: Weekday.monday),
        _Day('Lower A', [
          _Block(
            [_Item.strength(12, reps: 5, startWeightKg: 90)],
            label: 'Back squat',
            rounds: 4,
            restAfterRoundSeconds: 210,
          ),
          _Block([
            _Item.strength(14, reps: 8, startWeightKg: 70),
          ], restAfterRoundSeconds: 150),
          _Block(
            [
              _Item.strength(
                17,
                reps: 12,
                startWeightKg: 40,
                weightMode: WeightMode.absolute,
                gainPerFortnightKg: 0,
              ),
              _Item.strength(
                18,
                reps: 15,
                startWeightKg: 60,
                weightMode: WeightMode.absolute,
                gainPerFortnightKg: 0,
              ),
              _Item.strength(
                28,
                reps: 12,
                startWeightKg: 0,
                weightMode: WeightMode.absolute,
                gainPerFortnightKg: 0,
              ),
            ],
            kind: BlockKind.circuit,
            label: 'Accessory circuit',
            restBetweenExercisesSeconds: 20,
            restAfterRoundSeconds: 90,
          ),
        ], dayOfWeek: Weekday.tuesday),
        _Day('Upper B', [
          _Block(
            [_Item.strength(20, reps: 6, startWeightKg: 45)],
            label: 'Overhead press',
            rounds: 4,
            restAfterRoundSeconds: 180,
          ),
          _Block([
            _Item.strength(
              9,
              reps: 10,
              startWeightKg: 55,
              weightMode: WeightMode.baselinePercent,
              weightPercent: 90,
            ),
          ], restAfterRoundSeconds: 120),
          _Block(
            [
              _Item.strength(23, reps: 10, startWeightKg: 30),
              _Item.strength(
                22,
                reps: 15,
                startWeightKg: 10,
                weightMode: WeightMode.absolute,
                gainPerFortnightKg: 0,
              ),
            ],
            kind: BlockKind.superset,
            label: 'Arms and delts',
            restBetweenExercisesSeconds: 10,
            restAfterRoundSeconds: 90,
          ),
        ], dayOfWeek: Weekday.thursday),
        _Day('Lower B', [
          _Block(
            [_Item.strength(6, reps: 5, startWeightKg: 110)],
            label: 'Deadlift',
            rounds: 3,
            restAfterRoundSeconds: 240,
          ),
          _Block([
            _Item.strength(19, reps: 10, startWeightKg: 80),
          ], restAfterRoundSeconds: 120),
          _Block([
            _Item.strength(
              16,
              reps: 12,
              startWeightKg: 16,
              weightMode: WeightMode.absolute,
              gainPerFortnightKg: 0,
            ),
          ], restAfterRoundSeconds: 90),
        ], dayOfWeek: Weekday.friday),
      ],
    ),

    _Plan(
      name: 'Base Building (Running)',
      description:
          'Three runs a week — one easy, one structured, one long — plus a '
          'machine day every other week. Paces are prescribed per kilometre.',
      mode: PlanMode.staticPlan,
      scheduleType: ScheduleType.weekly,
      days: [
        const _Day('Easy Run', [
          _Block(
            [
              _Item.cardio(
                30,
                durationSeconds: 2400,
                distanceMeters: 6800,
                paceSecPerKm: 353,
              ),
            ],
            rounds: 1,
            restAfterRoundSeconds: 0,
          ),
        ], dayOfWeek: Weekday.wednesday),
        _Day('Intervals', [
          _Block(
            [
              _Item.cardio(
                30,
                durationSeconds: 2700,
                distanceMeters: 8400,
                paceSecPerKm: 321,
                intervals: _intervalWorkout(),
              ),
            ],
            rounds: 1,
            restAfterRoundSeconds: 0,
          ),
        ], dayOfWeek: Weekday.saturday),
        const _Day('Long Run', [
          _Block(
            [
              _Item.cardio(
                30,
                durationSeconds: 4800,
                distanceMeters: 14000,
                paceSecPerKm: 343,
              ),
            ],
            rounds: 1,
            restAfterRoundSeconds: 0,
          ),
        ], dayOfWeek: Weekday.sunday),
        // The machines, so incline and resistance appear in the seeded data
        // rather than only being reachable from a plan file.
        const _Day('Cross-Train', [
          _Block(
            [
              _Item.cardio(
                35,
                durationSeconds: 1800,
                distanceMeters: 12000,
                // 24 km/h, which is what makes the duration and distance agree.
                paceSecPerKm: 150,
                resistanceLevel: 10,
              ),
            ],
            rounds: 1,
            restAfterRoundSeconds: 60,
          ),
          _Block(
            [
              _Item.cardio(
                36,
                durationSeconds: 900,
                distanceMeters: 3000,
                paceSecPerKm: 300,
                resistanceLevel: 5,
              ),
            ],
            rounds: 1,
            restAfterRoundSeconds: 60,
          ),
          _Block(
            [
              _Item.cardio(
                31,
                durationSeconds: 1200,
                distanceMeters: 3000,
                paceSecPerKm: 400,
                inclinePercent: 8,
              ),
            ],
            rounds: 1,
            restAfterRoundSeconds: 0,
          ),
        ], dayOfWeek: Weekday.wednesday),
      ],
    ),

    const _Plan(
      name: '8-Week Strength Block',
      description:
          'A fixed program. The prescribed numbers never move; beating them is '
          'recorded as a personal record instead.',
      mode: PlanMode.periodized,
      scheduleType: ScheduleType.weekly,
      durationWeeks: 8,
      days: [
        _Day(
          'Week 1 — Heavy',
          [
            _Block(
              [
                _Item.strength(
                  12,
                  reps: 5,
                  startWeightKg: 100,
                  weightMode: WeightMode.absolute,
                  gainPerFortnightKg: 0,
                ),
              ],
              rounds: 5,
              restAfterRoundSeconds: 210,
            ),
            _Block(
              [
                _Item.strength(
                  1,
                  reps: 5,
                  startWeightKg: 80,
                  weightMode: WeightMode.absolute,
                  gainPerFortnightKg: 0,
                ),
              ],
              rounds: 5,
              restAfterRoundSeconds: 180,
            ),
          ],
          dayOfWeek: Weekday.monday,
          weekNumber: 1,
        ),
        _Day(
          'Week 1 — Volume',
          [
            _Block(
              [
                _Item.strength(
                  15,
                  reps: 10,
                  startWeightKg: 140,
                  weightMode: WeightMode.absolute,
                  gainPerFortnightKg: 0,
                ),
              ],
              rounds: 4,
              restAfterRoundSeconds: 120,
            ),
            _Block(
              [
                _Item.strength(
                  3,
                  reps: 10,
                  startWeightKg: 30,
                  weightMode: WeightMode.absolute,
                  gainPerFortnightKg: 0,
                ),
              ],
              rounds: 4,
              restAfterRoundSeconds: 120,
            ),
          ],
          dayOfWeek: Weekday.thursday,
          weekNumber: 1,
        ),
        _Day(
          'Week 2 — Heavy',
          [
            _Block(
              [
                _Item.strength(
                  12,
                  reps: 5,
                  startWeightKg: 105,
                  weightMode: WeightMode.absolute,
                  gainPerFortnightKg: 0,
                ),
              ],
              rounds: 5,
              restAfterRoundSeconds: 210,
            ),
          ],
          dayOfWeek: Weekday.monday,
          weekNumber: 2,
        ),
        _Day(
          'Week 2 — Volume',
          [
            _Block(
              [
                _Item.strength(
                  15,
                  reps: 10,
                  startWeightKg: 145,
                  weightMode: WeightMode.absolute,
                  gainPerFortnightKg: 0,
                ),
              ],
              rounds: 4,
              restAfterRoundSeconds: 120,
            ),
          ],
          dayOfWeek: Weekday.thursday,
          weekNumber: 2,
        ),
      ],
    ),
  ];

  static RunWorkout _intervalWorkout() => const RunWorkout([
    RunSegment(
      label: 'Warm-up',
      work: RunEffort(durationSeconds: 600, paceSecPerKm: 390),
    ),
    RunSegment(
      label: '800 m repeats',
      repeat: 6,
      work: RunEffort(distanceMeters: 800, paceSecPerKm: 250),
      recovery: RunEffort(distanceMeters: 400, paceSecPerKm: 450),
    ),
    RunSegment(
      label: 'Cool-down',
      work: RunEffort(durationSeconds: 600, paceSecPerKm: 400),
    ),
  ]);

  /// Which plan day is trained on which weekday. The two strength plans never
  /// overlap: only the static one is scheduled, matching the single-active-plan
  /// invariant.
  static const _week = [
    _Scheduled(0, 0, DateTime.monday, 18),
    _Scheduled(0, 1, DateTime.tuesday, 18),
    // Wednesday alternates: an easy run one week, the machines the next.
    _Scheduled(1, 0, DateTime.wednesday, 7, parity: 0),
    _Scheduled(1, 3, DateTime.wednesday, 7, parity: 1),
    _Scheduled(0, 2, DateTime.thursday, 18),
    _Scheduled(0, 3, DateTime.friday, 17),
    _Scheduled(1, 1, DateTime.saturday, 9),
    _Scheduled(1, 2, DateTime.sunday, 9),
  ];

  // ------------------------------------------------------------------- plans

  void _writePlan(int planIndex, _Plan plan) {
    final planId = _nextPlanId++;
    _planIds[planIndex] = planId;

    // Created before the history starts, so a plan is never newer than the
    // sessions performed against it.
    final created = _date(endDate.subtract(Duration(days: weeks * 7 + 3)));

    _plans.add({
      'id': planId,
      'name': plan.name,
      'description': plan.description,
      'mode': plan.mode.wireName,
      'scheduleType': plan.scheduleType.wireName,
      'startDate': created,
      'durationWeeks': plan.durationWeeks,
      'isActive': plan.isActive,
      'source': PlanSource.ui.wireName,
      'schemaVersion': null,
      'createdAt': created,
      'updatedAt': created,
    });

    final dayIds = <List<List<int>>>[];

    for (var d = 0; d < plan.days.length; d++) {
      final day = plan.days[d];
      final dayId = _nextDayId++;

      _planDays.add({
        'id': dayId,
        'planId': planId,
        'orderIndex': d,
        'label': day.label,
        'weekNumber': day.weekNumber,
        'dayOfWeek': day.dayOfWeek?.wireName,
        'notes': null,
      });

      final blockIds = <List<int>>[];

      for (var b = 0; b < day.blocks.length; b++) {
        final block = day.blocks[b];
        final blockId = _nextBlockId++;

        _planBlocks.add({
          'id': blockId,
          'planDayId': dayId,
          'orderIndex': b,
          'kind': block.kind.wireName,
          'label': block.label,
          'rounds': block.rounds,
          'restBetweenExercisesSeconds': block.restBetweenExercisesSeconds,
          'restAfterRoundSeconds': block.restAfterRoundSeconds,
        });

        final itemIds = <int>[];

        for (var i = 0; i < block.items.length; i++) {
          final item = block.items[i];
          final itemId = _nextItemId++;
          itemIds.add(itemId);

          _planItems.add({
            'id': itemId,
            'planBlockId': blockId,
            'exerciseId': item.exerciseId,
            'orderIndex': i,
            'targetReps': item.type == ExerciseType.strength ? item.reps : null,
            'targetWeightKg': item.type == ExerciseType.strength
                ? _round(item.startWeightKg)
                : null,
            'weightMode': item.type == ExerciseType.strength
                ? item.weightMode.wireName
                : null,
            'weightOffsetKg': item.weightOffsetKg,
            'weightPercent': item.weightPercent,
            'rpe': null,
            'tempo': null,
            'toFailure': false,
            'targetDurationSeconds': item.durationSeconds,
            'targetDistanceMeters': item.distanceMeters,
            'targetPaceSecPerKm': item.paceSecPerKm,
            'targetInclinePercent': item.inclinePercent,
            'targetResistanceLevel': item.resistanceLevel,
            'intervalsJson': item.intervals?.encode(),
            'notes': null,
          });
        }
        blockIds.add(itemIds);
      }
      dayIds.add(blockIds);
    }

    _itemIds[planIndex] = dayIds;
  }

  // ----------------------------------------------------------------- history

  void _writeHistory(List<_Plan> plans) {
    // Oldest week first, so weights climb forwards through the file.
    for (var week = weeks - 1; week >= 0; week--) {
      for (final slot in _week) {
        if (!slot.runsIn(week)) continue;
        if (slot.planIndex >= plans.length) continue;

        final plan = plans[slot.planIndex];
        if (slot.dayIndex >= plan.days.length) continue;

        final start = _slotDate(week, slot);
        if (start.isAfter(endDate)) continue;

        // Roughly one session in twelve is missed, which is what a real log
        // looks like and gives the history gaps to render.
        if (_random.nextInt(12) == 0) continue;

        _writeSession(
          plan: plan,
          planIndex: slot.planIndex,
          dayIndex: slot.dayIndex,
          weeksAgo: week,
          startedAt: start,
        );
      }
    }
  }

  /// The date of one scheduled slot, [week] weeks before the anchor.
  DateTime _slotDate(int week, _Scheduled slot) {
    final anchorMonday = endDate.subtract(
      Duration(days: endDate.weekday - DateTime.monday),
    );
    final monday = anchorMonday.subtract(Duration(days: week * 7));
    final day = monday.add(Duration(days: slot.weekday - DateTime.monday));

    return DateTime(day.year, day.month, day.day, slot.hour);
  }

  void _writeSession({
    required _Plan plan,
    required int planIndex,
    required int dayIndex,
    required int weeksAgo,
    required DateTime startedAt,
  }) {
    final day = plan.days[dayIndex];
    final sessionId = _nextSessionId++;

    var groupIndex = 0;
    var cursor = startedAt;

    for (var b = 0; b < day.blocks.length; b++) {
      final block = day.blocks[b];
      final itemIds = _itemIds[planIndex]![dayIndex][b];

      for (var round = 0; round < block.rounds; round++) {
        for (var i = 0; i < block.items.length; i++) {
          final item = block.items[i];
          cursor = cursor.add(Duration(seconds: 45 + _random.nextInt(40)));

          if (item.type == ExerciseType.cardio) {
            cursor = _writeCardioEntry(
              sessionId: sessionId,
              item: item,
              planItemId: itemIds[i],
              block: block,
              groupIndex: groupIndex,
              roundIndex: round,
              itemIndex: i,
              weeksAgo: weeksAgo,
              at: cursor,
            );
          } else {
            _writeStrengthSet(
              sessionId: sessionId,
              item: item,
              planItemId: itemIds[i],
              block: block,
              groupIndex: groupIndex,
              roundIndex: round,
              itemIndex: i,
              weeksAgo: weeksAgo,
              at: cursor,
            );
          }
        }
        cursor = cursor.add(Duration(seconds: block.restAfterRoundSeconds));
      }
      groupIndex++;
    }

    final duration = cursor.difference(startedAt).inSeconds;

    _sessions.add({
      'id': sessionId,
      'planId': _planIds[planIndex],
      'planDayId': _planDays
          .where((d) => d['planId'] == _planIds[planIndex])
          .elementAt(dayIndex)['id'],
      'title': day.label,
      'startedAt': _date(startedAt),
      'endedAt': _date(cursor),
      'status': SessionStatus.completed.wireName,
      'durationSeconds': duration,
      'notes': null,
    });
  }

  /// The weight actually lifted, [weeksAgo] weeks before the anchor.
  ///
  /// Rises a step every fortnight and is rounded to the nearest 2.5 kg, so the
  /// progress chart climbs in the steps a real logbook does rather than on a
  /// smooth line.
  double _weightAt(_Item item, int weeksAgo) {
    if (item.gainPerFortnightKg == 0) return item.startWeightKg;

    final fortnights = (weeks - 1 - weeksAgo) ~/ 2;
    final raw = item.startWeightKg + fortnights * item.gainPerFortnightKg;
    return _round((raw / 2.5).round() * 2.5);
  }

  void _writeStrengthSet({
    required int sessionId,
    required _Item item,
    required int planItemId,
    required _Block block,
    required int groupIndex,
    required int roundIndex,
    required int itemIndex,
    required int weeksAgo,
    required DateTime at,
  }) {
    final planned = _weightAt(item, weeksAgo);

    // The last round of a heavy block is the one that sometimes falls short.
    final missed = roundIndex == block.rounds - 1 && _random.nextInt(5) == 0;
    final actualReps = missed
        ? max(1, item.reps - 1 - _random.nextInt(2))
        : item.reps + (_random.nextInt(6) == 0 ? 1 : 0);

    _strengthSets.add({
      'id': _nextSetId++,
      'sessionId': sessionId,
      'exerciseId': item.exerciseId,
      'planItemId': planItemId,
      'groupIndex': groupIndex,
      'groupKind': block.kind.wireName,
      'groupLabel': block.label,
      'roundIndex': roundIndex,
      'itemIndex': itemIndex,
      'plannedReps': item.reps,
      'plannedWeightKg': planned,
      'actualReps': actualReps,
      'actualWeightKg': planned,
      'rpe': null,
      // The opening round of a heavy barbell block is a warm-up.
      'isWarmup': roundIndex == 0 && block.restAfterRoundSeconds >= 180,
      'status': EntryStatus.completed.wireName,
      'restTakenSeconds': block.restAfterRoundSeconds,
      'performedAt': _date(at),
      'notes': null,
    });

    _recordAchievement(item.exerciseId, planned, actualReps, at);
  }

  DateTime _writeCardioEntry({
    required int sessionId,
    required _Item item,
    required int planItemId,
    required _Block block,
    required int groupIndex,
    required int roundIndex,
    required int itemIndex,
    required int weeksAgo,
    required DateTime at,
  }) {
    // Fitness improves, so an older session is slower. Two seconds per km per
    // week, with a little noise on top.
    final weeksTrained = weeks - 1 - weeksAgo;
    final drift = (weeks - weeksTrained) * 2.0 + _random.nextInt(9) - 4;

    final plannedDistance = item.distanceMeters ?? 5000;
    final distance = _round(
      plannedDistance * (0.95 + _random.nextDouble() * 0.12),
    );
    final pace = _round((item.paceSecPerKm ?? 330) + drift);
    final duration = (distance / 1000 * pace).round();

    final entryId = _nextCardioId++;

    _cardioEntries.add({
      'id': entryId,
      'sessionId': sessionId,
      'exerciseId': item.exerciseId,
      'planItemId': planItemId,
      'groupIndex': groupIndex,
      'groupKind': block.kind.wireName,
      'groupLabel': block.label,
      'roundIndex': roundIndex,
      'itemIndex': itemIndex,
      'plannedDurationSeconds': item.durationSeconds,
      'plannedDistanceMeters': item.distanceMeters,
      'plannedPaceSecPerKm': item.paceSecPerKm,
      'actualDurationSeconds': duration,
      'actualDistanceMeters': distance,
      'actualPaceSecPerKm': pace,
      'inclinePercent': item.inclinePercent,
      'resistanceLevel': item.resistanceLevel,
      'avgHeartRate': 138 + _random.nextInt(22),
      'maxHeartRate': 168 + _random.nextInt(18),
      'calories': (distance / 1000 * 62).round(),
      'elevationGainMeters': _round(distance / 1000 * (4 + _random.nextInt(9))),
      'status': EntryStatus.completed.wireName,
      'performedAt': _date(at),
      'notes': null,
    });

    // Kilometre splits, so the split list has something to show.
    final wholeKm = distance ~/ 1000;
    for (var k = 0; k < wholeKm; k++) {
      _cardioSplits.add({
        'id': _nextSplitId++,
        'cardioEntryId': entryId,
        'splitIndex': k,
        'durationSeconds': (pace + _random.nextInt(21) - 10).round(),
        'distanceMeters': 1000,
      });
    }

    _recordCardio(item.exerciseId, duration, distance, pace, at);

    return at.add(Duration(seconds: duration));
  }

  // ------------------------------------------------------- derived summaries

  void _recordAchievement(
    int exerciseId,
    double weight,
    int reps,
    DateTime at,
  ) {
    if (weight <= 0) return;

    final byReps = _bestByReps[(exerciseId, reps)];
    if (byReps == null || weight > byReps.weightKg) {
      _bestByReps[(exerciseId, reps)] = _Achievement(weight, reps, at);
    }

    final overall = _bestOverall[exerciseId];
    // Epley, matching the app's own estimate.
    final estimate = weight * (1 + reps / 30);
    if (overall == null || estimate > overall.estimatedOneRepMax) {
      _bestOverall[exerciseId] = _Achievement(weight, reps, at);
    }
  }

  void _recordCardio(
    int exerciseId,
    int duration,
    double distance,
    double pace,
    DateTime at,
  ) {
    final best = _bestCardio[exerciseId];
    _bestCardio[exerciseId] = _CardioBest(
      bestPace: best == null ? pace : min(best.bestPace, pace),
      longestDistance: best == null
          ? distance
          : max(best.longestDistance, distance),
      longestDuration: best == null
          ? duration
          : max(best.longestDuration, duration),
      at: at,
    );
  }

  /// Working weights, taken from what was actually lifted rather than invented,
  /// so day one of the restored plan prescribes something the history supports.
  void _writeBaselines(List<_Plan> plans) {
    for (var p = 0; p < plans.length; p++) {
      final plan = plans[p];
      if (plan.mode != PlanMode.staticPlan) continue;

      for (final day in plan.days) {
        for (final block in day.blocks) {
          for (final item in block.items) {
            if (item.type != ExerciseType.strength) continue;
            if (!item.weightMode.usesBaseline) continue;

            final best = _bestByReps[(item.exerciseId, item.reps)];
            if (best == null) continue;

            _baselines.add({
              'id': _nextBaselineId++,
              'planId': _planIds[p],
              'exerciseId': item.exerciseId,
              'reps': item.reps,
              'weightKg': best.weightKg,
              'achievedAt': _date(best.at),
              'sourceSetId': null,
            });
          }
        }
      }
    }
  }

  void _writeRecords() {
    for (final entry in _bestByReps.entries) {
      final (exerciseId, reps) = entry.key;
      _addRecord(
        exerciseId,
        RecordType.maxWeightAtReps,
        entry.value.weightKg,
        entry.value.at,
        reps: reps,
      );
    }

    for (final entry in _bestOverall.entries) {
      _addRecord(
        entry.key,
        RecordType.maxWeight,
        entry.value.weightKg,
        entry.value.at,
      );
      _addRecord(
        entry.key,
        RecordType.estimatedOneRepMax,
        _round(entry.value.estimatedOneRepMax),
        entry.value.at,
      );
    }

    for (final entry in _bestCardio.entries) {
      _addRecord(
        entry.key,
        RecordType.bestPace,
        entry.value.bestPace,
        entry.value.at,
      );
      _addRecord(
        entry.key,
        RecordType.longestDistance,
        entry.value.longestDistance,
        entry.value.at,
      );
      _addRecord(
        entry.key,
        RecordType.longestDuration,
        entry.value.longestDuration.toDouble(),
        entry.value.at,
      );
    }
  }

  void _addRecord(
    int exerciseId,
    RecordType type,
    double value,
    DateTime at, {
    int reps = 0,
  }) {
    _records.add({
      'id': _nextRecordId++,
      'exerciseId': exerciseId,
      'recordType': type.wireName,
      // Zero rather than null means "not applicable", matching the table's
      // unique key on {exerciseId, recordType, reps}.
      'reps': reps,
      'value': value,
      'achievedAt': _date(at),
      'sessionId': null,
    });
  }

  // ------------------------------------------------------------------ helpers

  Map<String, Object?> _exercise(_Ex e) {
    final created = _date(endDate.subtract(Duration(days: weeks * 7 + 30)));
    return {
      'id': e.id,
      'name': e.name,
      // Same rule as normalizeExerciseName in exercise_repository.dart. The
      // catalog's unique key is built on it, so a mismatch fails the restore.
      'nameKey': e.name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
      'type': e.type.wireName,
      'cardioActivity': e.activity?.wireName,
      'muscleGroup': e.muscleGroup,
      'equipment': e.equipment,
      'notes': null,
      'isCustom': e.isCustom,
      'isArchived': e.isArchived,
      'createdAt': created,
      'updatedAt': created,
    };
  }

  static String _date(DateTime value) => value.toUtc().toIso8601String();

  static double _round(double value) => (value * 100).round() / 100;
}

class _Achievement {
  const _Achievement(this.weightKg, this.reps, this.at);

  final double weightKg;
  final int reps;
  final DateTime at;

  double get estimatedOneRepMax => weightKg * (1 + reps / 30);
}

class _CardioBest {
  const _CardioBest({
    required this.bestPace,
    required this.longestDistance,
    required this.longestDuration,
    required this.at,
  });

  final double bestPace;
  final double longestDistance;
  final int longestDuration;
  final DateTime at;
}
