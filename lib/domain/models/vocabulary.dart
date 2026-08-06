/// The standard vocabularies offered in the exercise editor's pickers.
///
/// These are *suggestions*, not a closed set: the editor always offers "Other"
/// so a user can type something these lists never anticipated, and the filter
/// picks its options from what the catalog actually contains. Nothing in the
/// schema or the database constrains these values.
library;

/// Muscle groups, ordered head to toe rather than alphabetically — that is how
/// people think about a training split.
const List<String> standardMuscleGroups = [
  'Chest',
  'Back',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Forearms',
  'Arms',
  'Core',
  'Abs',
  'Obliques',
  'Lower Back',
  'Glutes',
  'Quads',
  'Hamstrings',
  'Calves',
  'Legs',
  'Hip Flexors',
  'Adductors',
  'Abductors',
  'Neck',
  'Full Body',
  'Cardio',
];

/// Equipment, most common first so the usual choice is a short scroll away.
const List<String> standardEquipment = [
  'Barbell',
  'Dumbbell',
  'Kettlebell',
  'Machine',
  'Cable',
  'Smith Machine',
  'Bodyweight',
  'Resistance Band',
  'Suspension Trainer',
  'Medicine Ball',
  'Stability Ball',
  'EZ Bar',
  'Trap Bar',
  'Weight Plate',
  'Bench',
  'Pull-Up Bar',
  'Dip Station',
  'Sled',
  'Battle Ropes',
  'Foam Roller',
  'Treadmill',
  'Stationary Bike',
  'Rower',
  'Elliptical',
  'Stair Climber',
  'Assault Bike',
  'Jump Rope',
  'Pool',
  'None',
];

/// Merges the standard vocabulary with whatever the catalog already uses, so a
/// value that arrived through a plan import or an older build still appears in
/// the picker instead of silently becoming unreachable.
///
/// Standard entries keep their curated order and come first; anything extra is
/// appended alphabetically. Comparison is case-insensitive so "barbell" from an
/// import does not sit next to "Barbell".
List<String> mergeVocabulary(List<String> standard, Iterable<String?> used) {
  final seen = {for (final s in standard) s.toLowerCase()};
  final extra = <String>[];

  for (final value in used) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) continue;
    // Tracked lower-cased, so "Sandbag" and "sandbag" collapse to whichever
    // spelling was seen first rather than becoming two entries.
    if (!seen.add(trimmed.toLowerCase())) continue;
    extra.add(trimmed);
  }

  final sorted = extra.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [...standard, ...sorted];
}
