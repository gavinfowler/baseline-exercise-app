import 'dart:convert';
import 'dart:io';

import 'package:exercise_app/core/result.dart';
import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/models/run_segment.dart';
import 'package:exercise_app/domain/plan_import/plan_dto.dart';
import 'package:exercise_app/domain/plan_import/plan_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal valid file, with [overrides] merged into the plan object.
String planJson({Map<String, Object?> overrides = const {}}) {
  return jsonEncode({
    'schemaVersion': '1.0',
    'plan': {
      'name': 'Test Plan',
      'mode': 'static',
      'days': [
        {
          'label': 'Day 1',
          'blocks': [
            {
              'rounds': 3,
              'exercises': [
                {
                  'name': 'Barbell Bench Press',
                  'type': 'strength',
                  'reps': 8,
                  'weight': 60,
                },
              ],
            },
          ],
        },
      ],
      ...overrides,
    },
  });
}

List<String> pointersOf(Result<PlanFileDto> result) =>
    result.issues.map((i) => i.pointer).toList();

void main() {
  const parser = PlanParser();

  group('a valid file', () {
    test('parses', () {
      final result = parser.parse(planJson());
      expect(result.isOk, isTrue, reason: result.issues.join('; '));

      final plan = result.valueOrNull!.plan;
      expect(plan.name, 'Test Plan');
      expect(plan.mode, PlanMode.staticPlan);
      expect(plan.days, hasLength(1));
      expect(plan.days.single.blocks.single.rounds, 3);
      expect(plan.exerciseCount, 1);
    });

    test('defaults block kind to single and rest to 90 seconds', () {
      final plan = parser.parse(planJson()).valueOrNull!.plan;
      final block = plan.days.single.blocks.single;

      expect(block.kind, BlockKind.single);
      expect(block.restAfterRoundSeconds, 90);
      expect(block.restBetweenExercisesSeconds, 0);
    });
  });

  group('malformed input', () {
    test('reports invalid JSON without throwing', () {
      final result = parser.parse('{not json');
      expect(result.isErr, isTrue);
      expect(result.issues.single.message, contains('not valid JSON'));
    });

    test('rejects a non-object top level', () {
      expect(parser.parse('[]').isErr, isTrue);
    });

    test('reports a missing plan object', () {
      final result = parser.parse('{"schemaVersion":"1.0"}');
      expect(pointersOf(result), contains('/plan'));
    });
  });

  group('schemaVersion', () {
    test('is required', () {
      final result = parser.parse(
        jsonEncode({
          'plan': {'name': 'x', 'mode': 'static', 'days': <Object>[]},
        }),
      );
      expect(pointersOf(result), contains('/schemaVersion'));
    });

    test('rejects a version this build does not understand', () {
      final source = planJson().replaceFirst('"1.0"', '"9.9"');
      final result = parser.parse(source);

      expect(result.isErr, isTrue);
      expect(
        result.issues.first.message,
        contains('Unsupported schemaVersion'),
      );
    });
  });

  group('mode', () {
    test('rejects an unknown mode', () {
      final result = parser.parse(planJson(overrides: {'mode': 'dynamic'}));
      expect(pointersOf(result), contains('/plan/mode'));
    });

    test('a periodized plan must declare durationWeeks', () {
      // Without it the program has no end, which is the whole distinction.
      final result = parser.parse(planJson(overrides: {'mode': 'periodized'}));
      expect(pointersOf(result), contains('/plan/durationWeeks'));
    });

    test('a periodized plan with durationWeeks parses', () {
      final result = parser.parse(
        planJson(overrides: {'mode': 'periodized', 'durationWeeks': 8}),
      );
      expect(result.isOk, isTrue, reason: result.issues.join('; '));
      expect(result.valueOrNull!.plan.durationWeeks, 8);
    });

    test('a static plan does not need durationWeeks', () {
      expect(parser.parse(planJson()).isOk, isTrue);
    });
  });

  group('unit conversion', () {
    test('imperial weights are converted to kilograms', () {
      // The importer must never see pounds.
      final result = parser.parse(
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

      final exercise =
          result.valueOrNull!.plan.days.single.blocks.single.exercises.single;
      expect(exercise.weightKg, closeTo(61.2349, 0.001));
    });

    test('metric weights pass through unchanged', () {
      final plan = parser.parse(planJson()).valueOrNull!.plan;
      expect(plan.days.single.blocks.single.exercises.single.weightKg, 60);
    });

    test('imperial distances are converted to metres', () {
      final result = parser.parse(
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
                        'name': 'Outdoor Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'distance': 3.1,
                        'durationSeconds': 1500,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      final exercise =
          result.valueOrNull!.plan.days.single.blocks.single.exercises.single;
      expect(exercise.distanceMeters, closeTo(4988.97, 0.01));
    });

    test('pace is converted from per-mile to per-kilometre', () {
      final result = parser.parse(
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
                        'name': 'Outdoor Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 1800,
                        'targetPace': '8:00',
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      final exercise =
          result.valueOrNull!.plan.days.single.blocks.single.exercises.single;
      // 8:00/mile is about 4:58/km.
      expect(exercise.paceSecPerKm, closeTo(298.26, 0.1));
    });
  });

  group('supersets', () {
    test('a superset of two exercises parses', () {
      final result = parser.parse(
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
                ],
              },
            ],
          },
        ),
      );

      expect(result.isOk, isTrue, reason: result.issues.join('; '));
      final block = result.valueOrNull!.plan.days.single.blocks.single;
      expect(block.kind, BlockKind.superset);
      expect(block.exercises, hasLength(2));
      expect(block.label, 'A');
    });

    test('a superset of one exercise is rejected', () {
      // Almost always means the generator emitted the wrong kind.
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'kind': 'superset',
                    'exercises': [
                      {
                        'name': 'Bench',
                        'type': 'strength',
                        'reps': 8,
                        'weight': 60,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.issues.first.message, contains('at least two exercises'));
    });
  });

  group('field mixing', () {
    test('cardio fields on a strength exercise are rejected', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Bench',
                        'type': 'strength',
                        'reps': 8,
                        'weight': 60,
                        'distance': 5.0,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(
        pointersOf(result),
        contains('/plan/days/0/blocks/0/exercises/0/distance'),
      );
    });

    test('strength fields on a cardio exercise are rejected', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 600,
                        'reps': 8,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(
        pointersOf(result),
        contains('/plan/days/0/blocks/0/exercises/0/reps'),
      );
    });

    test('a cardio exercise needs a duration or a distance', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {'name': 'Run', 'type': 'cardio', 'activity': 'run'},
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(result.isErr, isTrue);
    });
  });

  group('error reporting', () {
    test('points at the exact offending node', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {'name': 'Bench', 'type': 'strength', 'reps': -5},
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(
        pointersOf(result),
        contains('/plan/days/0/blocks/0/exercises/0/reps'),
      );
    });

    test('collects every problem rather than stopping at the first', () {
      // A person fixing a generated file should not have to re-upload once
      // per mistake.
      final result = parser.parse(
        jsonEncode({
          'schemaVersion': '1.0',
          'plan': {
            'name': 'Broken',
            'mode': 'nonsense',
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {'name': 'A', 'type': 'strength', 'reps': 0},
                      {'name': 'B', 'type': 'unknown'},
                    ],
                  },
                ],
              },
            ],
          },
        }),
      );

      expect(result.issues.length, greaterThanOrEqualTo(3));
      expect(pointersOf(result), contains('/plan/mode'));
    });

    test('an unknown cardio activity lists the valid options', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Run',
                        'type': 'cardio',
                        'activity': 'teleport',
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

      expect(result.issues.first.message, contains('elliptical'));
    });
  });

  group('intervals', () {
    /// Parses one cardio exercise carrying [intervals] and returns its
    /// decoded, canonical structured workout.
    RunWorkout parseIntervals(
      List<Object?> intervals, {
      String units = 'metric',
    }) {
      final result = parser.parse(
        planJson(
          overrides: {
            'units': units,
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 1800,
                        'intervals': intervals,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      final exercise =
          result.valueOrNull!.plan.days.single.blocks.single.exercises.single;
      return RunWorkout.decode(exercise.intervalsJson);
    }

    test('the original flat shape still imports', () {
      final workout = parseIntervals([
        {'repeat': 6, 'workSeconds': 60, 'restSeconds': 90},
      ]);

      final segment = workout.segments.single;
      expect(segment.repeat, 6);
      expect(segment.work.durationSeconds, 60);
      expect(segment.recovery!.durationSeconds, 90);
    });

    test('distances and paces convert to canonical units', () {
      // A quarter mile at a 7:00 mile, written in an imperial plan.
      final workout = parseIntervals(units: 'imperial', [
        {
          'label': '400 m repeats',
          'repeat': 6,
          'workDistance': 0.25,
          'workPace': '7:00',
          'recoveryDistance': 0.25,
          'recoveryPace': '11:00',
        },
      ]);

      final segment = workout.segments.single;
      expect(segment.label, '400 m repeats');
      expect(segment.work.distanceMeters, closeTo(402.336, 0.001));
      expect(
        segment.work.paceSecPerKm,
        closeTo(Units.secPerMileToSecPerKm(420), 0.001),
      );
      expect(segment.recovery!.paceSecPerKm, greaterThan(0));
    });

    test('a segment with no recovery keys has no recovery', () {
      final workout = parseIntervals([
        {'repeat': 1, 'workSeconds': 1200, 'workPace': '5:00'},
      ]);
      expect(workout.segments.single.recovery, isNull);
    });

    test('a segment prescribing nothing is reported and dropped', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 1800,
                        'intervals': [
                          {'repeat': 4, 'restSeconds': 60},
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(
        pointersOf(result),
        contains('/plan/days/0/blocks/0/exercises/0/intervals/0'),
      );
    });

    test('a malformed pace is reported at its own pointer', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 1800,
                        'intervals': [
                          {'repeat': 4, 'workSeconds': 60, 'workPace': '7.30'},
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(
        pointersOf(result),
        contains('/plan/days/0/blocks/0/exercises/0/intervals/0/workPace'),
      );
    });

    test('a malformed interval is reported with its index', () {
      final result = parser.parse(
        planJson(
          overrides: {
            'days': [
              {
                'label': 'Day 1',
                'blocks': [
                  {
                    'exercises': [
                      {
                        'name': 'Run',
                        'type': 'cardio',
                        'activity': 'run',
                        'durationSeconds': 1800,
                        'intervals': [
                          {'repeat': 6, 'workSeconds': 60},
                          {'workSeconds': 60},
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ),
      );

      expect(
        pointersOf(result),
        contains('/plan/days/0/blocks/0/exercises/0/intervals/1/repeat'),
      );
    });
  });

  group('shipped examples', () {
    // These are what a user copies as a starting point, and what the schema
    // documents. If they stop parsing, the documentation is wrong.
    for (final name in const [
      'static-upper-lower.json',
      'periodized-8-week.json',
      'speed-work-running.json',
    ]) {
      test('$name parses cleanly', () {
        final file = File('assets/schema/examples/$name');
        expect(file.existsSync(), isTrue, reason: 'missing example $name');

        final result = parser.parse(file.readAsStringSync());
        expect(
          result.isOk,
          isTrue,
          reason: 'Example $name failed: ${result.issues.join('; ')}',
        );
      });
    }
  });

  group('import samples', () {
    // Developer fixtures for manually exercising the import screen. They are
    // not bundled into the app, so nothing else would notice them rotting.
    for (final name in const [
      'strength-static-metric.json',
      'strength-periodized-imperial.json',
      'cardio-running-intervals.json',
      'cardio-machines.json',
      'hybrid-week.json',
    ]) {
      test('$name parses without errors or warnings', () {
        final file = File('tool/import-samples/$name');
        expect(file.existsSync(), isTrue, reason: 'missing sample $name');

        final result = parser.parse(file.readAsStringSync());

        // Warnings count here too. These files exist to be loaded by hand while
        // checking the UI, and a warning banner would muddy what is being read.
        expect(
          result.issues,
          isEmpty,
          reason: 'Sample $name reported: ${result.issues.join('; ')}',
        );
      });
    }
  });

  group('shipped JSON Schema', () {
    test('is valid JSON and describes version 1.0', () {
      // The schema is what AI tools generate against, so a broken one is worse
      // than no schema at all.
      final file = File('assets/schema/exercise-plan.schema.json');
      expect(file.existsSync(), isTrue);

      final schema =
          jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final properties = schema['properties']! as Map<String, Object?>;
      final version = properties['schemaVersion']! as Map<String, Object?>;

      expect(version['const'], kSupportedPlanSchemaVersion);
    });
  });
}
