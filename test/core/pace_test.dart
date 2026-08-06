import 'package:exercise_app/core/units/pace.dart';
import 'package:exercise_app/core/units/unit_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsing', () {
    test('reads m:ss', () {
      expect(Pace.parse('5:30'), 330);
      expect(Pace.parse('10:00'), 600);
      expect(Pace.parse(' 4:05 '), 245);
    });

    test('allows three digits of minutes for a slow effort', () {
      expect(Pace.parse('100:00'), 6000);
    });

    test('rejects anything that is not m:ss', () {
      // Sixty seconds is a minute; accepting it would silently mean 5:00.
      expect(Pace.parse('5:60'), isNull);
      expect(Pace.parse('530'), isNull);
      expect(Pace.parse('5.30'), isNull);
      expect(Pace.parse(''), isNull);
      expect(Pace.parse('abc'), isNull);
    });

    test('round-trips through format', () {
      for (final seconds in const [60, 245, 330, 600, 3599]) {
        expect(Pace.parse(Pace.format(seconds.toDouble())), seconds);
      }
    });

    test('rounds rather than truncates when formatting', () {
      expect(Pace.format(599.6), '10:00');
      expect(Pace.format(0), '0:00');
    });
  });

  group('the duration/distance/pace triangle', () {
    test('a 10:00 mile for 10 minutes covers a mile', () {
      // The example from the brief, worked in canonical units.
      final pace = Units.secPerMileToSecPerKm(600);
      final distance = Pace.distanceMeters(
        durationSeconds: 600,
        paceSecPerKm: pace,
      );

      expect(Units.metersToMiles(distance!), closeTo(1.0, 0.0001));
    });

    test('a mile at a 10:00 mile pace takes ten minutes', () {
      final pace = Units.secPerMileToSecPerKm(600);
      final duration = Pace.durationSeconds(
        distanceMeters: Units.milesToMeters(1),
        paceSecPerKm: pace,
      );

      expect(duration, 600);
    });

    test('five kilometres in 25 minutes is a 5:00 kilometre', () {
      expect(
        Pace.secPerKm(durationSeconds: 1500, distanceMeters: 5000),
        closeTo(300, 0.0001),
      );
    });

    test('returns null rather than infinity for degenerate input', () {
      expect(
        Pace.distanceMeters(durationSeconds: 0, paceSecPerKm: 300),
        isNull,
      );
      expect(
        Pace.distanceMeters(durationSeconds: 600, paceSecPerKm: 0),
        isNull,
      );
      expect(
        Pace.durationSeconds(distanceMeters: 0, paceSecPerKm: 300),
        isNull,
      );
      expect(Pace.secPerKm(durationSeconds: 600, distanceMeters: 0), isNull);
    });
  });

  group('CardioTriple', () {
    test('solves the one missing field', () {
      const triple = CardioTriple(durationSeconds: 1500, distanceMeters: 5000);
      expect(triple.solveMissing().paceSecPerKm, closeTo(300, 0.0001));
    });

    test('leaves a complete triple alone', () {
      const triple = CardioTriple(
        durationSeconds: 1500,
        distanceMeters: 5000,
        // Deliberately inconsistent: solveMissing must not "fix" it, because
        // the user may be mid-edit and about to change the duration.
        paceSecPerKm: 999,
      );
      expect(triple.solveMissing().paceSecPerKm, 999);
    });

    test('leaves a triple with two gaps alone', () {
      const triple = CardioTriple(durationSeconds: 1500);
      expect(triple.solveMissing().distanceMeters, isNull);
      expect(triple.solveMissing().paceSecPerKm, isNull);
    });

    test('solveFor overwrites the named field only', () {
      const triple = CardioTriple(
        durationSeconds: 1500,
        distanceMeters: 5000,
        paceSecPerKm: 999,
      );

      final solved = triple.solveFor(CardioField.pace);
      expect(solved.paceSecPerKm, closeTo(300, 0.0001));
      expect(solved.durationSeconds, 1500);
      expect(solved.distanceMeters, 5000);
    });

    test('solveFor is a no-op when the other two are not both known', () {
      const triple = CardioTriple(durationSeconds: 1500);
      expect(triple.solveFor(CardioField.distance).distanceMeters, isNull);
    });
  });

  group('UnitFormatter.parseDuration', () {
    test('reads bare minutes', () {
      expect(UnitFormatter.parseDuration('45'), 2700);
    });

    test('reads m:ss and h:mm:ss', () {
      expect(UnitFormatter.parseDuration('8:34'), 514);
      expect(UnitFormatter.parseDuration('1:05:00'), 3900);
    });

    test('round-trips through formatDuration', () {
      for (final seconds in const [514, 2700, 3900]) {
        expect(
          UnitFormatter.parseDuration(UnitFormatter.formatDuration(seconds)),
          seconds,
        );
      }
    });

    test('returns null for unreadable or empty input', () {
      expect(UnitFormatter.parseDuration(''), isNull);
      expect(UnitFormatter.parseDuration('0'), isNull);
      expect(UnitFormatter.parseDuration('abc'), isNull);
      expect(UnitFormatter.parseDuration('1:2:3:4'), isNull);
    });
  });
}
