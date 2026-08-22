# flutter_tuya_sdk — pub.dev Publish Prep — Design

## Goal

Take the existing, ~10-months-abandoned Tuya Flutter plugin
(`packages/tuya_flutter_ha_sdk/`) and prepare it for a public pub.dev
release under the new name `flutter_tuya_sdk`: rename it, refresh it
for current Flutter/Dart tooling, replace licensing with the author's
own, add a proper `example/`, and satisfy pub.dev publishing rules.

## Assumptions (confirm/override before implementation)

- **Reverse-domain Android package id**: `com.waleedashraf.flutter_tuya_sdk`
  (replaces `us.kpmsg.tuya_flutter_ha_sdk`). No existing personal
  domain was given — change this in the plan if you have one.
- **Repository URL**: `https://github.com/waleedashraf/flutter_tuya_sdk`
  used as a placeholder for `homepage`/`repository`/`issue_tracker` in
  `pubspec.yaml`. Must be replaced with your actual GitHub URL (create
  the repo if it doesn't exist) before publishing — pub.dev verifies
  these links resolve.
- **License copyright holder**: `Waleed Ashraf` (confirmed).
- **Example app basis**: the root SyncN app (`lib/`) is trimmed down
  and moved into the package's `example/` folder, keeping auth
  (login/register), home & device list, WiFi/BLE pairing, and lock
  control as the demo surface (confirmed).

## Scope

### 1. Rename `tuya_flutter_ha_sdk` → `flutter_tuya_sdk`

- Rename the package directory: `packages/tuya_flutter_ha_sdk/` →
  `packages/flutter_tuya_sdk/`.
- `pubspec.yaml`: `name: flutter_tuya_sdk`, update `description`,
  `homepage`, `repository`, `issue_tracker`, `plugin.platforms.android.package`
  → `com.waleedashraf.flutter_tuya_sdk`. Plugin class renamed
  `TuyaFlutterHaSdkPlugin` → `FlutterTuyaSdkPlugin` for consistency.
- **Android**: move `android/src/main/java/us/kpmsg/tuya_flutter_ha_sdk/`
  → `android/src/main/java/com/waleedashraf/flutter_tuya_sdk/`, rename
  `TuyaFlutterHaSdkPlugin.java` → `FlutterTuyaSdkPlugin.java` (class +
  package decl), same for `TuyaCameraPlugin.java` and the test file.
  Update `AndroidManifest.xml`, `build.gradle`/`build.gradle.kts`
  package refs.
- **iOS**: rename `tuya_flutter_ha_sdk.podspec` →
  `flutter_tuya_sdk.podspec`, update `s.name`/`s.module_name`; rename
  `TuyaFlutterHaSdkPlugin.swift` → `FlutterTuyaSdkPlugin.swift` (class
  name + `register(with:)`), keep `BluetoothPairingManager.swift`,
  `ThingModelExtensions.swift`, `TuyaCameraPlugin.swift` as-is unless
  they reference the old plugin class name directly.
- **Dart**: rename `lib/tuya_flutter_ha_sdk.dart` →
  `lib/flutter_tuya_sdk.dart` (main export), `tuya_flutter_ha_sdk_platform_interface.dart`
  → `flutter_tuya_sdk_platform_interface.dart`,
  `tuya_flutter_ha_sdk_method_channel.dart` →
  `flutter_tuya_sdk_method_channel.dart`. Public API class
  `TuyaFlutterHaSdk` → `FlutterTuyaSdk`. Method channel name
  `tuya_flutter_ha_sdk` → `flutter_tuya_sdk`, event channel
  `tuya_flutter_ha_sdk/pairingEvents` → `flutter_tuya_sdk/pairingEvents`
  — **native and Dart sides must change together** or the channel
  breaks silently.
- **Root app** (`example` at repo root, later becomes the trimmed
  `example/`): update `pubspec.yaml` dependency path + every
  `import 'package:tuya_flutter_ha_sdk/...'` (repo-wide grep/replace)
  to `package:flutter_tuya_sdk/...`, and all `TuyaFlutterHaSdk.` call
  sites to `FlutterTuyaSdk.`.

### 2. License cleanup

- Rewrite `packages/flutter_tuya_sdk/LICENSE`: MIT, `Copyright (c)
  2026 Waleed Ashraf`.
- No other bundled license/notice files exist in the package (verified
  via repo-wide grep for `Copyright`/`License` — only the plugin's own
  `LICENSE`, `README.md` license section, and two `gradlew` wrapper
  scripts, which carry Gradle's own unrelated Apache header and must
  stay as-is since they're upstream Gradle files, not this project's
  copyright). Nothing else to strip.
- Update the `## License` section in the package `README.md` to
  reflect the same MIT/Waleed Ashraf notice.

### 3. Example app (`packages/flutter_tuya_sdk/example/`)

- Move a trimmed copy of the root SyncN app into the package's
  `example/` directory (pub.dev convention: `example/lib/main.dart`
  minimum).
- Keep: SDK init (`tuya_configuration.dart`), auth flow (login/register
  cubit + pages), home/device list, WiFi/BLE onboarding pages,
  lock control.
- Trim/remove: the custom `liquid_pull_to_refresh` widget set, unused
  `get_it` import (DI not actually wired), any app-specific
  branding/theming not needed to demonstrate the SDK, the map-based
  site widget if it adds dependency weight without demonstrating the
  plugin.
- Replace hardcoded Tuya App Key/Secret in `tuya_configuration.dart`
  with placeholders + a README note telling consumers to fill in their
  own (the current hardcoded keys are a real credential leak risk once
  public — **must** be scrubbed, including from git history if already
  pushed anywhere public).
- `example/pubspec.yaml`: `flutter_tuya_sdk: path: ../`, trimmed
  dependency list matching only what the trimmed example actually
  uses.
- The root repo's current `example` app either becomes exactly this
  (repo root turns into a thin wrapper / the example moves and the
  root `pubspec.yaml` `name` gets fixed from `example` →
  something sensible) — decided during implementation planning since
  it affects the whole repo layout; flagged here, not decided.

### 4. Flutter/Dart compatibility refresh

- Detect the currently installed Flutter/Dart version on this machine
  and set `environment.sdk` / `flutter:` constraints in the package
  pubspec to match current stable, not the stale `^3.7.2` / `>=3.3.0`.
- `flutter pub outdated` in the package; bump `plugin_platform_interface`
  and `flutter_lints` to current majors; fix lints that come with the
  bump.
- Android: verify Kotlin/AGP/Gradle wrapper versions against current
  Flutter's template defaults; verify `thingsmart`/`BizBundlesBom`/
  `thingsmart-ipcsdk`/`thingsmart-lock-sdk`/`soloader` versions still
  resolve from Tuya's Maven repo.
- iOS: verify Swift version and minimum iOS deployment target against
  current Xcode/CocoaPods expectations; verify the `ThingSmartCryption`
  pod path setup in the README still matches Tuya's current SDK
  distribution.
- Run `flutter analyze` and `flutter test` inside the package; fix
  breakage introduced by the version bumps or by the rename.

### 5. pub.dev publish compliance

- `pubspec.yaml`: real `description` (60–180 chars), valid
  `homepage`/`repository`/`issue_tracker`, `topics` list, no
  `publish_to: none` on the package (root app keeps it).
- `CHANGELOG.md`: add a genuine first-release entry (`0.1.0` or
  `1.0.0` — decide during planning) instead of the current placeholder.
- `README.md`: keep the detailed API guide but ensure it renders
  cleanly on pub.dev (heading structure, no broken relative links).
- Ensure public API has doc comments where missing (pub.dev scores
  this).
- Run `flutter pub publish --dry-run` inside the package and resolve
  every warning/error before considering this done.

## Testing

- `flutter analyze` clean in both the package and its `example/`.
- `flutter test` passes in the package.
- `example/` app builds for Android at minimum (iOS build verified if
  a Mac/Xcode is available in this environment — flag if not).
- `flutter pub publish --dry-run` passes with no errors (warnings
  triaged, not necessarily all fixed).

## Out of scope

- Actually running `flutter pub publish` (publishing is a one-way,
  externally-visible action — requires your explicit go-ahead
  separately from this plan).
- Setting up CI/CD for the package.
- Adding new SDK features beyond what already exists.
