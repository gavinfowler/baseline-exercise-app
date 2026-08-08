import 'package:exercise_app/app/providers.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/models/enums.dart';
import 'package:exercise_app/features/exercises/exercise_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/builders.dart';
import '../support/test_database.dart';

/// The catalog is one screen per exercise type, reached from two separate
/// destinations in the drawer. What is worth pinning down is that each screen
/// shows only its own type, and offers filters that make sense for it.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    // createTestDatabase registers its own close.
    db = createTestDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await insertExercise(db, name: 'Barbell Bench Press');
    await insertExercise(
      db,
      name: 'Easy Run',
      type: ExerciseType.cardio,
      cardioActivity: CardioActivity.run,
    );
  });

  /// Pumps until the catalog stream has delivered its first list.
  ///
  /// `pumpAndSettle` cannot be used: until the stream emits, the screen shows a
  /// `CircularProgressIndicator`, which never stops animating.
  Future<void> pumpCatalog(WidgetTester tester, ExerciseType type) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          // Material 3's InkSparkle needs a fragment shader the widget-test
          // environment cannot compile.
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: ExerciseCatalogScreen(type: type),
        ),
      ),
    );

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
    }
    fail('the catalog never loaded');
  }

  testWidgets('the strength screen lists only strength exercises', (
    tester,
  ) async {
    await pumpCatalog(tester, ExerciseType.strength);

    expect(find.widgetWithText(AppBar, 'Strength'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Easy Run'), findsNothing);
  });

  testWidgets('the cardio screen lists only cardio exercises', (tester) async {
    await pumpCatalog(tester, ExerciseType.cardio);

    expect(find.widgetWithText(AppBar, 'Cardio'), findsOneWidget);
    expect(find.text('Easy Run'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);
  });

  /// A run has no muscle group and a bench press has no activity, so offering
  /// both on both screens would leave half the filter row permanently dead.
  testWidgets('each screen offers the filter that suits its type', (
    tester,
  ) async {
    await pumpCatalog(tester, ExerciseType.strength);
    expect(find.text('Muscle group'), findsOneWidget);
    expect(find.text('Activity'), findsNothing);

    await pumpCatalog(tester, ExerciseType.cardio);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Muscle group'), findsNothing);
  });

  /// Adding from the cardio screen must not start out as a strength movement:
  /// saving it that way would file it under the screen the user is not on.
  testWidgets('the new-exercise button preselects the screen\'s type', (
    tester,
  ) async {
    await pumpCatalog(tester, ExerciseType.cardio);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'New'));
    await tester.pumpAndSettle();

    final segmented = tester.widget<SegmentedButton<ExerciseType>>(
      find.byType(SegmentedButton<ExerciseType>),
    );
    expect(segmented.selected, {ExerciseType.cardio});
    // The activity dropdown only renders for cardio, so its presence is the
    // second half of the same claim.
    expect(find.text('Activity'), findsWidgets);
  });
}
