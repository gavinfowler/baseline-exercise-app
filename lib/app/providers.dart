import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/time/clock.dart';
import '../core/units/unit_system.dart';
import '../data/db/app_database.dart';
import '../data/db/connection.dart';
import '../data/db/seed_exercises.dart';
import '../data/repositories/baseline_repository.dart';
import '../data/repositories/exercise_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/personal_record_repository.dart';
import '../data/repositories/plan_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/backup/backup_service.dart';
import '../domain/models/enums.dart';
import '../domain/models/vocabulary.dart';
import '../domain/plan_import/plan_importer.dart';
import '../domain/progression/progression_service.dart';

/// Which top-level destination the shell is showing.
///
/// Lives here rather than in `AppShell` because the drawer is built inside each
/// destination's own `Scaffold`, not the shell's, and so has no way to call back
/// up the widget tree.
class ShellDestination extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final shellDestinationProvider = NotifierProvider<ShellDestination, int>(
  ShellDestination.new,
);

/// The single application database.
///
/// Tests override this with an in-memory instance:
/// ```dart
/// ProviderContainer(overrides: [
///   databaseProvider.overrideWithValue(createTestDatabase()),
/// ]);
/// ```
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openAppDatabaseConnection());
  ref.onDispose(db.close);
  return db;
});

/// Overridden with a `FakeClock` in tests so anything time-dependent is
/// deterministic.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  );
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  );
});

final baselineRepositoryProvider = Provider<BaselineRepository>((ref) {
  return BaselineRepository(ref.watch(databaseProvider));
});

final personalRecordRepositoryProvider = Provider<PersonalRecordRepository>((
  ref,
) {
  return PersonalRecordRepository(ref.watch(databaseProvider));
});

/// Applies the static-vs-periodized progression rules after a session.
final progressionServiceProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(
    sessions: ref.watch(sessionRepositoryProvider),
    plans: ref.watch(planRepositoryProvider),
    baselines: ref.watch(baselineRepositoryProvider),
    records: ref.watch(personalRecordRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

/// Every plan, active one first.
final planListProvider = StreamProvider<List<PlanRow>>((ref) {
  return ref.watch(planRepositoryProvider).watchAll();
});

/// Days belonging to a plan, live so the editor updates as they are added.
final planDaysProvider = StreamProvider.family<List<PlanDayRow>, int>((
  ref,
  planId,
) {
  return ref.watch(planRepositoryProvider).watchDays(planId);
});

/// A day with its blocks and items, for the day editor.
///
/// Rebuilt whenever the plan's days change, which covers edits made to blocks
/// and items within this day too.
final planDayDetailProvider = FutureProvider.family<PlanDayDetail?, int>((
  ref,
  dayId,
) {
  ref.watch(planEditRevisionProvider);
  return ref.watch(planRepositoryProvider).loadDay(dayId);
});

/// Bumped after any structural edit so the day detail reloads.
///
/// Blocks and items have no stream of their own; a single revision counter is
/// simpler than watching four tables and cheaper than polling.
class PlanEditRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final planEditRevisionProvider = NotifierProvider<PlanEditRevision, int>(
  PlanEditRevision.new,
);

final planImporterProvider = Provider<PlanImporter>((ref) {
  return PlanImporter(
    db: ref.watch(databaseProvider),
    plans: ref.watch(planRepositoryProvider),
    exercises: ref.watch(exerciseRepositoryProvider),
    progression: ref.watch(progressionServiceProvider),
  );
});

/// The plan-file JSON Schema, loaded from assets.
///
/// Used by the "copy for AI" action so a user can paste the contract straight
/// into a chat tool and get back a plan this app accepts.
final planSchemaProvider = FutureProvider<String>((ref) {
  return rootBundle.loadString('assets/schema/exercise-plan.schema.json');
});

/// Populates the starter catalog on first launch. Awaited once at startup so
/// the exercise picker is never empty on a fresh install.
final catalogSeedProvider = FutureProvider<int>((ref) {
  return seedExercisesIfEmpty(ref.watch(databaseProvider));
});

/// The user's chosen unit system, kept live so a change in settings redraws
/// every weight and distance in the app at once.
final unitSystemProvider = StreamProvider<UnitSystem>((ref) {
  return ref.watch(settingsRepositoryProvider).watchUnitSystem();
});

/// Formats values for display. Falls back to metric until the setting loads,
/// which matches the stored default.
final unitFormatterProvider = Provider<UnitFormatter>((ref) {
  final system = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
  return UnitFormatter(system);
});

/// Rest used when a block does not prescribe its own.
final defaultRestSecondsProvider = FutureProvider<int>((ref) {
  return ref.watch(settingsRepositoryProvider).getDefaultRestSeconds();
});

/// A boolean setting, kept live so a toggle takes effect immediately.
final settingFlagProvider = StreamProvider.family<bool, String>((ref, key) {
  return ref.watch(settingsRepositoryProvider).watchFlag(key);
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  );
});

// --------------------------------------------------------------- catalog

/// What the catalog screen and the exercise picker are currently narrowed to.
///
/// A record rather than a class so the provider family keys on value equality
/// for free — two identical filters share one subscription.
typedef ExerciseFilter = ({
  ExerciseType? type,
  String? muscleGroup,
  String? equipment,
  bool includeArchived,
});

/// The unfiltered catalog: active exercises of every type.
const ExerciseFilter noExerciseFilter = (
  type: null,
  muscleGroup: null,
  equipment: null,
  includeArchived: false,
);

/// Live view of the exercise catalog under a filter.
final exerciseCatalogProvider =
    StreamProvider.family<List<ExerciseRow>, ExerciseFilter>((ref, filter) {
      return ref
          .watch(exerciseRepositoryProvider)
          .watchAll(
            type: filter.type,
            muscleGroup: filter.muscleGroup,
            equipment: filter.equipment,
            includeArchived: filter.includeArchived,
          );
    });

/// Muscle groups offered in the editor: the standard vocabulary plus anything
/// the catalog already uses, so an imported value stays selectable.
final muscleGroupOptionsProvider = Provider<List<String>>((ref) {
  final rows = ref.watch(allExercisesProvider).value ?? const <ExerciseRow>[];
  return mergeVocabulary(standardMuscleGroups, rows.map((e) => e.muscleGroup));
});

final equipmentOptionsProvider = Provider<List<String>>((ref) {
  final rows = ref.watch(allExercisesProvider).value ?? const <ExerciseRow>[];
  return mergeVocabulary(standardEquipment, rows.map((e) => e.equipment));
});

/// Only the values actually present in the catalog, for the filter dropdowns —
/// offering a filter that can only ever return nothing is a dead end.
final usedMuscleGroupsProvider = Provider<List<String>>((ref) {
  final rows = ref.watch(allExercisesProvider).value ?? const <ExerciseRow>[];
  return mergeVocabulary(const [], rows.map((e) => e.muscleGroup));
});

final usedEquipmentProvider = Provider<List<String>>((ref) {
  final rows = ref.watch(allExercisesProvider).value ?? const <ExerciseRow>[];
  return mergeVocabulary(const [], rows.map((e) => e.equipment));
});

// --------------------------------------------------------------- sessions

/// The workout currently in progress, if any.
final activeSessionProvider = StreamProvider<SessionRow?>((ref) {
  return ref.watch(sessionRepositoryProvider).watchActiveSession();
});

/// Sets logged in a given session, ordered for display.
final sessionStrengthSetsProvider =
    StreamProvider.family<List<StrengthSetRow>, int>((ref, sessionId) {
      return ref.watch(sessionRepositoryProvider).watchStrengthSets(sessionId);
    });

/// Cardio efforts logged in a given session.
final sessionCardioEntriesProvider =
    StreamProvider.family<List<CardioEntryRow>, int>((ref, sessionId) {
      return ref.watch(sessionRepositoryProvider).watchCardioEntries(sessionId);
    });

/// Which cardio entry the stopwatch is currently attached to. Null means the
/// timer is not in use.
///
/// Only one cardio effort can be timed at a time, so this is a single id rather
/// than per-entry state.
class TimedCardioEntry extends Notifier<int?> {
  @override
  int? build() => null;

  void attachTo(int entryId) => state = entryId;

  void clear() => state = null;
}

final timedCardioEntryProvider = NotifierProvider<TimedCardioEntry, int?>(
  TimedCardioEntry.new,
);

/// Completed sessions, newest first.
final sessionHistoryProvider = StreamProvider<List<SessionRow>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchHistory();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(databaseProvider));
});

