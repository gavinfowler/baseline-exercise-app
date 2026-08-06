import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/units/unit_system.dart';
import '../../data/repositories/history_repository.dart';
import '../ads/ad_slot.dart';
import '../progress/progress_view.dart';

/// Past workouts, and progress charts, as two tabs.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Log'),
              Tab(text: 'Progress'),
            ],
          ),
        ),
        body: const Column(
          children: [
            Expanded(
              child: TabBarView(children: [_SessionLog(), ProgressView()]),
            ),
            AdSlot(),
          ],
        ),
      ),
    );
  }
}

class _SessionLog extends ConsumerWidget {
  const _SessionLog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(recentSessionsProvider);

    return sessions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No completed workouts yet.\n'
                'Finish a session and it will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) => _SessionCard(summary: rows[i]),
        );
      },
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    final theme = Theme.of(context);
    final session = summary.session;

    // Stored timestamps are UTC; history is about the user's own day.
    final started = session.startedAt.toLocal();
    final dateLabel = DateFormat('EEE d MMM y').format(started);
    final timeLabel = DateFormat.jm().format(started);

    final stats = <String>[
      if (session.durationSeconds != null)
        UnitFormatter.formatDuration(session.durationSeconds!),
      if (summary.strengthSetCount > 0)
        '${summary.strengthSetCount} set'
            '${summary.strengthSetCount == 1 ? '' : 's'}',
      if (summary.cardioCount > 0) '${summary.cardioCount} cardio',
      if (summary.totalVolumeKg > 0)
        '${formatter.formatWeight(summary.totalVolumeKg)} volume',
    ];

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title ?? dateLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(timeLabel, style: theme.textTheme.labelSmall),
              ],
            ),
            if (session.title != null)
              Text(dateLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(stats.join('  ·  '), style: theme.textTheme.bodySmall),
            if (summary.exerciseNames.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                summary.exerciseNames.join(', '),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (session.notes != null) ...[
              const SizedBox(height: 6),
              Text(session.notes!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
