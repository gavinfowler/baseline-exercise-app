import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/rest_timer/rest_timer_controller.dart';
import 'services/platform_rest_alerts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up notifications before the first frame so a rest timer started
  // immediately still schedules correctly.
  final alerts = PlatformRestAlerts();
  await alerts.initialize();
  // Android 13+ gates notifications behind a runtime grant. Declining only
  // means rest alerts stay in-app; nothing else is affected.
  await alerts.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [restAlertsProvider.overrideWithValue(alerts)],
      child: const ExerciseApp(),
    ),
  );
}
