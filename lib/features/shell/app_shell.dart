import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../exercises/exercise_catalog_screen.dart';
import '../history/history_screen.dart';
import '../plans/plans_screen.dart';
import '../session/workout_screen.dart';
import '../settings/settings_screen.dart';

/// Top-level navigation.
///
/// Each destination keeps its own `Scaffold`, and each one carries an
/// [AppDrawer]. That is deliberate: hoisting them into a single shell `AppBar`
/// would cost the per-screen actions, the floating action buttons, and
/// History's tab bar. This widget only decides which one is on screen.
///
/// The stack order here is the index order in [AppDrawer].
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensures the starter catalog exists before the picker is ever opened.
    ref.watch(catalogSeedProvider);

    return IndexedStack(
      index: ref.watch(shellDestinationProvider),
      children: const [
        WorkoutScreen(),
        PlansScreen(),
        ExerciseCatalogScreen(),
        HistoryScreen(),
        SettingsScreen(),
      ],
    );
  }
}
