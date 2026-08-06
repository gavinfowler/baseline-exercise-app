import 'dart:convert';

import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/domain/models/run_segment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const metric = UnitFormatter(UnitSystem.metric);

  group('RunEffort', () {
    test('derives its duration from distance and pace', () {
      const effort = RunEffort(distanceMeters: 400, paceSecPerKm: 300);
      expect(effort.effectiveDurationSeconds, 120);
    });

    test('derives its distance from duration and pace', () {
      const effort = RunEffort(durationSeconds: 300, paceSecPerKm: 300);
      expect(effort.effectiveDistanceMeters, closeTo(1000, 0.0001));
    });

    test('prefers what was actually prescribed over what it could derive', () {
      // The user asked for 400 m in 120 s, which is a 5:00 km. Even if the
      // stated pace disagrees, the stated numbers win.
      const effort = RunEffort(
        durationSeconds: 120,
        distanceMeters: 400,
        paceSecPerKm: 999,
      );
      expect(effort.effectiveDurationSeconds, 120);
      expect(effort.effectiveDistanceMeters, 400);
    });

    test('knows when it cannot say', () {
      const effort = RunEffort(distanceMeters: 400);
      expect(effort.effectiveDurationSeconds, isNull);
    });
  });

  group('RunSegment totals', () {
    test('multiply work and recovery by the repeat count', () {
      const segment = RunSegment(
        repeat: 6,
        work: RunEffort(durationSeconds: 90),
        recovery: RunEffort(durationSeconds: 120),
      );
      expect(segment.totalDurationSeconds, 6 * 210);
    });

    test('a segment with no recovery counts only its work', () {
      const segment = RunSegment(
        repeat: 1,
        work: RunEffort(durationSeconds: 1200),
      );
      expect(segment.totalDurationSeconds, 1200);
    });

    test('an indeterminate recovery makes the whole segment indeterminate', () {
      // A partial total would read as fact, so it is withheld instead.
      const segment = RunSegment(
        repeat: 6,
        work: RunEffort(durationSeconds: 90),
        recovery: RunEffort(distanceMeters: 200),
      );
      expect(segment.totalDurationSeconds, isNull);
      expect(segment.totalDistanceMeters, isNull);
    });

    test('distance comes through pace when only duration was prescribed', () {
      const segment = RunSegment(
        repeat: 4,
        work: RunEffort(durationSeconds: 60, paceSecPerKm: 240),
      );
      expect(segment.totalDistanceMeters, closeTo(1000, 0.0001));
    });
  });

  group('RunWorkout totals', () {
    RunWorkout fartlek() => const RunWorkout([
      RunSegment(label: 'Warm-up', work: RunEffort(durationSeconds: 600)),
      RunSegment(
        label: 'Surges',
        repeat: 8,
        work: RunEffort(durationSeconds: 60),
        recovery: RunEffort(durationSeconds: 120),
      ),
      RunSegment(label: 'Cool-down', work: RunEffort(durationSeconds: 600)),
    ]);

    test('sum across every segment', () {
      expect(fartlek().totalDurationSeconds, 600 + 8 * 180 + 600);
    });

    test('one indeterminate segment withholds the total', () {
      const workout = RunWorkout([
        RunSegment(work: RunEffort(durationSeconds: 600)),
        RunSegment(work: RunEffort(distanceMeters: 400)),
      ]);
      expect(workout.totalDurationSeconds, isNull);
      // Distance is still knowable for neither, since the first has no pace.
      expect(workout.totalDistanceMeters, isNull);
    });

    test('an empty workout has no totals to report', () {
      expect(RunWorkout.empty.totalDurationSeconds, isNull);
      expect(RunWorkout.empty.totalDistanceMeters, isNull);
      expect(RunWorkout.empty.averagePaceSecPerKm, isNull);
    });

    test('average pace follows from the totals', () {
      const workout = RunWorkout([
        RunSegment(
          repeat: 2,
          work: RunEffort(durationSeconds: 600, distanceMeters: 2000),
        ),
      ]);
      expect(workout.averagePaceSecPerKm, closeTo(300, 0.0001));
    });
  });

  group('encoding', () {
    test('round-trips through JSON', () {
      const original = RunWorkout([
        RunSegment(
          label: '400 m repeats',
          repeat: 6,
          work: RunEffort(distanceMeters: 400, paceSecPerKm: 270),
          recovery: RunEffort(distanceMeters: 200, durationSeconds: 90),
        ),
      ]);

      final decoded = RunWorkout.decode(original.encode());
      final segment = decoded.segments.single;

      expect(segment.label, '400 m repeats');
      expect(segment.repeat, 6);
      expect(segment.work.distanceMeters, 400);
      expect(segment.work.paceSecPerKm, 270);
      expect(segment.recovery!.durationSeconds, 90);
    });

    test('an empty workout encodes as null, not as an empty array', () {
      // So an emptied builder clears the column instead of storing "[]".
      expect(RunWorkout.empty.encode(), isNull);
    });

    test('reads the original flat interval shape', () {
      // Plans written against the first version of the file format must still
      // open, so the decoder accepts {repeat, workSeconds, restSeconds}.
      const legacy = '[{"repeat":6,"workSeconds":60,"restSeconds":90}]';
      final segment = RunWorkout.decode(legacy).segments.single;

      expect(segment.repeat, 6);
      expect(segment.work.durationSeconds, 60);
      expect(segment.recovery!.durationSeconds, 90);
    });

    test(
      'a legacy interval with no rest becomes a segment without recovery',
      () {
        const legacy = '[{"repeat":3,"workSeconds":60}]';
        expect(RunWorkout.decode(legacy).segments.single.recovery, isNull);
      },
    );

    test('malformed JSON decodes to empty rather than throwing', () {
      // A plan that will not open is worse than one missing its interval detail.
      expect(RunWorkout.decode('not json').isEmpty, isTrue);
      expect(RunWorkout.decode('{"not":"a list"}').isEmpty, isTrue);
      expect(RunWorkout.decode(null).isEmpty, isTrue);
      expect(RunWorkout.decode('').isEmpty, isTrue);
    });

    test('skips segments that prescribe nothing', () {
      const partial = '[{"repeat":2},{"repeat":2,"work":{"seconds":60}}]';
      expect(RunWorkout.decode(partial).segments, hasLength(1));
    });

    test('omits absent fields rather than writing nulls', () {
      const workout = RunWorkout([
        RunSegment(work: RunEffort(durationSeconds: 60)),
      ]);

      final json = jsonDecode(workout.encode()!)! as List<Object?>;
      final segment = json.single! as Map<String, Object?>;
      final work = segment['work']! as Map<String, Object?>;

      expect(work.containsKey('meters'), isFalse);
      expect(segment.containsKey('recovery'), isFalse);
      expect(segment.containsKey('label'), isFalse);
    });
  });

  group('describing', () {
    test('a repeated distance segment reads as its prescription', () {
      const segment = RunSegment(
        repeat: 6,
        work: RunEffort(distanceMeters: 400, paceSecPerKm: 270),
        recovery: RunEffort(durationSeconds: 120),
      );

      final text = segment.describe(metric);
      expect(text, contains('6 ×'));
      expect(text, contains('4:30'));
      expect(text, contains('recovery'));
    });

    test('a single-rep segment omits the multiplier', () {
      const segment = RunSegment(work: RunEffort(durationSeconds: 600));
      expect(segment.describe(metric), isNot(contains('×')));
    });

    test('a workout summarises its size and totals', () {
      const workout = RunWorkout([
        RunSegment(work: RunEffort(durationSeconds: 600)),
        RunSegment(work: RunEffort(durationSeconds: 600)),
      ]);
      expect(workout.describe(metric), contains('2 segments'));
      expect(workout.describe(metric), contains('20:00'));
    });
  });
}
