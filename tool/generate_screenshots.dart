/// Regenerates the Play Store screenshots from the real UI.
///
/// This is a generator, not a test — like `generate_icons.dart` it is kept out
/// of `test/` so the normal suite never rewrites binaries. Run it after any
/// change that alters how a screen looks:
///
/// ```powershell
/// flutter test tool/generate_screenshots.dart
/// ```
///
/// It renders the actual widget tree against the seed backup in `tool/seed/`,
/// so every number on screen is real data the app produced, not mock-ups.
///
/// Output goes to `store/screenshots/<form-factor>/`, sized to what Play
/// accepts. Play demands an exact 16:9 or 9:16 ratio, so the sizes below are
/// exact 9:16 rather than the true aspect of any particular handset. The
/// 10-inch bucket additionally requires both sides to be at least 1080px, which
/// is why it is not simply the phone render at a larger scale.
library;

// This is a command-line generator; printing what it wrote is the point.
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:exercise_app/app/providers.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/domain/backup/backup_service.dart';
import 'package:exercise_app/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderRepaintBoundary, debugDisableShadows;
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Play screenshot bucket.
///
/// [pixels] is what Play receives. [logicalWidth] is the width the app lays
/// itself out at, and the density falls out of the two.
///
/// The tablet buckets deliberately do **not** lay out at a tablet's true
/// width. Baseline has no tablet breakpoint — every screen is a single column —
/// so rendering at 800dp gives a listing full of white space rather than a
/// listing of a roomier app. Laying out narrow and rendering dense produces the
/// same pixels Play asks for, showing the app at the proportions it was
/// designed at.
class _Device {
  const _Device(this.folder, this.pixels, this.logicalWidth);

  final String folder;
  final Size pixels;
  final double logicalWidth;

  double get pixelRatio => pixels.width / logicalWidth;
  Size get logical => Size(logicalWidth, pixels.height / pixelRatio);
  String get label => '${pixels.width.round()}x${pixels.height.round()}';
}

const List<_Device> _devices = [
  _Device('phone', Size(1080, 1920), 405),
  _Device('tablet-7in', Size(1440, 2560), 480),
  // Both sides clear the 1080 floor this bucket adds.
  _Device('tablet-10in', Size(1620, 2880), 540),
];

/// Indexes into [AppShell]'s stack, which is the drawer's order.
const int _workout = 0;
const int _plans = 1;
const int _strength = 2;
const int _cardio = 3;
const int _history = 4;
const int _settings = 5;

typedef _Interact = Future<void> Function(WidgetTester tester);

class _Shot {
  const _Shot(this.name, this.destination, {this.interact});

  final String name;
  final int destination;

  /// Anything the shot needs beyond selecting its destination — switching to a
  /// tab, opening a sheet.
  final _Interact? interact;
}

/// Ordered so the filenames sort into the order Play shows them, which is the
/// order they are uploaded in.
final List<_Shot> _shots = [
  const _Shot('01-workout', _workout),
  const _Shot('02-plans', _plans),
  const _Shot('03-strength', _strength),
  const _Shot('04-cardio', _cardio),
  const _Shot('05-history', _history),
  _Shot(
    '06-progress',
    _history,
    interact: (tester) async {
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
    },
  ),
  const _Shot('07-settings', _settings),
];

/// Rebuilt for each device so no shot inherits scroll or tab state from the
/// bucket rendered before it.
late AppDatabase _db;
late ProviderContainer _container;

void main() {
  setUpAll(_loadFonts);

  setUp(() async {
    // Same in-memory instance the test suite uses: real SQLite, no file, and
    // no background isolate — an isolate's futures never complete inside
    // flutter_test's fake-async zone.
    _db = AppDatabase(NativeDatabase.memory());
    addTearDown(_db.close);

    await BackupService(_db).restoreFromJson(
      File('tool/seed/baseline-seed-full.json').readAsStringSync(),
    );

    _container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(_db)],
    );
    addTearDown(_container.dispose);

    await _startLiveSession(_container, _db);
  });

  for (final device in _devices) {
    testWidgets('renders the ${device.folder} screenshots', (tester) async {
      tester.view.physicalSize = device.pixels;
      tester.view.devicePixelRatio = device.pixelRatio;
      addTearDown(tester.view.reset);

      // flutter_test paints shadows as flat black so goldens stay
      // deterministic. These are pictures of the app rather than goldens, and a
      // hard black outline around every elevated surface is the one thing that
      // would make them look fake. It has to be restored before the body ends:
      // the binding asserts on painting debug variables the moment the test
      // returns, which is earlier than any tear-down would run.
      debugDisableShadows = false;
      try {
        await _shoot(tester, device);
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}

Future<void> _shoot(WidgetTester tester, _Device device) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: UncontrolledProviderScope(
        container: _container,
        child: const _ScreenshotApp(),
      ),
    ),
  );
  await _settle(tester);

  final dir = Directory('store/screenshots/${device.folder}')
    ..createSync(recursive: true);

  for (final shot in _shots) {
    _container.read(shellDestinationProvider.notifier).select(shot.destination);
    await _settle(tester);
    await shot.interact?.call(tester);
    await _settle(tester);

    await _capture(
      tester,
      boundaryKey,
      device,
      File('${dir.path}/${shot.name}.png'),
    );
  }

  print('Wrote ${_shots.length} ${device.label} screenshots to ${dir.path}');
}

