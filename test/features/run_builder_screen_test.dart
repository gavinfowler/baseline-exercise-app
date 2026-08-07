import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/domain/models/run_segment.dart';
import 'package:exercise_app/features/plans/run_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers segment reordering, which had no test of its own while it was doing
/// its own off-by-one correction against the old `onReorder` contract.
void main() {
  const metric = UnitFormatter(UnitSystem.metric);

  RunWorkout threeSegments() => const RunWorkout([
    RunSegment(
      label: 'Warm-up',
      work: RunEffort(durationSeconds: 600, paceSecPerKm: 390),
    ),
    RunSegment(
      label: 'Repeats',
      repeat: 6,
      work: RunEffort(distanceMeters: 800, paceSecPerKm: 250),
    ),
    RunSegment(
      label: 'Cool-down',
      work: RunEffort(durationSeconds: 600, paceSecPerKm: 400),
    ),
  ]);

  Future<List<RunWorkout?>> open(
    WidgetTester tester,
    RunWorkout initial,
  ) async {
    final saved = <RunWorkout?>[];

    await tester.pumpWidget(
      MaterialApp(
        // Material 3's InkSparkle needs a fragment shader the widget-test
        // environment cannot compile.
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async => saved.add(
                await showRunBuilder(
                  context,
                  initial: initial,
                  formatter: metric,
                  exerciseName: 'Outdoor Run',
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return saved;
  }

  /// Drags the handle at [from] far enough to land on [to].
  Future<void> dragSegment(WidgetTester tester, int from, int to) async {
    final handles = find.byIcon(Icons.drag_handle);
    expect(handles, findsWidgets, reason: 'no drag handles to grab');

    final start = tester.getCenter(handles.at(from));
    // Landing exactly on the target's centre sits right on the boundary the
    // list uses to decide it has been passed, so overshoot in the direction of
    // travel.
    final overshoot = to > from ? 24.0 : -24.0;
    final end = tester.getCenter(handles.at(to)) + Offset(0, overshoot);

    final gesture = await tester.startGesture(start);
    // Long enough to arm the delayed drag listener the default handles use on
    // mobile. An immediate listener does not mind the pause.
    await tester.pump(const Duration(milliseconds: 700));
    // Moved in steps: a single jump can outrun the reorder animation.
    for (var step = 1; step <= 4; step++) {
      await gesture.moveTo(Offset.lerp(start, end, step / 4)!);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the segments in order', (tester) async {
    await open(tester, threeSegments());

    expect(find.text('Warm-up'), findsOneWidget);
    expect(find.text('Repeats'), findsOneWidget);
    expect(find.text('Cool-down'), findsOneWidget);
  });

  testWidgets('saves the segments unchanged when nothing is moved', (
    tester,
  ) async {
    final saved = await open(tester, threeSegments());

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved.single!.segments.map((s) => s.label), [
      'Warm-up',
      'Repeats',
      'Cool-down',
    ]);
  });

  testWidgets('dragging a segment down moves it past the one below', (
    tester,
  ) async {
    // The case the old manual `newIndex - 1` correction existed for. Dragging
    // downwards is where an off-by-one shows up: upwards happens to work either
    // way.
    final saved = await open(tester, threeSegments());

    await dragSegment(tester, 0, 1);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved.single!.segments.map((s) => s.label), [
      'Repeats',
      'Warm-up',
      'Cool-down',
    ]);
  });

  testWidgets('dragging a segment up moves it above the one before', (
    tester,
  ) async {
    final saved = await open(tester, threeSegments());

    await dragSegment(tester, 2, 0);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved.single!.segments.map((s) => s.label), [
      'Cool-down',
      'Warm-up',
      'Repeats',
    ]);
  });
}
