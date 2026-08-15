import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'rest_alerts.dart';

/// Real rest alerts: an OS notification for when the app is backgrounded, plus
/// sound and vibration for when it is not.
///
/// Everything here is local to the device — no network, no push service.
class PlatformRestAlerts implements RestAlerts {
  PlatformRestAlerts({
    FlutterLocalNotificationsPlugin? plugin,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationEnabled = true,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationEnabled;

  static const int _restNotificationId = 1001;
  static const String _channelId = 'rest_timer';

  bool _initialized = false;

  /// Only Android and Windows are shipped targets; anywhere else the scheduled
  /// notification is skipped rather than throwing.
  bool get _notificationsSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isWindows);

  Future<void> initialize() async {
    if (_initialized || !_notificationsSupported) return;

    tz_data.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        windows: WindowsInitializationSettings(
          appName: 'Baseline',
          appUserModelId: 'com.gavin.exercise_app',
          // Stable identifier for this app's notification registration.
          guid: '8e2a4b16-91f2-4a1e-9c3d-1f7b5a0c6d34',
        ),
      ),
    );

    _initialized = true;
  }

  /// Asks for notification permission on Android 13+, where it is runtime-gated.
  /// Returns false if the user declined; the app still works, just silently.
  Future<bool> requestPermissions() async {
    if (!_notificationsSupported || !Platform.isAndroid) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> scheduleCompletionAlert({
    required Duration after,
    String? label,
  }) async {
    if (!notificationEnabled || !_notificationsSupported) return;
    await initialize();
    await cancelCompletionAlert();

    final when = tz.TZDateTime.now(tz.local).add(after);

    await _plugin.zonedSchedule(
      id: _restNotificationId,
      scheduledDate: when,
      title: 'Rest complete',
      body: label == null ? 'Time for your next set.' : 'Next up: $label',
      // Inexact, because the app declares no exact-alarm permission: see the
      // note in AndroidManifest.xml. Asking for an exact alarm without it
      // throws `exact_alarms_not_permitted` on Android 12+. The trade is that
      // the system may batch this notification and deliver it late when the app
      // is in the background.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Rest timer',
          channelDescription: 'Alerts when a rest period between sets ends.',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
        ),
        windows: const WindowsNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> cancelCompletionAlert() async {
    if (!_notificationsSupported) return;
    await _plugin.cancel(id: _restNotificationId);
  }

  @override
  Future<void> alertNow() async {
    if (vibrationEnabled) {
      await HapticFeedback.heavyImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }
}
