import 'package:exercise_app/domain/models/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeVocabulary', () {
    test('keeps the curated order of the standard list', () {
      final merged = mergeVocabulary(const ['Chest', 'Back'], const []);
      expect(merged, ['Chest', 'Back']);
    });

    test('appends unknown values alphabetically', () {
      final merged = mergeVocabulary(
        const ['Chest'],
        const ['Sandbag', 'Anvil'],
      );
      expect(merged, ['Chest', 'Anvil', 'Sandbag']);
    });

    test('does not duplicate a value that differs only by case', () {
      // An import may well have written "barbell"; offering both spellings
      // would split the filter in two.
      final merged = mergeVocabulary(const ['Barbell'], const ['barbell']);
      expect(merged, ['Barbell']);
    });

    test('ignores nulls and blanks', () {
      final merged = mergeVocabulary(const ['Chest'], const [null, '', '   ']);
      expect(merged, ['Chest']);
    });

    test('trims what it keeps', () {
      final merged = mergeVocabulary(const [], const ['  Sandbag  ']);
      expect(merged, ['Sandbag']);
    });

    test('collapses repeats of the same new value', () {
      final merged = mergeVocabulary(const [], const [
        'Sandbag',
        'sandbag',
        'Sandbag',
      ]);
      expect(merged, hasLength(1));
    });

    test('an empty standard list yields just what is in use, sorted', () {
      // This is how the filter dropdowns are built: only offer choices that
      // can actually return something.
      final merged = mergeVocabulary(const [], const ['Rower', 'Barbell']);
      expect(merged, ['Barbell', 'Rower']);
    });
  });

  group('the shipped vocabularies', () {
    test('have no duplicates', () {
      for (final list in [standardMuscleGroups, standardEquipment]) {
        final lowered = list.map((e) => e.toLowerCase()).toList();
        expect(lowered.toSet(), hasLength(list.length));
      }
    });

    test('are all non-empty and trimmed', () {
      for (final value in [...standardMuscleGroups, ...standardEquipment]) {
        expect(value.trim(), value);
        expect(value, isNotEmpty);
      }
    });
  });
}
