/// The Baseline mark, drawn as geometry rather than shipped as a bitmap.
///
/// Five bars climbing off a solid rule: the rule is the baseline, and the bars
/// only ever go up. That is the app's central behaviour — a static plan's
/// working weight ratchets upward and never falls back — so the icon states the
/// product's one distinguishing idea.
///
/// Everything is expressed in a normalized 0..1 square and scaled at paint
/// time, so the same source draws the 48 px launcher icon, the 256 px Windows
/// icon, and an arbitrarily large splash without a raster asset anywhere. The
/// launcher PNGs are generated from this file by `tool/generate_icons.dart`.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The palette, derived from the app's `#2F6F4E` theme seed so the icon and the
/// interface agree.
abstract final class BaselineBrand {
  /// Deep forest, dark enough that the bars carry the contrast.
  static const Color background = Color(0xFF0F2B20);

  /// The baseline rule. Near-white rather than pure white, to sit calmly
  /// against the background at large sizes.
  static const Color rule = Color(0xFFF4F7F3);

  /// The shortest bar. Muted, so the ramp reads as a climb.
  static const Color barLow = Color(0xFF3E8F66);

  /// The tallest bar — the new high.
  static const Color barHigh = Color(0xFF6EE7A8);

  /// Matches the app's `ColorScheme.fromSeed` seed.
  static const Color seed = Color(0xFF2F6F4E);

  /// Fraction of an adaptive icon's canvas the mark may occupy.
  ///
  /// Android masks a 108dp adaptive icon down to a 72dp circle and guarantees
  /// only the inner 66dp. Anything outside that can be cropped by the launcher.
  static const double adaptiveSafeFraction = 66 / 108;
}

// Geometry, in a normalized 0..1 square. These are the only magic numbers in
// the mark, and they are what makes it legible at 48 px: no strokes, no detail
// finer than about 1/20th of the canvas.
const int _barCount = 5;

/// Clear air between the foot of each bar and the rule, so the bars read as
/// hovering above the baseline rather than growing out of it.
const double _barLift = 0.034;

/// Chosen so the mark's bounding box — the tallest bar down to the underside of
/// the rule — centres on the canvas. Deriving it keeps the composition centred
/// if the bar heights or the lift are ever retuned.
const double _ruleTop = 0.5 + (_barLift + _barMaxHeight - _ruleThickness) / 2;

/// Where the bars sit: lifted clear of the rule.
const double _barBaseline = _ruleTop - _barLift;

const double _ruleThickness = 0.058;
const double _ruleInset = 0.145;
const double _barWidth = 0.098;
const double _barGap = 0.0365;
const double _barMinHeight = 0.105;
const double _barMaxHeight = 0.415;
const double _barRadius = 0.018;

/// Paints just the bars and the rule, filling [size].
///
/// Leaves the background alone, which is what an Android adaptive foreground
/// and a monochrome themed icon both need.
void paintBaselineMark(Canvas canvas, Size size, {Color? monochrome}) {
  final s = size.shortestSide;
  final dx = (size.width - s) / 2;
  final dy = (size.height - s) / 2;

  double x(double v) => dx + v * s;
  double y(double v) => dy + v * s;

  const totalWidth = _barCount * _barWidth + (_barCount - 1) * _barGap;
  const startX = (1 - totalWidth) / 2;

  for (var i = 0; i < _barCount; i++) {
    final t = i / (_barCount - 1);
    final height = _barMinHeight + (_barMaxHeight - _barMinHeight) * t;
    final left = startX + i * (_barWidth + _barGap);

    final paint = Paint()
      ..isAntiAlias = true
      ..color =
          monochrome ??
          Color.lerp(BaselineBrand.barLow, BaselineBrand.barHigh, t)!;

    canvas.drawRRect(
      RRect.fromLTRBR(
        x(left),
        y(_barBaseline - height),
        x(left + _barWidth),
        y(_barBaseline),
        Radius.circular(_barRadius * s),
      ),
      paint,
    );
  }

  // Drawn last so it reads as the ground the bars rise from.
  canvas.drawRRect(
    RRect.fromLTRBR(
      x(_ruleInset),
      y(_ruleTop),
      x(1 - _ruleInset),
      y(_ruleTop + _ruleThickness),
      Radius.circular(_ruleThickness / 2 * s),
    ),
    Paint()
      ..isAntiAlias = true
      ..color = monochrome ?? BaselineBrand.rule,
  );
}

/// Paints the complete icon: background plus mark.
///
/// [cornerFraction] rounds the background — 0 for a full-bleed adaptive
/// background, about 0.22 for a standalone app icon.
void paintBaselineIcon(
  Canvas canvas,
  Size size, {
  double cornerFraction = 0.22,
  double markScale = 1,
}) {
  final s = size.shortestSide;
  final background = Paint()
    ..isAntiAlias = true
    ..color = BaselineBrand.background;

  if (cornerFraction <= 0) {
    canvas.drawRect(Offset.zero & size, background);
  } else {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(cornerFraction * s),
      ),
      background,
    );
  }

  _paintScaledMark(canvas, size, markScale);
}

/// Paints the mark inset to [scale] of the canvas, centred.
void _paintScaledMark(Canvas canvas, Size size, double scale) {
  if (scale == 1) {
    paintBaselineMark(canvas, size);
    return;
  }

  final inset = size.shortestSide * (1 - scale) / 2;
  canvas.save();
  canvas.translate(inset, inset);
  paintBaselineMark(
    canvas,
    Size(size.width - inset * 2, size.height - inset * 2),
  );
  canvas.restore();
}

/// Paints an adaptive-icon foreground: the mark alone, held inside the region
/// Android promises not to crop.
void paintBaselineAdaptiveForeground(Canvas canvas, Size size) =>
    _paintScaledMark(canvas, size, BaselineBrand.adaptiveSafeFraction);

/// The mark as a widget, for use inside the app.
///
/// Vector, so it is sharp at any size and costs no asset bundle space.
class BaselineLogo extends StatelessWidget {
  const BaselineLogo({
    this.size = 48,
    this.showBackground = true,
    this.color,
    super.key,
  });

  final double size;

  /// False draws the bars and rule alone, for placing on an existing surface.
  final bool showBackground;

  /// Overrides the palette with a single colour, for a monochrome treatment.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BaselineLogoPainter(
          showBackground: showBackground,
          color: color,
        ),
      ),
    );
  }
}

class _BaselineLogoPainter extends CustomPainter {
  const _BaselineLogoPainter({required this.showBackground, this.color});

  final bool showBackground;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    if (showBackground) {
      paintBaselineIcon(canvas, size);
    } else {
      paintBaselineMark(canvas, size, monochrome: color);
    }
  }

  @override
  bool shouldRepaint(_BaselineLogoPainter old) =>
      old.showBackground != showBackground || old.color != color;
}

/// Renders the icon to PNG bytes at [pixels] square.
///
/// Lives here rather than in `tool/` so the geometry and its rasterizer cannot
/// drift apart. Requires a Flutter engine, so it runs under `flutter test`.
Future<ui.Image> renderBaselineImage(
  int pixels, {
  required void Function(Canvas canvas, Size size) paint,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(pixels.toDouble(), pixels.toDouble());

  paint(canvas, size);

  final picture = recorder.endRecording();
  try {
    return await picture.toImage(pixels, pixels);
  } finally {
    picture.dispose();
  }
}
