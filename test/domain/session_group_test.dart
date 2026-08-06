import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/domain/models/session_group.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a row directly — grouping is pure logic and needs no database.
StrengthSetRow row({
  int id = 1,
  int exerciseId = 1,
  int groupIndex = 0,
  BlockKind groupKind = BlockKind.single,
  String? groupLabel,
  int roundIndex = 0,
  int itemIndex = 0,
  int? actualReps = 8,
  double? actualWeightKg = 60,
  bool isWarmup = false,
  EntryStatus status = EntryStatus.completed,
}) {
  return StrengthSetRow(
    id: id,
    sessionId: 1,
    exerciseId: exerciseId,
    groupIndex: groupIndex,
    groupKind: groupKind,
    groupLabel: groupLabel,
    roundIndex: roundIndex,
    itemIndex: itemIndex,
    actualReps: actualReps,
    actualWeightKg: actualWeightKg,
    isWarmup: isWarmup,
    status: status,
  );
}

void main() {
  test('an empty list produces no groups', () {
    expect(groupStrengthSets([]), isEmpty);
  });

  test('sets of one exercise collapse into a single group', () {
    final groups = groupStrengthSets([
      row(id: 1, roundIndex: 0),
      row(id: 2, roundIndex: 1),
      row(id: 3, roundIndex: 2),
    ]);

    expect(groups, hasLength(1));
    expect(groups.single.roundCount, 3);
    expect(groups.single.isSuperset, isFalse);
    expect(groups.single.exerciseIds, [1]);
  });

  test('groups are ordered by group index regardless of input order', () {
    final groups = groupStrengthSets([
      row(id: 1, groupIndex: 2),
      row(id: 2, groupIndex: 0),
      row(id: 3, groupIndex: 1),
    ]);

    expect(groups.map((g) => g.groupIndex), [0, 1, 2]);
  });

  test('sets within a group are ordered by round, then position', () {
    final groups = groupStrengthSets([
      row(id: 1, roundIndex: 1, itemIndex: 1),
      row(id: 2, roundIndex: 0, itemIndex: 1),
      row(id: 3, roundIndex: 1, itemIndex: 0),
      row(id: 4, roundIndex: 0, itemIndex: 0),
    ]);

    expect(groups.single.sets.map((s) => s.id), [4, 2, 3, 1]);
  });

  group('supersets', () {
    test('keep every exercise in performance order', () {
      // A superset of bench (item 0) and row (item 1), three rounds.
      final sets = [
        for (var round = 0; round < 3; round++) ...[
          row(
            id: round * 2 + 1,
            exerciseId: 1,
            groupKind: BlockKind.superset,
            groupLabel: 'A',
            roundIndex: round,
            itemIndex: 0,
          ),
          row(
            id: round * 2 + 2,
            exerciseId: 2,
            groupKind: BlockKind.superset,
            groupLabel: 'A',
            roundIndex: round,
            itemIndex: 1,
          ),
        ],
      ];

      final group = groupStrengthSets(sets).single;

      expect(group.isSuperset, isTrue);
      expect(group.label, 'A');
      expect(group.exerciseIds, [1, 2]);
      expect(group.roundCount, 3);
      expect(group.sets, hasLength(6));
    });

    test('setsForRound returns one entry per exercise', () {
      final sets = [
        row(id: 1, exerciseId: 1, groupKind: BlockKind.superset, itemIndex: 0),
        row(id: 2, exerciseId: 2, groupKind: BlockKind.superset, itemIndex: 1),
        row(
          id: 3,
          exerciseId: 1,
          groupKind: BlockKind.superset,
          roundIndex: 1,
          itemIndex: 0,
        ),
      ];

      final group = groupStrengthSets(sets).single;
      expect(group.setsForRound(0).map((s) => s.id), [1, 2]);
      expect(group.setsForRound(1).map((s) => s.id), [3]);
    });

    test('a repeated exercise is listed once', () {
      final group = groupStrengthSets([
        row(id: 1, exerciseId: 7, roundIndex: 0),
        row(id: 2, exerciseId: 7, roundIndex: 1),
      ]).single;

      expect(group.exerciseIds, [7]);
    });
  });

  group('workingVolumeKg', () {
    test('sums weight times reps for completed working sets', () {
      final group = groupStrengthSets([
        row(id: 1, actualWeightKg: 60, actualReps: 10),
        row(id: 2, actualWeightKg: 65, actualReps: 8),
      ]).single;

      expect(group.workingVolumeKg, 60 * 10 + 65 * 8);
    });

    test('excludes warm-ups, skipped and pending sets', () {
      final group = groupStrengthSets([
        row(id: 1, actualWeightKg: 60, actualReps: 10),
        row(id: 2, actualWeightKg: 20, actualReps: 15, isWarmup: true),
        row(
          id: 3,
          actualWeightKg: 60,
          actualReps: 10,
          status: EntryStatus.skipped,
        ),
        row(
          id: 4,
          actualWeightKg: null,
          actualReps: null,
          status: EntryStatus.pending,
        ),
      ]).single;

      expect(group.workingVolumeKg, 600);
    });
  });
}
