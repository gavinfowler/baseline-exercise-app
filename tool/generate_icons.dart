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
import 'package:flutter/services.dart' show FontLoader;
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

  test('regenerates the Play Store feature graphic', () async {
    Directory('assets/branding').createSync(recursive: true);
    await _loadBrandFonts();

    const width = 1024;
    const height = 500;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _paintFeatureGraphic(canvas, const Size(width * 1.0, height * 1.0));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();

    File(
      'assets/branding/feature-graphic-1024x500.png',
    ).writeAsBytesSync(data!.buffer.asUint8List());
    print('Wrote feature-graphic-1024x500.png');
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

/// Font families registered from the Flutter SDK's bundled Roboto, or null when
/// it could not be found.
String? _boldFamily;
String? _regularFamily;

/// Loads real fonts into the test environment.
///
/// `flutter test` renders text with a placeholder font whose glyphs are solid
/// boxes, which is fine for layout assertions and useless for a store banner.
/// Roboto ships inside the Flutter SDK, so the graphic uses the same typeface
/// the app itself renders with.
Future<void> _loadBrandFonts() async {
  final root = _flutterRoot();
  if (root == null) {
    print('WARNING: could not locate the Flutter SDK; banner will omit text');
    return;
  }

  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) {
    print('WARNING: ${dir.path} not found; banner will omit text');
    return;
  }

  Future<String?> load(String family, String file) async {
    final font = File('${dir.path}/$file');
    if (!font.existsSync()) return null;
    final bytes = font.readAsBytesSync();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
    return family;
  }

  _boldFamily = await load('BrandBold', 'roboto-bold.ttf');
  _regularFamily = await load('BrandRegular', 'roboto-regular.ttf');
}

/// The flutter tool exports FLUTTER_ROOT; failing that, the test binary itself
/// lives under the SDK's cache, so the root can be walked back to.
String? _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    if (Directory('${dir.path}/bin/cache/artifacts').existsSync()) {
      return dir.path;
    }
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

/// The 1024x500 banner Play shows at the top of a listing.
///
/// The mark sits left, the name and a one-line pitch right. Play often overlays
/// its own app title on this image, so the text is kept to the lower half and
/// well inside the margins.
void _paintFeatureGraphic(Canvas canvas, Size size) {
  canvas.drawRect(
    Offset.zero & size,
    Paint()..color = BaselineBrand.background,
  );

  // A faint echo of the mark, bled off the right edge, so the banner is not a
  // flat rectangle at large widths.
  canvas.save();
  canvas.clipRect(Offset.zero & size);
  canvas.translate(size.width * 0.66, -size.height * 0.28);
  canvas.saveLayer(
    Rect.fromLTWH(0, 0, size.height * 1.6, size.height * 1.6),
    Paint()..color = const Color(0x14FFFFFF),
  );
  paintBaselineMark(canvas, Size.square(size.height * 1.6));
  canvas.restore();
  canvas.restore();

  final markSize = size.height * 0.52;
  final markLeft = size.width * 0.075;
  canvas.save();
  canvas.translate(markLeft, (size.height - markSize) / 2);
  paintBaselineMark(canvas, Size.square(markSize));
  canvas.restore();

  if (_boldFamily == null) return;

  final textLeft = markLeft + markSize + size.width * 0.055;
  final maxWidth = size.width - textLeft - size.width * 0.06;

  _drawText(
    canvas,
    'Baseline',
    Offset(textLeft, size.height * 0.33),
    fontSize: size.height * 0.155,
    color: BaselineBrand.rule,
    family: _boldFamily,
    letterSpacing: -2,
    maxWidth: maxWidth,
  );
  _drawText(
    canvas,
    'Train offline. Your data stays yours.',
    Offset(textLeft, size.height * 0.545),
    fontSize: size.height * 0.058,
    color: BaselineBrand.barHigh,
    family: _regularFamily ?? _boldFamily,
    maxWidth: maxWidth,
  );
}

void _drawText(
  Canvas canvas,
  String text,
  Offset at, {
  required double fontSize,
  required Color color,
  required double maxWidth,
  String? family,
  double letterSpacing = 0,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: family,
        letterSpacing: letterSpacing,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  painter.paint(canvas, at);
  painter.dispose();
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
