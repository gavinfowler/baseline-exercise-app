import 'package:collection/collection.dart';

import '../../data/db/app_database.dart';
import 'enums.dart';

/// One block of a session as the UI shows it: a single exercise, or a superset
/// of several, together with every set logged against it.
class SessionGroup {
  const SessionGroup({
    required this.groupIndex,
    required this.kind,
    required this.label,
    required this.exerciseIds,
    required this.sets,
  });

  final int groupIndex;
  final BlockKind kind;
  final String? label;

  /// Distinct exercises in this block, in the order they are performed.
  final List<int> exerciseIds;

  final List<StrengthSetRow> sets;

  bool get isSuperset => kind.isGrouped;

  /// How many times through the block have been logged.
  int get roundCount =>
      sets.isEmpty ? 0 : sets.map((s) => s.roundIndex).toSet().length;

  List<StrengthSetRow> setsForRound(int roundIndex) =>
      sets.where((s) => s.roundIndex == roundIndex).toList();

  /// Total weight moved, ignoring warm-ups and anything not completed.
  double get workingVolumeKg => sets
      .where(
        (s) =>
            !s.isWarmup &&
            s.status == EntryStatus.completed &&
            s.actualWeightKg != null &&
            s.actualReps != null,
      )
      .fold(0, (sum, s) => sum + s.actualWeightKg! * s.actualReps!);
}

/// Groups flat set rows into displayable blocks.
///
/// Rows carry their own `groupIndex`/`groupKind` snapshot rather than pointing
/// at a plan, so this works identically for planned and ad-hoc workouts, and
/// keeps working after the originating plan is edited or deleted.
List<SessionGroup> groupStrengthSets(List<StrengthSetRow> sets) {
  final byGroup = groupBy(sets, (StrengthSetRow s) => s.groupIndex);

  final groups = byGroup.entries.map((entry) {
    final rows = entry.value.sorted((a, b) {
      final round = a.roundIndex.compareTo(b.roundIndex);
      return round != 0 ? round : a.itemIndex.compareTo(b.itemIndex);
    });

    // Exercise order comes from position within a round, not from insertion
    // order, so a superset always reads A, B, C.
    final ordered = rows.sorted((a, b) => a.itemIndex.compareTo(b.itemIndex));

    return SessionGroup(
      groupIndex: entry.key,
      kind: rows.first.groupKind,
      label: rows.first.groupLabel,
      exerciseIds: ordered.map((s) => s.exerciseId).toSet().toList(),
      sets: rows,
    );
  }).toList();

  groups.sort((a, b) => a.groupIndex.compareTo(b.groupIndex));
  return groups;
}
