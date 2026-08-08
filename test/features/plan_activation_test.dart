import 'package:exercise_app/app/providers.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/plan_repository.dart';
import 'package:exercise_app/features/plans/plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/test_database.dart';

/// Activating a plan was a one-way door: the active plan rendered as a plain
/// Chip, so the only ways back were activating a different plan or deleting it.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late PlanRepository plans;

  setUp(() {
    // createTestDatabase registers its own close.
    db = createTestDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    plans = container.read(planRepositoryProvider);
    addTearDown(container.dispose);
  });

  /// Pumps until the plan list has arrived.
  ///
  /// `pumpAndSettle` cannot be used to get here: the list is a stream, and until
  /// it emits the screen shows a `CircularProgressIndicator`, which never stops
  /// animating and so never settles.
  Future<void> pumpPlans(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          // Material 3's InkSparkle needs a fragment shader the widget-test
          // environment cannot compile.
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: const PlansScreen(),
        ),
      ),
    );

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
    }
    fail('the plan list never loaded');
  }

  /// Taps and then lets the list stream deliver the result of the write.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('an inactive plan offers Activate', (tester) async {
    await insertPlan(db, name: 'Upper/Lower');
    await pumpPlans(tester);

    expect(find.text('Activate'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
  });

  testWidgets('activating swaps the button for the Active chip', (
    tester,
  ) async {
    await insertPlan(db, name: 'Upper/Lower');
    await pumpPlans(tester);

    await tapAndSettle(tester, find.text('Activate'));

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Activate'), findsNothing);
    expect((await plans.getActivePlan())!.name, 'Upper/Lower');
  });

  testWidgets('the Active chip carries a deactivate control', (tester) async {
    final id = await insertPlan(db, name: 'Upper/Lower');
    await plans.setActivePlan(id);
    await pumpPlans(tester);

    expect(find.byTooltip('Deactivate'), findsOneWidget);
  });

  testWidgets('deactivating clears the active plan', (tester) async {
    final id = await insertPlan(db, name: 'Upper/Lower');
    await plans.setActivePlan(id);
    await pumpPlans(tester);

    await tapAndSettle(tester, find.byTooltip('Deactivate'));

    expect(await plans.getActivePlan(), isNull);
    // And the row goes back to offering activation, so it is not a dead end in
    // the other direction either.
    expect(find.text('Activate'), findsOneWidget);
  });

  testWidgets('deactivating one plan leaves the others alone', (tester) async {
    final first = await insertPlan(db, name: 'Upper/Lower');
    await insertPlan(db, name: 'Couch to 5k');
    await plans.setActivePlan(first);
    await pumpPlans(tester);

    await tapAndSettle(tester, find.byTooltip('Deactivate'));

    expect(await plans.getAll(), hasLength(2));
    expect(find.text('Activate'), findsNWidgets(2));
  });
}
