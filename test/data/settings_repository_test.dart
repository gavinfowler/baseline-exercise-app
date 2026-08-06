import 'package:exercise_app/core/units/unit_system.dart';
import 'package:exercise_app/data/db/app_database.dart';
import 'package:exercise_app/data/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = SettingsRepository(db);
  });

  test('defaults to metric before anything is stored', () async {
    expect(await repo.getUnitSystem(), UnitSystem.metric);
  });

  test('round-trips the unit system', () async {
    await repo.setUnitSystem(UnitSystem.imperial);
    expect(await repo.getUnitSystem(), UnitSystem.imperial);
  });

  test('overwrites rather than duplicating on repeated writes', () async {
    await repo.setUnitSystem(UnitSystem.imperial);
    await repo.setUnitSystem(UnitSystem.metric);

    expect(await repo.getUnitSystem(), UnitSystem.metric);
    expect(await db.select(db.appSettings).get(), hasLength(1));
  });

  test('falls back to the default rest when unset or corrupt', () async {
    expect(
      await repo.getDefaultRestSeconds(),
      SettingsRepository.defaultRestSecondsFallback,
    );

    await repo.setDefaultRestSeconds(120);
    expect(await repo.getDefaultRestSeconds(), 120);
  });

  test('flags default to true and round-trip', () async {
    expect(await repo.getFlag(SettingsRepository.keyRestSoundEnabled), isTrue);

    await repo.setFlag(SettingsRepository.keyRestSoundEnabled, value: false);
    expect(await repo.getFlag(SettingsRepository.keyRestSoundEnabled), isFalse);
  });

  test('watchUnitSystem emits on change', () async {
    final seen = <UnitSystem>[];
    final sub = repo.watchUnitSystem().listen(seen.add);

    await repo.setUnitSystem(UnitSystem.imperial);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(seen.last, UnitSystem.imperial);
  });

  test('readAll and writeAll round-trip for the backup feature', () async {
    await repo.setUnitSystem(UnitSystem.imperial);
    await repo.setDefaultRestSeconds(150);

    final exported = await repo.readAll();
    expect(exported[SettingsRepository.keyUnitSystem], 'imperial');
    expect(exported[SettingsRepository.keyDefaultRestSeconds], '150');

    // Simulate restoring into a fresh device.
    final restoreDb = createTestDatabase();
    await SettingsRepository(restoreDb).writeAll(exported);

    expect(
      await SettingsRepository(restoreDb).getUnitSystem(),
      UnitSystem.imperial,
    );
    expect(await SettingsRepository(restoreDb).getDefaultRestSeconds(), 150);
  });
}
