import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/units/unit_system.dart';
import 'rest_timer_controller.dart';

/// The rest countdown, shown above the bottom of the workout screen.
///
/// Collapses to nothing when idle so it costs no space between sets.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(restTimerProvider);
    if (!state.isActive) return const SizedBox.shrink();

    final controller = ref.read(restTimerProvider.notifier);
    final theme = Theme.of(context);
    final finished = state.isFinished;

    final background = finished
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.secondaryContainer;
    final foreground = finished
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Material(
      color: background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 3,
            backgroundColor: background,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Icon(
                  finished ? Icons.notifications_active : Icons.timer_outlined,
                  color: foreground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        finished
                            ? 'Rest complete'
                            : UnitFormatter.formatDuration(
                                state.remainingSeconds,
                              ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: foreground,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (state.label != null)
                        Text(
                          'Next: ${state.label}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foreground,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!finished) ...[
                  TextButton(
                    onPressed: () => controller.adjust(-15),
                    child: const Text('-15s'),
                  ),
                  TextButton(
                    onPressed: () => controller.adjust(30),
                    child: const Text('+30s'),
                  ),
                  IconButton(
                    tooltip: state.isPaused ? 'Resume' : 'Pause',
                    icon: Icon(
                      state.isPaused ? Icons.play_arrow : Icons.pause,
                      color: foreground,
                    ),
                    onPressed: state.isPaused
                        ? controller.resume
                        : controller.pause,
                  ),
                ],
                IconButton(
                  tooltip: finished ? 'Dismiss' : 'Skip rest',
                  icon: Icon(Icons.close, color: foreground),
                  onPressed: controller.stop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
