import 'package:intl/intl.dart';

/// Which units the user sees. Storage is always metric; this only affects display
/// and data entry, so switching never migrates stored rows.
enum UnitSystem {
  metric,
  imperial;

  static UnitSystem fromName(String name) => UnitSystem.values.firstWhere(
    (u) => u.name == name,
    orElse: () => UnitSystem.metric,
  );
}

/// Pure conversion helpers between the canonical storage units
/// (kilograms, meters, seconds) and imperial display units.
///
/// All of these are exact by definition, not approximations.
abstract final class Units {
  static const double _kgPerLb = 0.45359237;
  static const double _metersPerMile = 1609.344;
  static const double metersPerKm = 1000;

  static double kgToLb(double kg) => kg / _kgPerLb;

  static double lbToKg(double lb) => lb * _kgPerLb;

  static double metersToMiles(double meters) => meters / _metersPerMile;

  static double milesToMeters(double miles) => miles * _metersPerMile;

  static double metersToKm(double meters) => meters / metersPerKm;

  static double kmToMeters(double km) => km * metersPerKm;

  /// Pace is stored as seconds per kilometer; imperial users read seconds per mile.
  static double secPerKmToSecPerMile(double secPerKm) =>
      secPerKm * (_metersPerMile / metersPerKm);

  static double secPerMileToSecPerKm(double secPerMile) =>
      secPerMile * (metersPerKm / _metersPerMile);

  /// Derives pace from a completed effort. Returns `null` when it is undefined
  /// (zero or negative distance), rather than yielding infinity.
  static double? paceSecPerKm({
    required int durationSeconds,
    required double distanceMeters,
  }) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return null;
    return durationSeconds / metersToKm(distanceMeters);
  }

  /// Derives speed in km/h. Returns `null` when undefined.
  static double? speedKmh({
    required int durationSeconds,
    required double distanceMeters,
  }) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return null;
    return metersToKm(distanceMeters) / (durationSeconds / 3600);
  }

  /// Epley estimated one-rep max. At 1 rep it returns the weight unchanged.
  static double estimatedOneRepMax({
    required double weightKg,
    required int reps,
  }) {
    if (reps <= 1) return weightKg;
    return weightKg * (1 + reps / 30);
  }
}

/// Formats canonical values for display in the user's chosen unit system.
class UnitFormatter {
  const UnitFormatter(this.system);

  final UnitSystem system;

  bool get isMetric => system == UnitSystem.metric;

  String get weightSuffix => isMetric ? 'kg' : 'lb';

  String get distanceSuffix => isMetric ? 'km' : 'mi';

  String get paceSuffix => isMetric ? '/km' : '/mi';

  /// Converts a stored weight into the display unit, without formatting.
  double weightValue(double kg) => isMetric ? kg : Units.kgToLb(kg);

  /// Converts a user-entered weight back into kilograms for storage.
  double weightToKg(double displayValue) =>
      isMetric ? displayValue : Units.lbToKg(displayValue);

  /// Converts a stored distance into the display unit, without formatting.
  double distanceValue(double meters) =>
      isMetric ? Units.metersToKm(meters) : Units.metersToMiles(meters);

  /// Converts a user-entered distance back into meters for storage.
  double distanceToMeters(double displayValue) => isMetric
      ? Units.kmToMeters(displayValue)
      : Units.milesToMeters(displayValue);

  String formatWeight(double kg, {bool withSuffix = true}) {
    final value = weightValue(kg);
    final text = _trimNumber(value, maxDecimals: 1);
    return withSuffix ? '$text $weightSuffix' : text;
  }

  String formatDistance(double meters, {bool withSuffix = true}) {
    final value = distanceValue(meters);
    final text = _trimNumber(value, maxDecimals: 2);
    return withSuffix ? '$text $distanceSuffix' : text;
  }

  /// Reads a typed duration back into seconds.
  ///
  /// Deliberately forgiving, because this parses what a user is halfway through
  /// typing: `45` is 45 minutes, `8:34` is 8m34s, `1:05:00` is an hour and five
  /// minutes. Returns null for anything unreadable, which the editor treats as
  /// "not set yet" rather than as an error.
  ///
  /// Bare minutes are the friendly reading here; the plan *file* format is
  /// stricter and insists on `m:ss`, where there is no user to guess for.
  static int? parseDuration(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');
    if (parts.length > 3) return null;

    final numbers = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part.trim());
      if (value == null || value < 0) return null;
      numbers.add(value);
    }

    final seconds = switch (numbers.length) {
      1 => numbers[0] * 60,
      2 => numbers[0] * 60 + numbers[1],
      _ => numbers[0] * 3600 + numbers[1] * 60 + numbers[2],
    };
    return seconds <= 0 ? null : seconds;
  }

  /// `1:05:03` when there are hours, `5:03` otherwise. Negative input clamps to zero.
  static String formatDuration(int seconds) {
    final total = seconds < 0 ? 0 : seconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final two = NumberFormat('00');
    if (h > 0) return '$h:${two.format(m)}:${two.format(s)}';
    return '$m:${two.format(s)}';
  }

  /// Pace reads as `m:ss` per unit — `5:30 /km`. Seconds are rounded, not truncated.
  String formatPace(double secPerKm, {bool withSuffix = true}) {
    final converted = isMetric
        ? secPerKm
        : Units.secPerKmToSecPerMile(secPerKm);
    final text = formatDuration(converted.round());
    return withSuffix ? '$text $paceSuffix' : text;
  }

  /// Drops trailing zeros so `61.0` reads as `61` but `61.25` survives.
  static String _trimNumber(double value, {required int maxDecimals}) {
    final fixed = value.toStringAsFixed(maxDecimals);
    if (!fixed.contains('.')) return fixed;
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
