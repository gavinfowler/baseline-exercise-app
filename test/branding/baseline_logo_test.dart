import 'dart:io';

import 'package:exercise_app/branding/baseline_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the logo widget', () {
    testWidgets('renders at any size without overflowing', (tester) async {
      for (final size in const [16.0, 48.0, 512.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: BaselineLogo(size: size)),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: 'failed at $size');
        expect(tester.getSize(find.byType(BaselineLogo)), Size.square(size));
      }
    });

    testWidgets('draws the mark alone when the background is off', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BaselineLogo(showBackground: false, color: Colors.white),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('generated assets', () {
    // These are checked in, so a fresh clone builds with the right icon without
    // anyone having to run the generator first.
    for (final path in const [
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
      'android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png',
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png',
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      'windows/runner/resources/app_icon.ico',
      'assets/branding/baseline-icon-512.png',
    ]) {
      test('$path exists and is non-empty', () {
        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'run tool/generate_icons.dart',
        );
        expect(file.lengthSync(), greaterThan(0));
      });
    }

    test('the .ico announces the sizes it actually contains', () {
      final bytes = File(
        'windows/runner/resources/app_icon.ico',
      ).readAsBytesSync();

      // ICONDIR: reserved(2) = 0, type(2) = 1 for an icon, count(2).
      expect(bytes[0] | bytes[1], 0);
      expect(bytes[2] | (bytes[3] << 8), 1);

      final count = bytes[4] | (bytes[5] << 8);
      expect(count, greaterThanOrEqualTo(4));

      // Every entry must point at a real slice of the file, or Explorer shows
      // a blank icon rather than an error.
      for (var i = 0; i < count; i++) {
        final entry = 6 + i * 16;
        final length =
            bytes[entry + 8] |
            (bytes[entry + 9] << 8) |
            (bytes[entry + 10] << 16) |
            (bytes[entry + 11] << 24);
        final offset =
            bytes[entry + 12] |
            (bytes[entry + 13] << 8) |
            (bytes[entry + 14] << 16) |
            (bytes[entry + 15] << 24);

        expect(offset + length, lessThanOrEqualTo(bytes.length));
        // Each entry is a PNG, which Windows has read inside .ico since Vista.
        expect(bytes.sublist(offset, offset + 8), [
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
        ]);
      }
    });
  });

  test('the Android adaptive background matches the brand colour', () {
    // The colour is duplicated into Android XML because a resource file cannot
    // read a Dart constant. This is the guard against the two drifting.
    final xml = File(
      'android/app/src/main/res/values/ic_launcher_background.xml',
    ).readAsStringSync();

    final hex = RegExp(r'#([0-9A-Fa-f]{6})').firstMatch(xml)?.group(1);
    expect(hex, isNotNull, reason: 'no colour found in ic_launcher_background');

    final expected = BaselineBrand.background.toARGB32() & 0xFFFFFF;
    expect(int.parse(hex!, radix: 16), expected);
  });
}
