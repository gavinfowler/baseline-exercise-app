import 'package:drift/drift.dart';

import '../../core/units/unit_system.dart';
import '../db/app_database.dart';

/// Typed access to the key/value settings table.
///
/// Settings live in the database rather than in shared preferences so a backup
/// export captures them alongside the training data.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const String keyUnitSystem = 'unitSystem';
  static const String keyDefaultRestSeconds = 'defaultRestSeconds';
  static const String keyRestSoundEnabled = 'restSoundEnabled';
  static const String keyRestVibrationEnabled = 'restVibrationEnabled';
  static const String keyRestNotificationEnabled = 'restNotificationEnabled';

  static const int defaultRestSecondsFallback = 90;

  Future<String?> _read(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(AppSettingRow(key: key, value: value));
  }

  Stream<String?> _watch(String key) {
    return (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<UnitSystem> getUnitSystem() async {
    final raw = await _read(keyUnitSystem);
    return raw == null ? UnitSystem.metric : UnitSystem.fromName(raw);
  }

  Future<void> setUnitSystem(UnitSystem system) =>
      _write(keyUnitSystem, system.name);

  Stream<UnitSystem> watchUnitSystem() => _watch(
    keyUnitSystem,
  ).map((raw) => raw == null ? UnitSystem.metric : UnitSystem.fromName(raw));

  /// Rest used when a block does not prescribe one.
  Future<int> getDefaultRestSeconds() async {
    final raw = await _read(keyDefaultRestSeconds);
    return int.tryParse(raw ?? '') ?? defaultRestSecondsFallback;
  }

  Future<void> setDefaultRestSeconds(int seconds) =>
      _write(keyDefaultRestSeconds, seconds.toString());

  Future<bool> getFlag(String key, {bool fallback = true}) async {
    final raw = await _read(key);
    if (raw == null) return fallback;
    return raw == 'true';
  }

  Future<void> setFlag(String key, {required bool value}) =>
      _write(key, value.toString());

  Stream<bool> watchFlag(String key, {bool fallback = true}) =>
      _watch(key).map((raw) => raw == null ? fallback : raw == 'true');

  /// Every stored setting, for the backup export.
  Future<Map<String, String>> readAll() async {
    final rows = await _db.select(_db.appSettings).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Restores settings from a backup, replacing whatever is there.
  Future<void> writeAll(Map<String, String> values) async {
    await _db.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _db.appSettings,
          AppSettingRow(key: entry.key, value: entry.value),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