/// Summarised history for the log list.
///
/// Depends on [sessionHistoryProvider] so finishing a workout refreshes it
/// without any manual invalidation.
final recentSessionsProvider = FutureProvider<List<SessionSummary>>((ref) {
  ref.watch(sessionHistoryProvider);
  return ref.watch(historyRepositoryProvider).recentSessions();
});

/// Exercises with at least one completed effort, for the progress picker.
final exercisesWithHistoryProvider = FutureProvider<List<ExerciseRow>>((ref) {
  ref.watch(sessionHistoryProvider);
  return ref.watch(historyRepositoryProvider).exercisesWithHistory();
});

/// Which metric a progress chart is showing.
enum ProgressMetric {
  topSetWeight('Top set'),
  estimatedOneRepMax('Est. 1RM'),
  distance('Distance'),
  pace('Pace');

  const ProgressMetric(this.label);

  final String label;
}

/// Chart data for one exercise and metric.
final progressChartProvider =
    FutureProvider.family<
      List<ProgressPoint>,
      ({int exerciseId, ProgressMetric metric})
    >((ref, args) {
      ref.watch(sessionHistoryProvider);
      final repo = ref.watch(historyRepositoryProvider);

      return switch (args.metric) {
        ProgressMetric.topSetWeight => repo.strengthProgress(args.exerciseId),
        ProgressMetric.estimatedOneRepMax => repo.estimatedOneRepMaxProgress(
          args.exerciseId,
        ),
        ProgressMetric.distance => repo.cardioDistanceProgress(args.exerciseId),
        ProgressMetric.pace => repo.cardioPaceProgress(args.exerciseId),
      };
    });

/// Personal records for one exercise, shown alongside its chart.
final personalRecordsProvider =
    FutureProvider.family<List<PersonalRecordRow>, int>((ref, exerciseId) {
      ref.watch(sessionHistoryProvider);
      return ref
          .watch(personalRecordRepositoryProvider)
          .forExercise(exerciseId);
    });

/// Every exercise, archived ones included.
///
/// History can reference an archived exercise, so the name lookup below must
/// see them or old workouts would render as "Unknown exercise".
final allExercisesProvider = StreamProvider<List<ExerciseRow>>((ref) {
  return ref.watch(exerciseRepositoryProvider).watchAll(includeArchived: true);
});

/// Exercise lookup by id, so logged rows can render a name without a join.
final exercisesByIdProvider = Provider<Map<int, ExerciseRow>>((ref) {
  final rows = ref.watch(allExercisesProvider).value ?? const <ExerciseRow>[];
  return {for (final row in rows) row.id: row};
});
