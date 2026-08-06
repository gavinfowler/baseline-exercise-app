import 'unit_system.dart';

/// Duration, distance and pace form a triangle: any two of them determine the
/// third. This is the whole of that arithmetic, kept pure so the plan editor can
/// auto-fill a field without owning any maths.
///
/// Everything here is canonical — **seconds**, **meters**, **seconds per
/// kilometre**. Converting a user's `10:00 /mi` into those units is the caller's
/// job, via [UnitFormatter].
abstract final class Pace {
  /// `m:ss`, allowing three digits of minutes so a slow hike still parses.
  static final RegExp _pattern = RegExp(r'^(\d{1,3}):([0-5]\d)$');

  /// `"10:00"` becomes 600. Returns null for anything that is not `m:ss`, so a
  /// half-typed field simply reads as "not set yet" rather than as an error.
  static double? parse(String text) {
    final match = _pattern.firstMatch(text.trim());
    if (match == null) return null;
    return (int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!))
        .toDouble();
  }

  /// The inverse of [parse]. Seconds are rounded, never truncated, so a pace of
  /// 599.6 reads as `10:00` rather than `9:59`.
  static String format(double seconds) => UnitFormatter.formatDuration(
    seconds.isFinite && seconds > 0 ? seconds.round() : 0,
  );

  /// How long covering [distanceMeters] takes at [paceSecPerKm].
  static int? durationSeconds({
    required double distanceMeters,
    required double paceSecPerKm,
  }) {
    if (distanceMeters <= 0 || paceSecPerKm <= 0) return null;
    return (Units.metersToKm(distanceMeters) * paceSecPerKm).round();
  }

  /// How far [durationSeconds] of running at [paceSecPerKm] covers.
  static double? distanceMeters({
    required int durationSeconds,
    required double paceSecPerKm,
  }) {
    if (durationSeconds <= 0 || paceSecPerKm <= 0) return null;
    return Units.kmToMeters(durationSeconds / paceSecPerKm);
  }

  /// The pace implied by covering [distanceMeters] in [durationSeconds].
  static double? secPerKm({
    required int durationSeconds,
    required double distanceMeters,
  }) => Units.paceSecPerKm(
    durationSeconds: durationSeconds,
    distanceMeters: distanceMeters,
  );
}

/// Which leg of the triangle a value belongs to.
enum CardioField { duration, distance, pace }

/// A duration/distance/pace triple, any part of which may be unknown.
class CardioTriple {
  const CardioTriple({
    this.durationSeconds,
    this.distanceMeters,
    this.paceSecPerKm,
  });

  final int? durationSeconds;
  final double? distanceMeters;
  final double? paceSecPerKm;

  bool get isEmpty =>
      durationSeconds == null && distanceMeters == null && paceSecPerKm == null;

  /// Recomputes [target] from the other two fields, leaving them untouched.
  ///
  /// Returns `this` unchanged when the other two are not both known, so a
  /// partially filled form never has a field wiped out from under the user.
  CardioTriple solveFor(CardioField target) {
    switch (target) {
      case CardioField.duration:
        if (distanceMeters == null || paceSecPerKm == null) return this;
        final solved = Pace.durationSeconds(
          distanceMeters: distanceMeters!,
          paceSecPerKm: paceSecPerKm!,
        );
        return solved == null ? this : copyWith(durationSeconds: solved);

      case CardioField.distance:
        if (durationSeconds == null || paceSecPerKm == null) return this;
        final solved = Pace.distanceMeters(
          durationSeconds: durationSeconds!,
          paceSecPerKm: paceSecPerKm!,
        );
        return solved == null ? this : copyWith(distanceMeters: solved);

      case CardioField.pace:
        if (durationSeconds == null || distanceMeters == null) return this;
        final solved = Pace.secPerKm(
          durationSeconds: durationSeconds!,
          distanceMeters: distanceMeters!,
        );
        return solved == null ? this : copyWith(paceSecPerKm: solved);
    }
  }

  /// Fills in whichever single field is missing, if the other two are known.
  ///
  /// This is what the editor calls after any keystroke: enter a pace and a
  /// duration and the distance appears, without the user choosing what to solve.
  CardioTriple solveMissing() {
    final unknown = CardioField.values
        .where(
          (f) => switch (f) {
            CardioField.duration => durationSeconds == null,
            CardioField.distance => distanceMeters == null,
            CardioField.pace => paceSecPerKm == null,
          },
        )
        .toList();
    if (unknown.length != 1) return this;
    return solveFor(unknown.single);
  }

  CardioTriple copyWith({
    int? durationSeconds,
    double? distanceMeters,
    double? paceSecPerKm,
  }) => CardioTriple(
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
  );
}
