import 'package:drift/native.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates an isolated, in-memory database for a single test and registers its
/// teardown.
///
/// This is the reason the app persists through Drift: every test gets a real
/// SQLite instance in milliseconds, so queries, constraints and cascades are
/// verified against actual SQL instead of against mocks.
AppDatabase createTestDatabase() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}
