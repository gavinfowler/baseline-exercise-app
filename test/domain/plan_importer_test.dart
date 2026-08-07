import 'dart:io';

import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/baseline_repository.dart';
import 'package:exercise_app/data/repositories/exercise_repository.dart';
import 'package:exercise_app/data/repositories/personal_record_repository.dart';
import 'package:exercise_app/data/repositories/plan_repository.dart';
import 'package:exercise_app/data/repositories/session_repository.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/models/run_segment.dart';
import 'package:exercise_app/domain/plan_import/plan_importer.dart';
import 'package:exercise_app/domain/progression/progression_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/test_database.dart';
import 'plan_parser_test.dart' show planJson;

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late PlanRepository plans;
  late ExerciseRepository exercises;
  late BaselineRepository baselines;
  late PlanImporter importer;

  setUp(() {
    db = createTestDatabase();
    clock = FakeClock();
    plans = PlanRepository(db, clock: clock);
    exercises = ExerciseRepository(db, clock: clock);
    baselines = BaselineRepository(db);

    importer = PlanImporter(
      db: db,
      plans: plans,
      exercises: exercises,
      progression: ProgressionService(
        sessions: SessionRepository(db, clock: clock),
        plans: plans,
        baselines: baselines,
        records: PersonalRecordRepository(db),
        clock: clock,
      ),
    );
  });

  group('importing a plan', () {
    test('creates the plan, its days, blocks and items', () async {
      final outcome = await importer.importSource(planJson());
      expect(outcome.isSuccess, isTrue);

      final summary = outcome.summary!;
      expect(summary.planName, 'Test Plan');
      expect(summary.mode, PlanMode.staticPlan);
      expect(summary.dayCount, 1);
      expect(summary.blockCount, 1);
      expect(summary.exerciseCount, 1);

      final detail = await plans.loadPlanDays(summary.planId);
      expect(detail, hasLength(1));
      expect(detail.single.blocks.single.items, hasLength(1));
      expect(detail.single.blocks.single.block.rounds, 3);
    });

    test('marks the plan as imported and records the schema version', () async {
      final outcome = await importer.importSource(planJson());
      final plan = await plans.findById(outcome.summary!.planId);

      expect(plan!.source, PlanSource.imported);
      expect(plan.schemaVersion, '1.0');
    });

    test('creates exercises the catalog does not have', () async {
      final outcome = await importer.importSource(planJson());

      expect(outcome.summary!.createdExerciseNames, ['Barbell Bench Press']);
      expect(await exercises.findByName('Barbell Bench Press'), isNotNull);
    });

    test('reuses an existing exercise instead of duplicating it', () async {
      // A generated plan names movements without knowing the user's catalog.
      final existing = await exercises.create(
        name: 'Barbell Bench Press',
        type: ExerciseType.strength,
      );

      final outcome = await importer.importSource(planJson());

      expect(outcome.summary!.createdExerciseNames, isEmpty);
      expect(await exercises.getAll(), hasLength(1));

      final items = (await plans.loadPlanDays(
        outcome.summary!.planId,
      )).single.blocks.single.items;
      expect(items.single.exerciseId, existing.id);
    });

    test('matches an existing exercise despite different casing', () async {
      await exercises.create(
        name: 'barbell bench press',
        type: ExerciseType.strength,
      );

      final outcome = await importer.importSource(planJson());
      expect(outcome.summary!.createdExerciseNames, isEmpty);
    });

    test('preserves block order and superset grouping', () async {
      final outcome = await importer.importSource(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'kind': 'superset',
                    'label': 'A',
                    'rounds': 3,
                    'restAfterRoundSeconds': 120,
                    'exercises': [
                      {
                        'name': 'Bench',
                        'type': 'strength',
                        'reps': 8,
                        'weight': 60,
                      },
                      {
                        'name': 'Row',
                        'type': 'strength',
                        'reps': 8,
                        'weight': 50,
                      },
                    ],
                  },
                  {
                    'rounds': 1,
                    'exercises': [
                      {
                        'name': 'Treadmill Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 600,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      final day = (await plans.loadPlanDays(outcome.summary!.planId)).single;
      expect(day.blocks, hasLength(2));

      final superset = day.blocks.first;
      expect(superset.block.kind, BlockKind.superset);
      expect(superset.block.label, 'A');
      expect(superset.block.restAfterRoundSeconds, 120);
      expect(superset.items, hasLength(2));
      expect(superset.items.map((i) => i.orderIndex), [0, 1]);

      final cardio = day.blocks.last;
      expect(cardio.items.single.targetDurationSeconds, 600);
    });

    test('stores imperial input as canonical kilograms', () async {
      final outcome = await importer.importSource(
        planJson(
          overrides: {
            'units': 'imperial',
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Bench',
                        'type': 'strength',
                        'reps': 5,
                        'weight': 135,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      final item = (await plans.loadPlanDays(
        outcome.summary!.planId,
      )).single.blocks.single.items.single;
      expect(item.targetWeightKg, closeTo(61.2349, 0.001));
    });
  });

  group('baseline seeding', () {
    test('a static plan starts from the weights in the file', () async {
      final outcome = await importer.importSource(planJson());

      final baseline = await baselines.find(
        planId: outcome.summary!.planId,
        exerciseId: (await exercises.findByName('Barbell Bench Press'))!.id,
        reps: 8,
      );
      // Otherwise day one of an imported plan would prescribe nothing.
      expect(baseline!.weightKg, 60);
    });

    test('a periodized plan gets no baselines at all', () async {
      final outcome = await importer.importSource(
        planJson(overrides: {'mode': 'periodized', 'durationWeeks': 8}),
      );

      expect(await baselines.forPlan(outcome.summary!.planId), isEmpty);
    });
  });

  group('invalid files', () {
    test('are reported and write nothing', () async {
      final outcome = await importer.importSource('{"nope": true}');

      expect(outcome.isSuccess, isFalse);
      expect(outcome.issues, isNotEmpty);
      expect(await plans.getAll(), isEmpty);
      expect(await exercises.getAll(), isEmpty);
    });

    test('a bad exercise aborts the whole import', () async {
      // Partial imports would leave the user to clean up by hand.
      final outcome = await importer.importSource(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Good',
                        'type': 'strength',
                        'reps': 8,
                        'weight': 60,
                      },
                      {'name': 'Bad', 'type': 'not-a-type'},
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(outcome.isSuccess, isFalse);
      expect(await plans.getAll(), isEmpty);
      expect(await exercises.getAll(), isEmpty);
    });
  });

  group('shipped examples import end to end', () {
    for (final name in const [
      'static-upper-lower.json',
      'periodized-8-week.json',
      'speed-work-running.json',
    ]) {
      test(name, () async {
        final source = File('assets/schema/examples/$name').readAsStringSync();

        final outcome = await importer.importSource(source);
        expect(outcome.isSuccess, isTrue, reason: outcome.issues.join('; '));

        final summary = outcome.summary!;
        expect(summary.dayCount, greaterThan(0));
        expect(summary.exerciseCount, greaterThan(0));

        final days = await plans.loadPlanDays(summary.planId);
        expect(days, hasLength(summary.dayCount));
        for (final day in days) {
          expect(day.blocks, isNotEmpty);
          for (final block in day.blocks) {
            expect(block.items, isNotEmpty);
          }
        }
      });
    }
  });

  group('import samples import end to end', () {
    // The developer fixtures reach further than the shipped examples do —
    // cardio circuits, resistance levels, inclines — so parsing cleanly is not
    // on its own proof that they land in the database.
    for (final name in const [
      'strength-static-metric.json',
      'strength-periodized-imperial.json',
      'cardio-running-intervals.json',
      'cardio-machines.json',
      'hybrid-week.json',
    ]) {
      test(name, () async {
        final source = File('tool/import-samples/$name').readAsStringSync();

        final outcome = await importer.importSource(source);
        expect(outcome.isSuccess, isTrue, reason: outcome.issues.join('; '));

        final days = await plans.loadPlanDays(outcome.summary!.planId);
        expect(days, hasLength(outcome.summary!.dayCount));
        for (final day in days) {
          expect(
            day.blocks,
            isNotEmpty,
            reason: '${day.day.label} has no work',
          );
          for (final block in day.blocks) {
            expect(block.items, isNotEmpty);
            // A superset or circuit that arrived with one exercise would be a
            // parser bug the day editor then renders as an error.
            if (block.block.kind.isGrouped) {
              expect(block.items.length, greaterThanOrEqualTo(2));
            }
          }
        }
      });
    }

    test('machine cardio keeps its incline and resistance', () async {
      // No UI wrote these columns before the cardio screen existed, so this is
      // the only end-to-end coverage they have.
      final source = File(
        'tool/import-samples/cardio-machines.json',
      ).readAsStringSync();

      final outcome = await importer.importSource(source);
      expect(outcome.isSuccess, isTrue, reason: outcome.issues.join('; '));

      final days = await plans.loadPlanDays(outcome.summary!.planId);
      final items = [
        for (final day in days)
          for (final block in day.blocks) ...block.items,
      ];

      expect(
        items.where((i) => i.targetResistanceLevel != null),
        isNotEmpty,
        reason: 'no resistance level survived the import',
      );
      expect(
        items.where((i) => i.targetInclinePercent != null),
        isNotEmpty,
        reason: 'no incline survived the import',
      );

      final inclineWalk = days
          .firstWhere((d) => d.day.label == 'Incline Walk')
          .blocks
          .single
          .items
          .single;
      expect(inclineWalk.targetInclinePercent, 12);
    });
  });

  group('structured cardio', () {
    test('survives the round trip into the database', () async {
      // The imperial example is the interesting one: its quarter-mile reps and
      // per-mile paces have to come back out in meters and seconds per km.
      final source = File(
        'assets/schema/examples/speed-work-running.json',
      ).readAsStringSync();

      final outcome = await importer.importSource(source);
      expect(outcome.isSuccess, isTrue, reason: outcome.issues.join('; '));

      final days = await plans.loadPlanDays(outcome.summary!.planId);
      final intervalDay = days.firstWhere(
        (d) => d.day.label.contains('Repeat'),
      );
      final item = intervalDay.blocks.single.items.single;

      final workout = RunWorkout.decode(item.intervalsJson);
      expect(workout.segments, hasLength(3));

      final repeats = workout.segments[1];
      expect(repeats.label, '400 m repeats');
      expect(repeats.repeat, 6);
      // A quarter of a mile, stored in meters.
      expect(repeats.work.distanceMeters, closeTo(402.336, 0.001));
      // A 7:00 mile, stored as seconds per kilometre.
      expect(
        repeats.work.paceSecPerKm,
        closeTo(Units.secPerMileToSecPerKm(420), 0.001),
      );
      expect(repeats.recovery, isNotNull);

      // The totals are derivable, which is what lets the editor summarise it.
      expect(workout.totalDurationSeconds, isNotNull);
    });

    test('a plain cardio item stores no intervals', () async {
      final outcome = await importer.importSource(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Easy',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Outdoor Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 1800,
                        'targetPace': '6:00',
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      final days = await plans.loadPlanDays(outcome.summary!.planId);
      final item = days.single.blocks.single.items.single;

      expect(item.intervalsJson, isNull);
      expect(item.targetPaceSecPerKm, 360);
    });
  });

  group('re-importing', () {
    test('creates a separate plan rather than merging', () async {
      await importer.importSource(planJson());
      await importer.importSource(planJson());

      // Two imports of the same file are two plans; the user chooses which is
      // active.
      expect(await plans.getAll(), hasLength(2));
      // The exercise catalog is still deduplicated by name.
      expect(await exercises.getAll(), hasLength(1));
    });
  });
}
