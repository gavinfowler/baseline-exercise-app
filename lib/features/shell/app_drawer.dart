import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../branding/baseline_logo.dart';

/// The top-level navigation menu, opened by the hamburger button.
///
/// Every destination's `Scaffold` builds its own instance — that is what puts
/// the hamburger in its `AppBar` — so the selection itself lives in
/// [shellDestinationProvider] rather than in this widget.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  /// Index into [AppShell]'s `IndexedStack`, in the order shown here.
  ///
  /// The `Divider` below is not a destination, so it does not occupy an index:
  /// `NavigationDrawer` numbers only its `NavigationDrawerDestination`
  /// children. Settings is 5 despite being the seventh child.
  static const _destinations = [
    (
      icon: Icon(Icons.play_circle_outline),
      selected: Icon(Icons.play_circle),
      label: 'Workout',
    ),
    (
      icon: Icon(Icons.calendar_month_outlined),
      selected: Icon(Icons.calendar_month),
      label: 'Plans',
    ),
    (
      icon: Icon(Icons.fitness_center_outlined),
      selected: Icon(Icons.fitness_center),
      label: 'Strength',
    ),
    (
      icon: Icon(Icons.directions_run_outlined),
      selected: Icon(Icons.directions_run),
      label: 'Cardio',
    ),
    (
      icon: Icon(Icons.history_outlined),
      selected: Icon(Icons.history),
      label: 'History',
    ),
    (
      icon: Icon(Icons.settings_outlined),
      selected: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(shellDestinationProvider);
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: current,
      onDestinationSelected: (index) {
        Navigator.of(context).pop();
        ref.read(shellDestinationProvider.notifier).select(index);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
          child: Row(
            children: [
              const BaselineLogo(size: 40),
              const SizedBox(width: 12),
              Text('Baseline', style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        for (final destination in _destinations.take(_destinations.length - 1))
          NavigationDrawerDestination(
            icon: destination.icon,
            selectedIcon: destination.selected,
            label: Text(destination.label),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
          child: Divider(),
        ),
        NavigationDrawerDestination(
          icon: _destinations.last.icon,
          selectedIcon: _destinations.last.selected,
          label: Text(_destinations.last.label),
        ),
      ],
    );
  }
}
