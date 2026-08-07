import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/backup/backup_service.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/seed_data.dart';
import '../support/test_database.dart';

/// The seed script writes a file the app has to be able to read.
///
/// It builds that file by hand rather than through `BackupService`, so nothing
/// but this test stops the two drifting apart — a renamed key or a missing
/// column would only surface as a failed restore on a real device.
void main() {
  late AppDatabase db;
  late BackupService backup;

  // Fixed, so the generated history is identical on every run.
  final endDate = DateTime(2026, 8, 7, 12);

  setUp(() {
    db = createTestDatabase();
    backup = BackupService(db);
  });

  Future<RestoreSummary> restore({int weeks = 6, int plansWanted = 3}) {
    final document = buildSeedDocument(
      endDate: endDate,
      weeks: weeks,
      plansWanted: plansWanted,
    );
    return backup.restoreFromJson(jsonEncode(document));
  }

  test('the generated document restores', () async {
    final summary = await restore();

    expect(summary.exercises, greaterThan(30));
    expect(summary.plans, 3);
    expect(summary.sessions, greaterThan(20));
    expect(summary.strengthSets, greaterThan(100));
    expect(summary.cardioEntries, greaterThan(10));
  });

  test('declares the version the restore accepts', () {
    // A mismatch here is rejected outright, with no partial write.
    expect(backupVersion, kBackupVersion);
  });

  test('the starter file has a catalog and a plan but no history', () async {
    final summary = await restore(weeks: 0, plansWanted: 1);

    expect(summary.exercises, greaterThan(30));
    expect(summary.plans, 1);
    expect(summary.sessions, 0);
    expect(summary.strengthSets, 0);

    // The plan still has to be complete enough to open in the editor.
    final days = await db.select(db.planDays).get();
    expect(days, isNotEmpty);
    expect(await db.select(db.planItems).get(), isNotEmpty);
  });

  test('is deterministic', () async {
    String generate() => jsonEncode(buildSeedDocument(endDate: endDate));

    expect(generate(), generate());
  });

  group('referential integrity', () {
    // Foreign keys are enforced from `beforeOpen`, so a dangling reference
    // would already have thrown above. These check the things SQLite cannot.

    test('exactly one plan is active', () async {
      await restore();

      final active = (await db.select(db.plans).get())
          .where((p) => p.isActive)
          .toList();
      expect(active, hasLength(1));
    });

    test('every logged row points at an exercise that exists', () async {
      await restore();

      final ids = (await db.select(db.exercises).get())
          .map((e) => e.id)
          .toSet();

      for (final set in await db.select(db.strengthSets).get()) {
        expect(ids, contains(set.exerciseId));
      }
      for (final entry in await db.select(db.cardioEntries).get()) {
        expect(ids, contains(entry.exerciseId));
      }
    });

    test('no session is dated after the anchor', () async {
      await restore();

      for (final session in await db.select(db.sessions).get()) {
        expect(session.startedAt.isAfter(endDate), isFalse);
        expect(session.endedAt, isNotNull);
      }
    });
  });

  group('the history is self-consistent', () {
    test('cardio pace agrees with its duration and distance', () async {
      await restore();

      for (final entry in await db.select(db.cardioEntries).get()) {
        final duration = entry.actualDurationSeconds!;
        final distance = entry.actualDistanceMeters!;
        expect(
          entry.actualPaceSecPerKm,
          closeTo(duration / (distance / 1000), 1),
          reason: 'entry ${entry.id} has a pace its own numbers do not give',
        );
      }
    });

    test('no personal record beats the sets behind it', () async {
      // A seeded PR nobody ever lifted is worse than no PR at all — it makes
      // the progress screen contradict the log on the same device.
      await restore();

      final sets = await db.select(db.strengthSets).get();
      final records = await db.select(db.personalRecords).get();

      for (final record in records.where(
        (r) => r.recordType == RecordType.maxWeightAtReps,
      )) {
        final matching = sets.where(
          (s) =>
              s.exerciseId == record.exerciseId && s.actualReps == record.reps,
        );
        if (matching.isEmpty) continue;

        final heaviest = matching
            .map((s) => s.actualWeightKg ?? 0)
            .reduce((a, b) => a > b ? a : b);
        expect(record.value, heaviest);
      }
    });

    test('baselines match the heaviest set at their rep target', () async {
      await restore();

      final sets = await db.select(db.strengthSets).get();

      for (final baseline in await db.select(db.exerciseBaselines).get()) {
        final matching = sets.where(
          (s) =>
              s.exerciseId == baseline.exerciseId &&
              s.actualReps == baseline.reps,
        );
        expect(matching, isNotEmpty, reason: 'baseline with no set behind it');

        final heaviest = matching
            .map((s) => s.actualWeightKg ?? 0)
            .reduce((a, b) => a > b ? a : b);
        expect(baseline.weightKg, heaviest);
      }
    });

    test('working weights climb over time', () async {
      // Otherwise the progress chart is a flat line and proves nothing.
      await restore();

      final squat = (await db.select(db.exercises).get()).firstWhere(
        (e) => e.name == 'Back Squat',
      );

      final sets =
          await (db.select(db.strengthSets)
                ..where((t) => t.exerciseId.equals(squat.id))
                ..orderBy([(t) => OrderingTerm.asc(t.performedAt)]))
              .get();

      expect(sets.length, greaterThan(10));
      expect(
        sets.last.actualWeightKg!,
        greaterThan(sets.first.actualWeightKg!),
      );
    });
  });
}
