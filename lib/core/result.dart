import 'package:collection/collection.dart';

/// A single problem found while validating user-supplied data.
///
/// [pointer] is an RFC 6901 JSON Pointer into the uploaded plan file
/// (`/plan/days/0/blocks/1/exercises/0/reps`) so the UI can tell the user
/// exactly which part of their file is wrong.
class ValidationIssue {
  const ValidationIssue({
    required this.pointer,
    required this.message,
    this.severity = IssueSeverity.error,
  });

  final String pointer;
  final String message;
  final IssueSeverity severity;

  bool get isError => severity == IssueSeverity.error;

  /// Renders the pointer in a form a person can act on.
  String get location => pointer.isEmpty ? 'file' : pointer;

  @override
  String toString() => '$location: $message';

  @override
  bool operator ==(Object other) =>
      other is ValidationIssue &&
      other.pointer == pointer &&
      other.message == message &&
      other.severity == severity;

  @override
  int get hashCode => Object.hash(pointer, message, severity);
}

enum IssueSeverity { error, warning }

/// Result of an operation that can fail with a *list* of problems.
///
/// Validation deliberately reports every issue at once rather than stopping at
/// the first, so a user fixing a generated plan file does not have to re-upload
/// once per mistake.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  /// The value on success, or `null` on failure.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// The issues on failure, or an empty list on success.
  List<ValidationIssue> get issues => switch (this) {
    Ok<T>() => const [],
    Err<T>(:final issues) => issues,
  };

  R fold<R>(
    R Function(T value) onOk,
    R Function(List<ValidationIssue> issues) onErr,
  ) => switch (this) {
    Ok<T>(:final value) => onOk(value),
    Err<T>(:final issues) => onErr(issues),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok(transform(value)),
    Err<T>(:final issues) => Err(issues),
  };
}

class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

class Err<T> extends Result<T> {
  Err(List<ValidationIssue> issues)
    : issues = List.unmodifiable(issues),
      assert(issues.isNotEmpty, 'An Err must carry at least one issue');

  Err.single(ValidationIssue issue) : issues = List.unmodifiable([issue]);

  @override
  final List<ValidationIssue> issues;

  /// Errors only — warnings never block an import.
  List<ValidationIssue> get errors => issues.where((i) => i.isError).toList();

  @override
  bool operator ==(Object other) =>
      other is Err<T> &&
      const ListEquality<ValidationIssue>().equals(other.issues, issues);

  @override
  int get hashCode => const ListEquality<ValidationIssue>().hash(issues);

  @override
  String toString() => 'Err(${issues.join('; ')})';
}
