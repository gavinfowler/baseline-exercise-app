/// An injectable source of "now".
///
/// Every part of the app that needs the current time depends on this rather
/// than calling [DateTime.now] directly, so tests can drive time deterministically
/// (see `test/support/fake_clock.dart`). The rest timer in particular is
/// untestable without it.
abstract interface class Clock {
  DateTime now();
}

/// The real clock, used everywhere outside tests.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
