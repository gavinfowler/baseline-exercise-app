# Data safety answers

Play Console → App content → Data safety. There is no API for this form, so it
has to be filled in by hand; this is the answer key, with the evidence for each
answer so it can be defended if Google queries it.

Re-check this file whenever the app gains a dependency or a permission. The
answers below are only true because of facts about the code, not because of
anything about the app's intent.

## The one that decides the rest

**Does your app collect or share any of the required user data types?**
→ **No**

Play defines *collection* as transmitting user data off the device, and
*sharing* as transferring it to a third party. Baseline does neither:

- No network code anywhere in `lib/` — no HTTP client, no sockets, no SDK that
  opens a connection.
- `android/app/src/main/AndroidManifest.xml` declares no `INTERNET` permission,
  so the shipped app is not capable of transmitting data even in principle.
- No analytics, crash reporting, attribution or advertising dependency in
  `pubspec.yaml`.

Answering No here collapses the rest of the form. The follow-up questions about
encryption in transit and about a data deletion request only appear for apps
that collect something.

## Data types — all No

Say No to every one. The two worth pausing on:

- **Health and fitness.** Baseline is full of health and fitness data:
  workouts, sets, weights, heart rate, calories. It still answers No, because
  the form asks what you *collect*, not what the app stores. Data that never
  leaves the device is not collected. Over-declaring here is the most likely
  mistake, and it is not a safe one — it would put a "collects health data"
  label on a listing whose entire pitch is the opposite.
- **Files and docs.** The backup export writes a file and the plan import reads
  one, both to a location the user picks. That is not collection either; see
  below.

Everything else is a plain No: location, personal info, financial info,
messages, photos and videos, audio, calendar, contacts, app activity, web
browsing, app info and performance, device or other IDs.

## Why the export features do not change the answer

Baseline can put training data outside itself in three ways. None is
collection or sharing, and all three rely on the same exemption: a transfer
that happens only because the user initiated it, to a destination the user
chose, is exempt from disclosure.

1. **Backup export** — writes a JSON file to a location chosen in the system
   file picker.
2. **Plan import** — reads a file the user picks.
3. **Copy for an AI tool** — puts training data on the clipboard, for the user
   to paste wherever they want. The app never contacts an AI service; there is
   no code that could.

In all three the app hands data to the user, not to a recipient of its own
choosing. What the user then does with it is outside the app.

## Adjacent questions in App content

- **Privacy policy** →
  `https://gavinfowler.github.io/baseline-exercise-app/privacy-policy.html`
- **Ads: does your app contain ads?** → **No**. `lib/features/ads/ad_slot.dart`
  reserves layout space but pulls in no ad SDK and renders nothing unless
  `ADS_ENABLED` is defined, which `tool/build_release.ps1` does not define. If
  that ever changes, this answer and the privacy policy both change first.
- **App access** → no login of any kind, so no credentials to provide.
- **Government apps / financial features / news** → No.

## If ads or sync ever ship

The whole form flips. Anything that transmits training data makes Health and
fitness a collected type, requires disclosing the purpose and whether it is
shared, and turns on the encryption-in-transit and deletion-request questions.
Update the privacy policy and `store/play-listing.md` in the same change.
