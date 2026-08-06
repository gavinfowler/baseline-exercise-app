# Baseline

An offline exercise tracker for cardio and strength training. Everything runs on
the device — there is no account, no sync, and no network call anywhere in the
app. All data lives in a local SQLite database.

The name is the product: a static plan's **baseline** is the working weight that
ratchets upward and never falls back. The icon says the same thing — five bars
climbing off a solid rule.

Targets **Android** (primary) and **Windows desktop** (used as the fast
development loop).

## Quick start

```powershell
flutter pub get
dart run build_runner build     # generates the Drift database code
flutter run -d windows          # or: flutter run -d <android-device>
```

Run every quality gate the same way CI does:

```powershell
.\tool\check.ps1
```

## The two planning modes

This is the distinction that shapes the whole app:

| Mode | Behaviour when you beat the prescription |
|---|---|
| **Static** | The plan's baseline **rises**. Complete the prescribed reps at a heavier weight and that weight becomes the new target. |
| **Periodized** | The plan **does not change**. The result is recorded as a personal record, but the prescribed numbers stay exactly as written for the whole program. |

A static plan's baseline is keyed on *(plan, exercise, rep count)*, because
promotion means "heaviest weight completed **at the prescribed reps**". A set cut
short never promotes.

## What's in it

- **Workout logging** — ad-hoc or planned. Strength sets (weight, reps, RPE,
  warm-up flag) and cardio (duration, distance, incline, resistance, heart rate,
  calories, elevation), with the field set following the activity.
- **Supersets** — every exercise lives in a block; a block with two or more
  exercises is a superset or circuit, with its own round count and rest.
- **Rest timer** — starts itself when you log a working set, with sound,
  vibration, and an OS notification so it still reaches you if you switch away.
- **Cardio stopwatch** — start/pause/lap, saved as splits. No GPS, no
  permissions.
- **Pace that works itself out** — enter any two of duration, distance and pace
  and the third is filled in. A 10:00 mile for 10 minutes is a mile.
- **Structured runs** — fartlek, interval repeats, tempo blocks and pyramids,
  built as a list of segments with their own paces. Start from a template and
  change the numbers.
- **Plans** — built in the app or uploaded as a file, in both progression modes.
- **AI-generated plans** — the import screen copies the JSON Schema plus a
  ready-made prompt to your clipboard; paste it into any chat tool, save the
  reply, and import it.
- **History and progress** — a log of past sessions, per-exercise charts (top
  set, estimated 1RM, distance, pace) and personal records.
- **Backup** — full JSON export and restore.

## Plan file format

The contract lives at `assets/schema/exercise-plan.schema.json`, with worked
examples in `assets/schema/examples/`. A minimal plan:

```json
{
  "schemaVersion": "1.0",
  "plan": {
    "name": "Upper/Lower",
    "mode": "static",
    "units": "imperial",
    "days": [{
      "label": "Upper A",
      "blocks": [{
        "kind": "superset", "rounds": 3, "restAfterRoundSeconds": 120,
        "exercises": [
          {"name": "Barbell Bench Press", "type": "strength",
           "reps": 8, "weight": 135, "weightMode": "baseline"},
          {"name": "Barbell Row", "type": "strength",
           "reps": 8, "weight": 115, "weightMode": "baseline"}
        ]
      }]
    }]
  }
}
```

Exercises are matched by name, case- and spacing-insensitively, and created if
they don't exist. Import validates the whole file and reports **every** problem
at once, each with a JSON Pointer to the exact node — nothing is written until
you confirm the preview.

### Structured cardio

A cardio exercise can carry an `intervals` array describing a whole session as
ordered segments. Each entry is one repeated work/recovery pair, so `6 × 400m
with a 200m jog` is a single entry with `repeat: 6`:

```json
{
  "name": "Outdoor Run", "type": "cardio", "activity": "run",
  "durationSeconds": 2760, "distance": 4.5,
  "intervals": [
    { "label": "Warm-up", "repeat": 1, "workSeconds": 600, "workPace": "10:00" },
    { "label": "400 m repeats", "repeat": 6,
      "workDistance": 0.25, "workPace": "7:00",
      "recoveryDistance": 0.25, "recoveryPace": "11:00" },
    { "label": "Cool-down", "repeat": 1, "workSeconds": 600, "workPace": "10:30" }
  ]
}
```