/// The app as the screenshots want it.
///
/// Mirrors `lib/app.dart` rather than using [ExerciseApp] directly, for two
/// reasons: the fonts loaded below have to be named as the default family, and
/// Material 3's InkSparkle needs a fragment shader the widget-test environment
/// cannot compile. Keep the colour in step with `lib/app.dart`.
class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp();

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F6F4E);

    return MaterialApp(
      title: 'Baseline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        fontFamily: 'Roboto',
        splashFactory: InkRipple.splashFactory,
      ),
      home: const AppShell(),
    );
  }
}

/// Puts a half-finished workout on screen.
///
/// The seed backup is 18 weeks of *completed* training, so without this the
/// Workout tab would screenshot as its empty state — the one screen a store
/// listing must not lead with.
Future<void> _startLiveSession(
  ProviderContainer container,
  AppDatabase db,
) async {
  final repo = container.read(sessionRepositoryProvider);

  Future<int?> idOf(String name) async {
    final rows = await (db.select(
      db.exercises,
    )..where((t) => t.name.equals(name))).get();
    return rows.isEmpty ? null : rows.first.id;
  }

  final sessionId = await repo.startSession(title: 'Upper A');

  // Weights are the seed's own working numbers, so the sets agree with the
  // history and personal records on the other tabs. Four exercises rather than
  // two because the tall buckets are 2880px: a session that fills a phone
  // leaves a tablet shot two-thirds empty.
  const work = [
    ('Barbell Bench Press', [(8, 82.5, 7.5), (8, 82.5, 8.0), (7, 82.5, 9.0)]),
    ('Barbell Row', [(8, 75.0, 7.0), (8, 75.0, 8.0), (8, 75.0, 8.5)]),
    ('Overhead Press', [(8, 47.5, 7.5), (7, 47.5, 8.5)]),
    ('Lat Pulldown', [(10, 65.0, 7.0), (10, 65.0, 8.0)]),
  ];

  var group = 0;
  for (final (name, sets) in work) {
    final exerciseId = await idOf(name);
    if (exerciseId == null) continue;

    var round = 0;
    for (final (reps, weight, rpe) in sets) {
      await repo.addStrengthSet(
        sessionId: sessionId,
        exerciseId: exerciseId,
        groupIndex: group,
        roundIndex: round,
        actualReps: reps,
        actualWeightKg: weight,
        rpe: rpe,
      );
      round++;
    }
    group++;
  }
}

/// Pumps until the screen has stopped loading, then lets animations finish.
///
/// `pumpAndSettle` alone cannot be used here: while a stream is still to
/// deliver its first value the screen shows a `CircularProgressIndicator`,
/// which never stops animating and would time it out.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 40));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
    await tester.pumpAndSettle();
  }
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  _Device device,
  File out,
) async {
  // Encoding must escape the fake-async zone, where `toImage` never completes.
  final bytes = await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: device.pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });

  out.writeAsBytesSync(bytes!);
}

/// Loads the real Roboto and the Material icon font.
///
/// Without this every glyph renders as the test font's filled box. The files
/// ship with the Flutter SDK, so nothing has to be vendored into the repo.
Future<void> _loadFonts() async {
  final root = _flutterRoot();
  if (root == null) {
    print('WARNING: no FLUTTER_ROOT; text will render as boxes');
    return;
  }

  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) {
    print('WARNING: ${dir.path} not found; text will render as boxes');
    return;
  }

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    var found = false;
    for (final file in files) {
      final font = File('${dir.path}/$file');
      if (!font.existsSync()) continue;
      found = true;
      loader.addFont(
        Future.value(ByteData.view(font.readAsBytesSync().buffer)),
      );
    }
    if (found) await loader.load();
  }

  // Both weights go into one family; Flutter picks between them using the
  // weight recorded inside each file.
  await load('Roboto', ['roboto-regular.ttf', 'roboto-bold.ttf']);
  await load('MaterialIcons', ['materialicons-regular.otf']);
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
    dir = dir.parent;
  }
  return null;
}
