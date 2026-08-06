import '../../data/db/app_database.dart';
import '../models/enums.dart';

/// Works out the weight a plan item actually prescribes for today's session.
///
/// Pure logic: the caller supplies the baseline it looked up, so this is
/// exhaustively testable without a database.
///
/// [baselineWeightKg] is the current baseline for this exercise at this rep
/// count, or null when none has been established yet.
double? resolvePrescribedWeightKg({
  required PlanItemRow item,
  required double? baselineWeightKg,
}) {
  final mode = item.weightMode ?? WeightMode.absolute;

  return switch (mode) {
    WeightMode.absolute => item.targetWeightKg,

    // Before a baseline exists, the plan's written weight seeds it — otherwise
    // a freshly imported plan would prescribe nothing on day one.
    WeightMode.baseline => baselineWeightKg ?? item.targetWeightKg,

    WeightMode.baselinePlus => _offset(
      baselineWeightKg ?? item.targetWeightKg,
      item.weightOffsetKg,
    ),

    WeightMode.baselinePercent => _percent(
      baselineWeightKg ?? item.targetWeightKg,
      item.weightPercent,
    ),
  };
}

double? _offset(double? base, double? offsetKg) {
  if (base == null) return null;
  final result = base + (offsetKg ?? 0);
  // A negative offset larger than the baseline would prescribe a negative
  // weight; clamp rather than propagate nonsense into the log screen.
  return result < 0 ? 0 : result;
}

double? _percent(double? base, double? percent) {
  if (base == null) return null;
  if (percent == null) return base;
  final result = base * (percent / 100);
  return result < 0 ? 0 : result;
}

/// True when this item's weight depends on a baseline, and therefore only makes
/// sense inside a static plan.
bool itemUsesBaseline(PlanItemRow item) =>
    (item.weightMode ?? WeightMode.absolute).usesBaseline;
