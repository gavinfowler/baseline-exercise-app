import 'package:exercise_app/app/providers.dart';
import 'package:exercise_app/features/shell/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget coverage for the navigation drawer.
///
/// The drawer reads and writes nothing but [shellDestinationProvider], so it
/// needs no database.
void main() {
  late ProviderContainer container;

  Future<void> pumpDrawer(WidgetTester tester) async {
    container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          // Material 3's default InkSparkle loads a fragment shader that the
          // widget-test environment cannot compile, which fails the first test
          // to tap anything. The ripple is visually equivalent here and needs
          // no shader.
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Scaffold(
            // The AppBar is what renders the hamburger; a Scaffold with a
            // drawer but no bar has nothing to tap. Every real destination has
            // one.
            // Title deliberately matches no destination label, so `find.text`
            // below is never ambiguous between the bar and the drawer.
            appBar: AppBar(title: const Text('Screen')),
            drawer: const AppDrawer(),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    // Open it: the hamburger only exists because the Scaffold has a drawer.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  }

  int selected() => container.read(shellDestinationProvider);

  testWidgets('opens from the hamburger and lists every destination', (
    tester,
  ) async {
    await pumpDrawer(tester);

    for (final label in [
      'Workout',
      'Plans',
      'Exercises',
      'History',
      'Settings',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Baseline'), findsOneWidget);
  });

  testWidgets('starts on Workout', (tester) async {
    await pumpDrawer(tester);

    expect(selected(), 0);
  });

  testWidgets('choosing a destination selects it and closes the drawer', (
    tester,
  ) async {
    await pumpDrawer(tester);

    await tester.tap(find.text('Exercises'));
    await tester.pumpAndSettle();

    expect(selected(), 2);
    expect(find.text('Baseline'), findsNothing);
  });

  /// The `Divider` above Settings is not a `NavigationDrawerDestination`, so it
  /// must not consume an index. If it ever did, Settings would select History's
  /// screen — the kind of off-by-one that is invisible until someone taps it.
  testWidgets('the divider does not shift the Settings index', (tester) async {
    await pumpDrawer(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(selected(), 4);
  });

  testWidgets('each destination maps to its own index', (tester) async {
    const expected = {
      'Workout': 0,
      'Plans': 1,
      'Exercises': 2,
      'History': 3,
      'Settings': 4,
    };

    for (final entry in expected.entries) {
      await pumpDrawer(tester);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(selected(), entry.value, reason: 'for ${entry.key}');
    }
  });
}
