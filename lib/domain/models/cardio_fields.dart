import 'enums.dart';

/// A metric that can be recorded for a cardio effort.
enum CardioField {
  duration,
  distance,
  incline,
  resistance,
  heartRate,
  calories,
  elevation,
}

/// Which metrics the log form should prompt for, per activity.
///
/// Asking a swimmer for treadmill incline, or a stair climber for distance, is
/// how a logging screen becomes tedious enough to stop using. Pace is not listed
/// because it is always derived from duration and distance rather than entered.
Set<CardioField> cardioFieldsFor(CardioActivity? activity) {
  const base = {
    CardioField.duration,
    CardioField.heartRate,
    CardioField.calories,
  };

  return switch (activity) {
    CardioActivity.run || CardioActivity.walk => {
      ...base,
      CardioField.distance,
      // Treadmills are the common indoor case for both.
      CardioField.incline,
      CardioField.elevation,
    },
    CardioActivity.hike => {
      ...base,
      CardioField.distance,
      CardioField.elevation,
    },
    CardioActivity.cycle => {
      ...base,
      CardioField.distance,
      CardioField.resistance,
      CardioField.elevation,
    },
    CardioActivity.row || CardioActivity.elliptical => {
      ...base,
      CardioField.distance,
      CardioField.resistance,
    },
    CardioActivity.swim => {...base, CardioField.distance},
    CardioActivity.stairs => {
      ...base,
      CardioField.resistance,
      CardioField.elevation,
    },
    CardioActivity.other || null => {...base, CardioField.distance},
  };
}

/// True when pace is meaningful for this activity — that is, when it covers
/// distance. A stair climber has no pace worth showing.
bool activityHasPace(CardioActivity? activity) =>
    cardioFieldsFor(activity).contains(CardioField.distance);
