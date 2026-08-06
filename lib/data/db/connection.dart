import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-device database file.
///
/// Uses the application *support* directory rather than a documents or cache
/// directory: it is private to the app, is not user-browsable, and is not
/// subject to being cleared by the OS to reclaim space.
///
/// [LazyDatabase] defers all of this until the first query, so constructing the
/// database is synchronous and cheap.
QueryExecutor openAppDatabaseConnection({
  String fileName = 'exercise_app.sqlite',
}) {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));

    // Runs the SQLite work on a background isolate so large history queries
    // never block the UI thread.
    return NativeDatabase.createInBackground(file);
  });
}

/// Resolves the path of the database file without opening it — needed by the
/// backup feature, which reports where the data lives.
Future<String> appDatabaseFilePath({
  String fileName = 'exercise_app.sqlite',
}) async {
  final dir = await getApplicationSupportDirectory();
  return p.join(dir.path, fileName);
}
