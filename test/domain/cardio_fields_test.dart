import 'package:exercise_app/domain/models/cardio_fields.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every activity prompts for duration', () {
    // Duration is the one metric that always applies; without it an entry
    // cannot be saved at all.
    for (final activity in CardioActivity.values) {
      expect(
        cardioFieldsFor(activity),
        contains(CardioField.duration),
        reason: '${activity.wireName} must track duration',
      );
    }
  });

  test('an unknown activity still gets a usable field set', () {
    expect(cardioFieldsFor(null), contains(CardioField.duration));
    expect(cardioFieldsFor(null), contains(CardioField.distance));
  });

  group('activity-specific fields', () {
    test('running offers incline for the treadmill case', () {
      expect(
        cardioFieldsFor(CardioActivity.run),
        contains(CardioField.incline),
      );
    });

    test('swimming has no incline or resistance', () {
      final fields = cardioFieldsFor(CardioActivity.swim);
      expect(fields, contains(CardioField.distance));
      expect(fields, isNot(contains(CardioField.incline)));
      expect(fields, isNot(contains(CardioField.resistance)));
    });

    test('a stair climber tracks no distance', () {
      // Asking for distance on a stair climber is how a log screen becomes
      // tedious enough to abandon.
      final fields = cardioFieldsFor(CardioActivity.stairs);
      expect(fields, isNot(contains(CardioField.distance)));
      expect(fields, contains(CardioField.elevation));
    });

    test('machines with resistance offer it', () {
      for (final activity in [
        CardioActivity.cycle,
        CardioActivity.row,
        CardioActivity.elliptical,
        CardioActivity.stairs,
      ]) {
        expect(
          cardioFieldsFor(activity),
          contains(CardioField.resistance),
          reason: '${activity.wireName} should track resistance',
        );
      }
    });

    test('hiking tracks elevation', () {
      expect(
        cardioFieldsFor(CardioActivity.hike),
        contains(CardioField.elevation),
      );
    });
  });

  group('activityHasPace', () {
    test('is true for distance-covering activities', () {
      expect(activityHasPace(CardioActivity.run), isTrue);
      expect(activityHasPace(CardioActivity.swim), isTrue);
      expect(activityHasPace(CardioActivity.cycle), isTrue);
    });

    test('is false where pace is meaningless', () {
      expect(activityHasPace(CardioActivity.stairs), isFalse);
    });
  });
}
