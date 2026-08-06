/// Regenerates every launcher icon from `lib/branding/baseline_logo.dart`.
///
/// This is a generator, not a test — it is kept out of `test/` so the normal
/// suite never rewrites binaries. Run it after changing the mark:
///
/// ```powershell
/// flutter test tool/generate_icons.dart
/// ```
///
/// It needs a Flutter engine to rasterize, which is why it runs under
/// `flutter test` rather than `dart run`.
library;

// This is a command-line generator; printing what it wrote is the point.
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:exercise_app/branding/baseline_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Android's launcher densities, as a multiplier of the 48dp baseline.
const Map<String, double> _densities = {
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

/// Sizes Windows expects inside an .ico. 256 is the one File Explorer shows at
/// its largest tile; 16 is the title bar.
const List<int> _icoSizes = [16, 32, 48, 64, 128, 256];

void main() {
  // A plain `test` rather than `testWidgets`: image encoding must not run
  // inside flutter_test's fake-async zone, where `toImage` never completes.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('regenerates the Android launcher icons', () async {
    for (final entry in _densities.entries) {
      final dir = Directory('android/app/src/main/res/mipmap-${entry.key}')
        ..createSync(recursive: true);

      // Legacy square icon, for launchers older than adaptive icons.
      final legacy = (48 * entry.value).round();
      await _writePng(
        File('${dir.path}/ic_launcher.png'),
        legacy,
        (canvas, size) => paintBaselineIcon(canvas, size),
      );

      // Adaptive foreground and background are 108dp each; the launcher masks
      // them to whatever shape the device uses.
      final adaptive = (108 * entry.value).round();
      await _writePng(
        File('${dir.path}/ic_launcher_foreground.png'),
        adaptive,
        paintBaselineAdaptiveForeground,
      );
    }

    print('Wrote launcher icons for ${_densities.length} densities');
  });

  test('regenerates the Windows .ico', () async {
    final images = <(int, Uint8List)>[];
    for (final size in _icoSizes) {
      // Windows applies its own rounding, so the icon is drawn square.
      images.add((
        size,
        await _pngBytes(size, (canvas, s) {
          paintBaselineIcon(canvas, s, cornerFraction: size >= 48 ? 0.16 : 0);
        }),
      ));
    }

    File(
      'windows/runner/resources/app_icon.ico',
    ).writeAsBytesSync(_buildIco(images));
    print('Wrote app_icon.ico with ${images.length} sizes');
  });

  test('regenerates the shareable logo', () async {
    final dir = Directory('assets/branding')..createSync(recursive: true);

    await _writePng(
      File('${dir.path}/baseline-icon-512.png'),
      512,
      (canvas, size) => paintBaselineIcon(canvas, size),
    );
    await _writePng(
      File('${dir.path}/baseline-mark-512.png'),
      512,
      (canvas, size) => paintBaselineMark(canvas, size),
    );

    print('Wrote assets/branding');
  });
}

Future<Uint8List> _pngBytes(
  int pixels,
  void Function(Canvas, Size) paint,
) async {
  final image = await renderBaselineImage(pixels, paint: paint);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('Failed to encode a ${pixels}px PNG');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

Future<void> _writePng(
  File file,
  int pixels,
  void Function(Canvas, Size) paint,
) async {
  file.writeAsBytesSync(await _pngBytes(pixels, paint));
}

/// Packs PNGs into an .ico container.
///
/// Windows Vista and later read PNG-compressed entries directly, so there is no
/// need to emit the legacy BMP-with-AND-mask form.
Uint8List _buildIco(List<(int size, Uint8List png)> images) {
  const headerSize = 6;
  const entrySize = 16;

  final builder = BytesBuilder();
  final header = ByteData(headerSize)
    ..setUint16(0, 0, Endian.little) // reserved
    ..setUint16(2, 1, Endian.little) // 1 = icon
    ..setUint16(4, images.length, Endian.little);
  builder.add(header.buffer.asUint8List());

  var offset = headerSize + entrySize * images.length;
  for (final (size, png) in images) {
    final entry = ByteData(entrySize)
      // 0 means 256: the field is a single byte.
      ..setUint8(0, size >= 256 ? 0 : size)
      ..setUint8(1, size >= 256 ? 0 : size)
      ..setUint8(2, 0) // palette size, 0 for truecolour
      ..setUint8(3, 0) // reserved
      ..setUint16(4, 1, Endian.little) // colour planes
      ..setUint16(6, 32, Endian.little) // bits per pixel
      ..setUint32(8, png.length, Endian.little)
      ..setUint32(12, offset, Endian.little);
    builder.add(entry.buffer.asUint8List());
    offset += png.length;
  }

  for (final (_, png) in images) {
    builder.add(png);
  }
  return builder.toBytes();
}
