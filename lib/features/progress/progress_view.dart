import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/units/unit_system.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/history_repository.dart';
import '../../domain/models/enums.dart';

/// Per-exercise progress: pick an exercise and a metric, see it over time.
class ProgressView extends ConsumerStatefulWidget {
  const ProgressView({super.key});

  @override
  ConsumerState<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends ConsumerState<ProgressView> {
  int? _exerciseId;
  ProgressMetric? _metric;

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesWithHistoryProvider);

    return exercises.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nothing to chart yet.\n'
                'Log a few workouts and your progress appears here.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final selected = rows.firstWhere(
          (e) => e.id == _exerciseId,
          orElse: () => rows.first,
        );
        final metrics = _metricsFor(selected);
        final metric = metrics.contains(_metric) ? _metric! : metrics.first;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: selected.id,
              decoration: const InputDecoration(
                labelText: 'Exercise',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final exercise in rows)
                  DropdownMenuItem(
                    value: exercise.id,
                    child: Text(exercise.name),
                  ),
              ],
              onChanged: (value) => setState(() {
                _exerciseId = value;
                // The old metric may not apply to the new exercise.
                _metric = null;
              }),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final option in metrics)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: option == metric,
                    onSelected: (_) => setState(() => _metric = option),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _Chart(exercise: selected, metric: metric),
            const SizedBox(height: 24),
            _Records(exerciseId: selected.id),
          ],
        );
      },
    );
  }

  /// Strength and cardio have nothing useful in common to chart, so the metric
  /// options follow the exercise type.
  List<ProgressMetric> _metricsFor(ExerciseRow exercise) {
    return exercise.type == ExerciseType.cardio
        ? const [ProgressMetric.distance, ProgressMetric.pace]
        : const [
            ProgressMetric.topSetWeight,
            ProgressMetric.estimatedOneRepMax,
          ];
  }
}

class _Chart extends ConsumerWidget {
  const _Chart({required this.exercise, required this.metric});

  final ExerciseRow exercise;
  final ProgressMetric metric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      progressChartProvider((exerciseId: exercise.id, metric: metric)),
    );
    final formatter = ref.watch(unitFormatterProvider);

    return SizedBox(
      height: 260,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (points) {
          if (points.length < 2) {
            return Center(
              child: Text(
                points.isEmpty
                    ? 'No data for this metric yet.'
                    : 'One session so far — a trend needs at least two.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return _LineChart(
            points: points,
            metric: metric,
            formatter: formatter,
          );
        },
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.points,
    required this.metric,
    required this.formatter,
  });

  final List<ProgressPoint> points;
  final ProgressMetric metric;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // X is days since the first point, so gaps between sessions show as gaps
    // rather than being evenly spaced.
    final origin = points.first.date;
    final spots = [
      for (final point in points)
        FlSpot(
          point.date.difference(origin).inDays.toDouble(),
          _display(point.value),
        ),
    ];

    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    // A flat series would otherwise collapse to a zero-height axis.
    final padding = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY) * 0.15;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: theme.dividerColor, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) =>
                  Text(_axisLabel(value), style: theme.textTheme.labelSmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _dateInterval(spots.last.x),
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat(
                    'd MMM',
                  ).format(origin.add(Duration(days: value.round()))),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${_axisLabel(spot.y)}\n'
                  '${DateFormat('d MMM y').format(origin.add(Duration(days: spot.x.round())))}',
                  theme.textTheme.bodySmall ?? const TextStyle(),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2.5,
            color: theme.colorScheme.primary,
            dotData: const FlDotData(),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  /// Converts the stored canonical value into the user's display unit.
  double _display(double raw) => switch (metric) {
    ProgressMetric.topSetWeight ||
    ProgressMetric.estimatedOneRepMax => formatter.weightValue(raw),
    ProgressMetric.distance => formatter.distanceValue(raw),
    // Pace stays in seconds; the axis formats it as m:ss.
    ProgressMetric.pace => raw,
  };

  String _axisLabel(double value) => switch (metric) {
    ProgressMetric.topSetWeight || ProgressMetric.estimatedOneRepMax =>
      '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} '
          '${formatter.weightSuffix}',
    ProgressMetric.distance =>
      '${value.toStringAsFixed(1)} ${formatter.distanceSuffix}',
    ProgressMetric.pace => formatter.formatPace(value, withSuffix: false),
  };

  /// Keeps the date axis from crowding on a long history.
  double _dateInterval(double spanDays) =>
      spanDays <= 0 ? 1 : (spanDays / 4).ceilToDouble();
}

class _Records extends ConsumerWidget {
  const _Records({required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(personalRecordsProvider(exerciseId));
    final formatter = ref.watch(unitFormatterProvider);
    final theme = Theme.of(context);

    return records.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal records', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final record in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_label(record), style: theme.textTheme.bodyMedium),
                        Text(
                          _value(record, formatter),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _label(PersonalRecordRow record) => switch (record.recordType) {
    RecordType.maxWeightAtReps => 'Heaviest × ${record.reps}',
    RecordType.maxWeight => 'Heaviest ever',
    RecordType.estimatedOneRepMax => 'Estimated 1RM',
    RecordType.bestPace => 'Best pace',
    RecordType.longestDistance => 'Longest distance',
    RecordType.longestDuration => 'Longest duration',
  };

  String _value(PersonalRecordRow record, UnitFormatter formatter) =>
      switch (record.recordType) {
        RecordType.maxWeightAtReps ||
        RecordType.maxWeight ||
        RecordType.estimatedOneRepMax => formatter.formatWeight(record.value),
        RecordType.bestPace => formatter.formatPace(record.value),
        RecordType.longestDistance => formatter.formatDistance(record.value),
        RecordType.longestDuration => UnitFormatter.formatDuration(
          record.value.round(),
        ),
      };
}
