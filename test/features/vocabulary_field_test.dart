import 'package:exercise_app/features/exercises/vocabulary_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A DB-free widget, so it belongs in `test/` rather than `integration_test/`.
void main() {
  const options = ['Barbell', 'Dumbbell', 'Cable'];

  /// Pumps the field and returns a sink holding the latest reported value.
  Future<List<String?>> pumpField(WidgetTester tester, {String? value}) async {
    final reported = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VocabularyField(
            label: 'Equipment',
            options: options,
            value: value,
            onChanged: reported.add,
          ),
        ),
      ),
    );
    return reported;
  }

  Future<void> choose(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('offers the vocabulary, a blank, and an escape hatch', (
    tester,
  ) async {
    await pumpField(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();

    for (final option in options) {
      expect(find.text(option), findsWidgets, reason: 'missing $option');
    }
    expect(find.text('Not set'), findsWidgets);
    expect(find.text('Other…'), findsWidgets);
  });

  testWidgets('reports a chosen vocabulary entry', (tester) async {
    final reported = await pumpField(tester);
    await choose(tester, 'Dumbbell');

    expect(reported, ['Dumbbell']);
  });

  testWidgets('choosing Other reveals a text field and reports what is typed', (
    tester,
  ) async {
    final reported = await pumpField(tester);

    expect(find.byType(TextField), findsNothing);
    await choose(tester, 'Other…');
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sandbag');
    await tester.pump();

    expect(reported.last, 'Sandbag');
  });

  testWidgets('an empty custom entry reports null rather than a blank', (
    tester,
  ) async {
    final reported = await pumpField(tester);
    await choose(tester, 'Other…');
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    expect(reported.last, isNull);
  });

  testWidgets('an existing value selects its vocabulary entry', (tester) async {
    await pumpField(tester, value: 'Cable');

    expect(find.text('Cable'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('matches an existing value case-insensitively', (tester) async {
    // An imported plan may have written "cable"; that must not push the field
    // into custom mode and offer a second spelling of a value we already know.
    await pumpField(tester, value: 'cable');

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Cable'), findsOneWidget);
  });

  testWidgets('an unrecognised value opens in custom mode, prefilled', (
    tester,
  ) async {
    await pumpField(tester, value: 'Sandbag');

    expect(find.text('Other…'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Sandbag'), findsOneWidget);
  });

  testWidgets('clearing back to Not set reports null', (tester) async {
    final reported = await pumpField(tester, value: 'Cable');
    await choose(tester, 'Not set');

    expect(reported.last, isNull);
  });
}
