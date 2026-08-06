import 'dart:async';

import 'package:drift/drift.dart';

/// Applied automatically to every test in this directory tree.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Several tests deliberately open more than one in-memory database at once
  // (for example, exporting from one and restoring into another). They are
  // fully isolated, so drift's shared-executor warning does not apply.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