Distances and paces are in the plan's own `units` and are converted on import;
see `assets/schema/examples/speed-work-running.json`, which is written in miles.
Within a leg, supplying any two of seconds, distance and pace determines the
third, so `workSeconds` and `workPace` is a complete prescription on its own.

The earlier flat `{repeat, workSeconds, restSeconds}` form is still accepted, so
plans written against the first version of the format import unchanged.

## Branding

The logo is **code, not a bitmap**: `lib/branding/baseline_logo.dart` draws it
as geometry in a normalized square, so the same source produces the 48 px
launcher icon, the 256 px Windows icon and an arbitrarily large render. The app
draws it as a vector too, via the `BaselineLogo` widget, so no image asset is
bundled.

Regenerate every launcher icon after changing the mark:

```powershell
flutter test tool/generate_icons.dart
```

That rewrites the Android mipmaps (legacy, adaptive foreground and monochrome),
`windows/runner/resources/app_icon.ico`, and the PNGs in `assets/branding/`.
It lives in `tool/` rather than `test/` so the normal suite never rewrites
binaries; `assets/branding/` is deliberately **not** in the pubspec's asset list,
since those PNGs are for store listings rather than for the app to load.

## Project layout

```
lib/
  core/        pure Dart: unit conversion, Clock, Result/validation types
  data/        Drift schema, generated database code, repositories
  domain/      plan import, progression rules, records — no Flutter imports
  features/    UI, one directory per screen area
assets/schema/ the plan-file JSON Schema and worked examples
test/          unit and widget tests
integration_test/  end-to-end flows
```

## Units

Everything is stored in **kilograms, meters and seconds**, with pace as seconds
per kilometre. Imperial is a display concern only, applied at the edges by
`UnitFormatter`, so switching the unit setting never migrates stored data.

Timestamps are stored as ISO-8601 text rather than unix integers, which keeps
sub-second precision and avoids the local/UTC ambiguity of drift's integer
default.

## Testing

Ease of testing is a design constraint here, not an afterthought:

- The `core` and `domain` layers are pure Dart and run in milliseconds.
- Repository tests use `NativeDatabase.memory()` — a **real** SQLite instance per
  test, so constraints, cascades and queries are verified against actual SQL
  rather than against mocks. See `test/support/test_database.dart`.
- Time flows through an injectable `Clock`; tests drive `FakeClock`.
- Fixture builders in `test/support/builders.dart` keep tests declarative.

```powershell
flutter test                    # unit + widget
flutter test integration_test   # end-to-end, needs a device
```

### Where UI-plus-database tests live

`flutter_test` runs widget tests inside a fake-async zone. Drift does not
cooperate with it: `database.close()` never completes there, and drift's stream
store leaves a cleanup timer pending, which trips the framework's
end-of-test invariant check. Widget tests that need real data therefore live in
`integration_test/`, which runs on a real device with real async where drift
behaves normally.

Widget tests under `test/` are for UI that takes plain data — see
`test/features/rest_timer_bar_test.dart`. Everything data-shaped is covered by
repository tests against real in-memory SQLite, which are fast and reliable.

> **CI note:** host tests need a SQLite library available to the test VM. It is
> present by default on this development machine; a clean CI image may need
> `sqlite3` installed.

## Ads

There are none, and no ad SDK is a dependency. Adding one would introduce network
and tracking code that contradicts the offline guarantee. What exists instead is
a reserved layout slot (`AdSlot`) that renders nothing while `AdsConfig.enabled`
is false, so a banner can be dropped in later without reworking any screen.

## Dependency notes

Two constraints in `pubspec.yaml` look arbitrary and are not:

- **`path_provider_foundation` is pinned to 2.4.1** via `dependency_overrides`.
  It is the iOS/macOS implementation and is never executed on Android or
  Windows, but from 2.5.0 it pulls in `objective_c`, which declares native build
  hooks that this Dart version's `build_runner` cannot compile.
- **`drift`/`drift_dev` are held below 2.32.** From that version they require
  `analyzer` 13, which needs `meta` 1.18, while the Flutter SDK pins `meta`
  1.17.0. Raising these is worth revisiting after a Flutter SDK upgrade.
