# Local Firestore development on Windows

The existing feature-based lib/ folders remain in place. No Firebase Authentication dependency, emulator, or sign-in UI is included.

## Prerequisites

This machine was found to have Flutter 3.47.7 / Dart 3.13.5, Node.js 24.20.0, Firebase CLI 15.34.0, Java 21, and the Android device emulator-5554. No software installation was performed.

On another machine, check `flutter --version`, `node --version`, `firebase.cmd --version`, and `java -version`. Use Node.js 24 LTS, a JDK 21 on PATH (and JAVA_HOME if needed), the Firebase CLI, and Flutter with the Android SDK. If the CLI is missing, install it yourself with `npm.cmd install -g firebase-tools`. The first emulator start may download Firebase's emulator runtime into its cache and needs internet access. No Firebase login, billing, FlutterFire reconfiguration, or real Firebase project is needed for this demo setup. Existing Firebase Dart dependencies are sufficient; use `flutter pub get` if restoring packages.

## Run locally

Open two VS Code PowerShell terminals in `C:\Users\aniru\apartment_survey_app`.

Terminal 1:

```powershell
.\scripts\start-firestore.ps1
```

Wait for the emulators-ready message. Terminal 2:

```powershell
flutter devices
.\scripts\run-local.ps1 -Device emulator-5554
```

If PowerShell blocks scripts, use the equivalent commands directly; changing your execution policy is unnecessary:

```powershell
firebase.cmd emulators:start --only firestore --project demo-apartment-survey --config firebase.emulators.json
# In the other terminal:
flutter run --debug -d emulator-5554 --dart-define=USE_FIRESTORE_EMULATOR=true
```

Alternatively select your Android emulator and the VS Code launch configuration **Apartment Survey - local Firestore**, then press F5 after starting Firestore.

Open http://127.0.0.1:4000 for the Emulator UI. The app log must show `Firestore emulator: demo-apartment-survey at 10.0.2.2:8080`. Use only invented apartment records. Local data is in memory and disappears when the Firestore emulator stops. Ctrl+C stops it. Stop and restart the app after changing environments; hot reload does not rerun initialization.

## Isolation and rules

- Debug builds default to the local demo project; an unavailable emulator never causes fallback to production. Android uses 10.0.2.2:8080 (the Android emulator's route to Windows loopback). Other targets select 127.0.0.1, but this workflow is verified for Android only; physical phones need a different networking setup.
- A named Firebase demo app is configured before any service/listener is created. Its Firestore instance is passed through MyApp and SurveyScreen to the existing ApartmentServices. Local disk persistence is disabled to prevent stale emulator data after restarts.
- Release and profile builds bypass emulator setup and retain the existing production Firebase options. An intentional production debug run requires `--dart-define=USE_FIRESTORE_EMULATOR=false`. Do not use that switch for dummy smoke tests.
- Android cleartext permission is added only in the debug manifest.
- `firebase.json` and `lib/firebase_options.dart` keep their existing FlutterFire production configuration. `.firebaserc` defaults CLI use to `demo-apartment-survey`; the local script also specifies that project explicitly.
- `firebase.emulators.json` is the separate local configuration. It binds Firestore, UI, and hub to Windows loopback. `emulator/firestore.local.rules` permits unauthenticated apartment CRUD locally and denies other collections. These are development rules, not a production access policy. Never deploy this local config or copy these rules into production.
- No production rules file existed in this checkout, and no deployed production rules were read or changed. A production no-auth access policy remains a separate release decision; this local setup does not grant cloud access.

## Verify with dummy data

```powershell
flutter test
flutter analyze
# With the Firestore emulator running:
flutter run --debug -d emulator-5554 -t tool/firestore_smoke.dart --dart-define=USE_FIRESTORE_EMULATOR=true
```

The smoke target refuses non-debug/non-emulator runs and verifies the demo project and Android local endpoint before writing. It exercises the actual ApartmentServices create transaction, duplicate rejection, update, stream, and deletion using a uniquely named DUMMY record, then cleans it up. Expect `FIRESTORE_SMOKE_PASS` and a success screen. Stop this test app, then run the regular app with the instructions above. The widget test uses an injected dummy service without any Firebase/network access.

## Troubleshooting

- Connection refused: leave terminal 1 running; check 8080 is free and inspect firebase-debug.log / firestore-debug.log. Do not open public firewall ports; both emulators are on this PC.
- Permission denied locally: use the exact local config and demo project command above; inspect requests in the Emulator UI. Do not change cloud Security Rules to fix a local connection.
- Different device ID: use the Android ID printed by `flutter devices`.
- Firebase CLI missing from PATH: reopen VS Code after installing it, or use its full path. The supplied scripts use firebase.cmd to avoid npm's PowerShell shim execution-policy issue.

References: https://firebase.google.com/docs/emulator-suite/connect_firestore and https://firebase.google.com/docs/emulator-suite/install_and_configure

## Verification on this machine (29 October 2026)

- flutter test passed (survey empty state, with no Firebase network calls).
- Android debug build succeeded and was installed on emulator-5554.
- The Android smoke target logged FIRESTORE_SMOKE_PASS for create, duplicate rejection, update, stream, and delete at 10.0.2.2:8080.
- A separate unauthenticated local REST check passed apartment write/read and verified another collection returns 403. Dummy records were deleted.
- JSON and PowerShell syntax checks passed; firebase.json is byte-for-byte unchanged.
- flutter analyze reports four pre-existing use_build_context_synchronously info findings in survey_screens.dart, with no new findings.
- The Android build emits existing Firebase plugin Kotlin migration and Android SDK XML version warnings; neither prevented the build.
- Firebase CLI downloaded its Firestore/UI runtime cache on first start. No system software was installed.


The regular survey app was rebuilt and launched successfully after the smoke test, and logged the demo endpoint. The test Emulator Suite was then stopped and its ports were released. Start it again in your own terminal using the run instructions above.

