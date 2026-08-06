import 'package:exercise_app/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const issue = ValidationIssue(
    pointer: '/plan/days/0/blocks/1/exercises/0/reps',
    message: 'reps must be a positive integer',
  );

  group('Ok', () {
    test('carries the value and no issues', () {
      const result = Ok<int>(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.issues, isEmpty);
    });

    test('maps the value', () {
      const result = Ok<int>(21);
      expect(result.map((v) => v * 2).valueOrNull, 42);
    });

    test('folds to the success branch', () {
      const result = Ok<int>(7);
      expect(result.fold((v) => 'ok $v', (_) => 'err'), 'ok 7');
    });
  });

  group('Err', () {
    test('carries the issues and no value', () {
      final result = Err<int>.single(issue);
      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.issues, [issue]);
    });

    test('map preserves the issues without invoking the transform', () {
      final result = Err<int>.single(issue);
      var called = false;
      final mapped = result.map((v) {
        called = true;
        return v * 2;
      });
      expect(called, isFalse);
      expect(mapped.issues, [issue]);
    });

    test('separates errors from warnings', () {
      final result = Err<int>([
        issue,
        const ValidationIssue(
          pointer: '/plan/name',
          message: 'unusually long name',
          severity: IssueSeverity.warning,
        ),
      ]);
      expect(result.issues, hasLength(2));
      expect(result.errors, hasLength(1));
    });

    test('exposes every issue at once, not just the first', () {
      // Validation reports everything so a user fixing a generated plan file
      // does not have to re-upload once per mistake.
      final result = Err<int>([
        issue,
        const ValidationIssue(pointer: '/plan/mode', message: 'unknown mode'),
        const ValidationIssue(
          pointer: '/plan/days',
          message: 'must not be empty',
        ),
      ]);
      expect(result.issues, hasLength(3));
    });

    test('compares by value so tests can assert on exact issue lists', () {
      expect(Err<int>.single(issue), equals(Err<int>.single(issue)));
    });
  });

  group('ValidationIssue', () {
    test('describes its location for the user', () {
      expect(issue.location, '/plan/days/0/blocks/1/exercises/0/reps');
      expect(
        const ValidationIssue(pointer: '', message: 'bad file').location,
        'file',
      );
    });
  });
}
