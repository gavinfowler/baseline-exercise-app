import 'package:exercise_app/core/units/unit_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Units conversions', () {
    test('kilograms and pounds round-trip exactly', () {
      expect(Units.kgToLb(100), closeTo(220.462262, 0.000001));
      expect(Units.lbToKg(Units.kgToLb(137.5)), closeTo(137.5, 1e-12));
    });

    test('meters and miles round-trip exactly', () {
      expect(Units.metersToMiles(1609.344), closeTo(1.0, 1e-12));
      expect(Units.milesToMeters(3.1), closeTo(4988.9664, 1e-9));
    });

    test('pace converts between per-km and per-mile', () {
      // A 5:00/km pace is a little over 8:02/mile.
      expect(Units.secPerKmToSecPerMile(300), closeTo(482.8032, 1e-6));
      expect(
        Units.secPerMileToSecPerKm(Units.secPerKmToSecPerMile(330)),
        closeTo(330, 1e-9),
      );
    });
  });

  group('derived cardio metrics', () {
    test('pace is seconds per kilometre', () {
      // 5 km in 25 minutes is 5:00/km.
      expect(
        Units.paceSecPerKm(durationSeconds: 1500, distanceMeters: 5000),
        closeTo(300, 1e-9),
      );
    });

    test(
      'pace and speed are null rather than infinite when distance is zero',
      () {
        // A treadmill session logged with time but no distance must not produce
        // an infinite pace that then poisons a chart or a personal record.
        expect(
          Units.paceSecPerKm(durationSeconds: 1200, distanceMeters: 0),
          isNull,
        );
        expect(
          Units.speedKmh(durationSeconds: 1200, distanceMeters: 0),
          isNull,
        );
        expect(
          Units.paceSecPerKm(durationSeconds: 0, distanceMeters: 5000),
          isNull,
        );
      },
    );

    test('speed is km per hour', () {
      expect(
        Units.speedKmh(durationSeconds: 3600, distanceMeters: 10000),
        closeTo(10, 1e-9),
      );
    });
  });

  group('estimated one-rep max', () {
    test('returns the weight unchanged at one rep', () {
      expect(Units.estimatedOneRepMax(weightKg: 100, reps: 1), 100);
    });

    test('never estimates below the weight actually lifted', () {
      expect(Units.estimatedOneRepMax(weightKg: 100, reps: 0), 100);
    });

    test('applies the Epley formula above one rep', () {
      // 100kg x 5 -> 100 * (1 + 5/30)
      expect(
        Units.estimatedOneRepMax(weightKg: 100, reps: 5),
        closeTo(116.6667, 0.0001),
      );
    });
  });

  group('UnitFormatter', () {
    const metric = UnitFormatter(UnitSystem.metric);
    const imperial = UnitFormatter(UnitSystem.imperial);

    test('formats weight in the chosen system', () {
      expect(metric.formatWeight(61.235), '61.2 kg');
      expect(imperial.formatWeight(Units.lbToKg(135)), '135 lb');
    });

    test('drops trailing zeros', () {
      expect(metric.formatWeight(60), '60 kg');
      expect(metric.formatDistance(5000), '5 km');
    });

    test('formats distance in the chosen system', () {
      expect(metric.formatDistance(5000), '5 km');
      expect(imperial.formatDistance(1609.344), '1 mi');
    });

    test('converts user input back to storage units', () {
      expect(imperial.weightToKg(135), closeTo(61.2349, 0.0001));
      expect(metric.weightToKg(61.5), 61.5);
      expect(imperial.distanceToMeters(1), closeTo(1609.344, 1e-9));
    });

    test('formats duration with hours only when needed', () {
      expect(UnitFormatter.formatDuration(65), '1:05');
      expect(UnitFormatter.formatDuration(3665), '1:01:05');
      expect(UnitFormatter.formatDuration(0), '0:00');
    });

    test(
      'clamps negative durations to zero rather than rendering nonsense',
      () {
        expect(UnitFormatter.formatDuration(-30), '0:00');
      },
    );

    test('formats pace per the chosen distance unit', () {
      expect(metric.formatPace(300), '5:00 /km');
      expect(imperial.formatPace(300), '8:03 /mi');
    });
  });

  group('UnitSystem.fromName', () {
    test('parses known names', () {
      expect(UnitSystem.fromName('imperial'), UnitSystem.imperial);
      expect(UnitSystem.fromName('metric'), UnitSystem.metric);
    });

    test('falls back to metric for unknown input rather than throwing', () {
      // A corrupt settings row must not prevent the app from starting.
      expect(UnitSystem.fromName('furlongs'), UnitSystem.metric);
    });
  });
}
