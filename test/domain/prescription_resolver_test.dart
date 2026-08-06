import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/progression/prescription_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

PlanItemRow item({
  WeightMode? weightMode,
  double? targetWeightKg,
  double? weightOffsetKg,
  double? weightPercent,
  int? targetReps = 8,
}) {
  return PlanItemRow(
    id: 1,
    planBlockId: 1,
    exerciseId: 1,
    orderIndex: 0,
    targetReps: targetReps,
    targetWeightKg: targetWeightKg,
    weightMode: weightMode,
    weightOffsetKg: weightOffsetKg,
    weightPercent: weightPercent,
    toFailure: false,
  );
}

void main() {
  group('absolute', () {
    test('uses the weight written in the plan and ignores the baseline', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.absolute, targetWeightKg: 60),
          baselineWeightKg: 100,
        ),
        60,
      );
    });

    test('is the default when no mode is set', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(targetWeightKg: 60),
          baselineWeightKg: 100,
        ),
        60,
      );
    });
  });

  group('baseline', () {
    test('uses the current baseline', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baseline, targetWeightKg: 60),
          baselineWeightKg: 85,
        ),
        85,
      );
    });

    test('falls back to the plan weight before a baseline exists', () {
      // Otherwise a freshly imported plan would prescribe nothing on day one.
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baseline, targetWeightKg: 60),
          baselineWeightKg: null,
        ),
        60,
      );
    });

    test('is null when there is neither a baseline nor a plan weight', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baseline),
          baselineWeightKg: null,
        ),
        isNull,
      );
    });
  });

  group('baselinePlus', () {
    test('adds the offset to the baseline', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baselinePlus, weightOffsetKg: 2.5),
          baselineWeightKg: 80,
        ),
        82.5,
      );
    });

    test('treats a missing offset as zero', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baselinePlus),
          baselineWeightKg: 80,
        ),
        80,
      );
    });

    test('a negative offset reduces the weight', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baselinePlus, weightOffsetKg: -10),
          baselineWeightKg: 80,
        ),
        70,
      );
    });

    test('clamps at zero rather than prescribing a negative weight', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baselinePlus, weightOffsetKg: -200),
          baselineWeightKg: 80,
        ),
        0,
      );
    });
  });

  group('baselinePercent', () {
    test('takes a percentage of the baseline', () {
      // A 70% back-off set.
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baselinePercent, weightPercent: 70),
          baselineWeightKg: 100,
        ),
        70,
      );
    });

    test('can exceed 100 percent', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(
            weightMode: WeightMode.baselinePercent,
            weightPercent: 105,
          ),
          baselineWeightKg: 100,
        ),
        105,
      );
    });

    test('treats a missing percentage as the full baseline', () {
      expect(
        resolvePrescribedWeightKg(
          item: item(weightMode: WeightMode.baselinePercent),
          baselineWeightKg: 100,
        ),
        100,
      );
    });
  });

  group('itemUsesBaseline', () {
    test('is false only for absolute weights', () {
      expect(itemUsesBaseline(item(weightMode: WeightMode.absolute)), isFalse);
      expect(itemUsesBaseline(item()), isFalse);
      expect(itemUsesBaseline(item(weightMode: WeightMode.baseline)), isTrue);
      expect(
        itemUsesBaseline(item(weightMode: WeightMode.baselinePlus)),
        isTrue,
      );
      expect(
        itemUsesBaseline(item(weightMode: WeightMode.baselinePercent)),
        isTrue,
      );
    });
  });
}
