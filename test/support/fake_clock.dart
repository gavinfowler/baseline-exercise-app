import 'package:exercise_app/core/time/clock.dart';

/// A [Clock] the test drives by hand.
///
/// Anything that records "when" — set timestamps, baseline promotion dates,
/// rest durations — reads through this so assertions can be exact rather than
/// approximate.
class FakeClock implements Clock {
  FakeClock([DateTime? start])
    : _now = start ?? DateTime.utc(2026, 1, 5, 9, 30);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) => _now = _now.add(duration);

  void setTo(DateTime value) => _now = value;
}
