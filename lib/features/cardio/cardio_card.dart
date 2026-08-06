import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/cardio_fields.dart';
import '../../domain/models/enums.dart';
import 'cardio_entry_sheet.dart';
import 'cardio_timer_controller.dart';

/// One cardio effort inside a workout: log it manually, or run the stopwatch.
class CardioCard extends ConsumerWidget {
  const CardioCard({required this.entry, super.key});

  final CardioEntryRow entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exercisesByIdProvider)[entry.exerciseId];
    final formatter = ref.watch(unitFormatterProvider);
    final timedEntryId = ref.watch(timedCardioEntryProvider);
    final isTiming = timedEntryId == entry.id;

    final name = exercise?.name ?? 'Cardio';
    final done = entry.status == EntryStatus.completed;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_run, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (isTiming) {
                      ref.read(timedCardioEntryProvider.notifier).clear();
                      ref.read(cardioTimerProvider.notifier).reset();
                    }
                    ref
                        .read(sessionRepositoryProvider)
                        .deleteCardioEntry(entry.id);
                  },
                ),
              ],
            ),
            if (done)
              _CardioSummary(
                entry: entry,
                formatter: formatter,
                activity: exercise?.cardioActivity,
              )
            else if (!isTiming)
              Text(
                entry.status == EntryStatus.skipped ? 'Skipped' : 'Not logged',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

            if (isTiming) _CardioStopwatch(entry: entry, exerciseName: name),

            const SizedBox(height: 4),
            Row(
              children: [
                if (!isTiming)
                  TextButton.icon(
                    onPressed: () => _startTimer(ref),
                    icon: const Icon(Icons.timer_outlined, size: 18),
                    label: const Text('Timer'),
                  ),
                TextButton.icon(
                  onPressed: () => _logManually(
                    context,
                    ref,
                    name,
                    exercise?.cardioActivity,
                    formatter,
                  ),
                  icon: Icon(
                    done ? Icons.edit_outlined : Icons.check,
                    size: 18,
                  ),
                  label: Text(done ? 'Edit' : 'Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer(WidgetRef ref) {
    ref.read(cardioTimerProvider.notifier).reset();
    ref.read(timedCardioEntryProvider.notifier).attachTo(entry.id);
    ref.read(cardioTimerProvider.notifier).start();
  }

  Future<void> _logManually(
    BuildContext context,
    WidgetRef ref,
    String name,
    CardioActivity? activity,
    UnitFormatter formatter,
  ) async {
    final repo = ref.read(sessionRepositoryProvider);

    var duration = entry.actualDurationSeconds ?? entry.plannedDurationSeconds;
    var distance = entry.actualDistanceMeters ?? entry.plannedDistanceMeters;
    if (duration == null && distance == null) {
      final previous = await repo.lastCompletedCardio(entry.exerciseId);
      duration ??= previous?.actualDurationSeconds;
      distance ??= previous?.actualDistanceMeters;
    }
    if (!context.mounted) return;

    final result = await showCardioEntrySheet(
      context,
      exerciseName: name,
      activity: activity,
      formatter: formatter,
      initialDurationSeconds: duration,
      initialDistance: distance == null
          ? null
          : formatter.distanceValue(distance),
    );
    if (result == null) return;

    await repo.completeCardioEntry(
      entry.id,
      durationSeconds: result.durationSeconds,
      distanceMeters: result.distance == null
          ? null
          : formatter.distanceToMeters(result.distance!),
      inclinePercent: result.inclinePercent,
      resistanceLevel: result.resistanceLevel,
      avgHeartRate: result.avgHeartRate,
      maxHeartRate: result.maxHeartRate,
      calories: result.calories,
      elevationGainMeters: result.elevationGain,
      notes: result.notes,
    );
  }
}

/// Read-out for a completed effort.
class _CardioSummary extends StatelessWidget {
  const _CardioSummary({
    required this.entry,
    required this.formatter,
    required this.activity,
  });

  final CardioEntryRow entry;
  final UnitFormatter formatter;
  final CardioActivity? activity;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      UnitFormatter.formatDuration(entry.actualDurationSeconds ?? 0),
      if (entry.actualDistanceMeters != null)
        formatter.formatDistance(entry.actualDistanceMeters!),
      if (entry.actualPaceSecPerKm != null && activityHasPace(activity))
        formatter.formatPace(entry.actualPaceSecPerKm!),
    ];

    final extras = <String>[
      if (entry.inclinePercent != null) '${entry.inclinePercent}% incline',
      if (entry.resistanceLevel != null) 'level ${entry.resistanceLevel}',
      if (entry.avgHeartRate != null) '${entry.avgHeartRate} bpm avg',
      if (entry.calories != null) '${entry.calories} cal',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parts.join('  ·  '), style: Theme.of(context).textTheme.bodyLarge),
        if (extras.isNotEmpty)
          Text(
            extras.join('  ·  '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// The running stopwatch, shown inline while this entry is being timed.
class _CardioStopwatch extends ConsumerWidget {
  const _CardioStopwatch({required this.entry, required this.exerciseName});

  final CardioEntryRow entry;
  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardioTimerProvider);
    final controller = ref.read(cardioTimerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UnitFormatter.formatDuration(state.elapsedSeconds),
          style: theme.textTheme.displaySmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (state.laps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              state.laps
                  .map(
                    (l) =>
                        'Lap ${l.index + 1}: '
                        '${UnitFormatter.formatDuration(l.durationSeconds)}',
                  )
                  .join('   '),
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            if (state.isRunning)
              TextButton.icon(
                onPressed: controller.pause,
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Pause'),
              )
            else if (state.isPaused)
              TextButton.icon(
                onPressed: controller.resume,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Resume'),
              ),
            TextButton.icon(
              onPressed: controller.lap,
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('Lap'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _finish(context, ref),
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('Stop & log'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(cardioTimerProvider.notifier);
    controller.stop();

    final state = ref.read(cardioTimerProvider);
    final formatter = ref.read(unitFormatterProvider);
    final activity = ref
        .read(exercisesByIdProvider)[entry.exerciseId]
        ?.cardioActivity;

    final result = await showCardioEntrySheet(
      context,
      exerciseName: exerciseName,
      activity: activity,
      formatter: formatter,
      initialDurationSeconds: state.elapsedSeconds,
    );

    // Cancelling the sheet leaves the stopwatch stopped but intact, so nothing
    // is lost and the user can reopen it.
    if (result == null) return;

    final repo = ref.read(sessionRepositoryProvider);
    await repo.completeCardioEntry(
      entry.id,
      durationSeconds: result.durationSeconds,
      distanceMeters: result.distance == null
          ? null
          : formatter.distanceToMeters(result.distance!),
      inclinePercent: result.inclinePercent,
      resistanceLevel: result.resistanceLevel,
      avgHeartRate: result.avgHeartRate,
      maxHeartRate: result.maxHeartRate,
      calories: result.calories,
      elevationGainMeters: result.elevationGain,
      notes: result.notes,
    );

    if (state.laps.isNotEmpty) {
      await repo.replaceSplits(entry.id, [
        for (final lap in state.laps)
          (durationSeconds: lap.durationSeconds, distanceMeters: null),
      ]);
    }

    ref.read(timedCardioEntryProvider.notifier).clear();
    controller.reset();
  }
}
