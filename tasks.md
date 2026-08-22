# Tasks — flutter_tuya_sdk publish prep

Source spec: `docs/superpowers/specs/2026-08-22-flutter-tuya-sdk-publish-design.md`
(read it first — it has the full rationale/assumptions behind every
task below).

Assumptions locked in the spec (change these two if wrong before
starting):
- Android package id: `com.waleedashraf.flutter_tuya_sdk`
- Repo URL: `https://github.com/waleedashraf/flutter_tuya_sdk`

Tasks are ordered — later tasks depend on earlier ones in the same
numbered group. Groups themselves are mostly sequential too (rename
must land before compatibility/pub.dev work touches the renamed
files).

---

## 1. Rename package: tuya_flutter_ha_sdk → flutter_tuya_sdk

- [ ] 1.1 Rename `packages/tuya_flutter_ha_sdk/` → `packages/flutter_tuya_sdk/`
      (directory move, keep all contents).
- [ ] 1.2 Update `packages/flutter_tuya_sdk/pubspec.yaml`: `name`,
      `description`, `homepage`, `repository`, `issue_tracker`,
      `plugin.platforms.android.package` →
      `com.waleedashraf.flutter_tuya_sdk`.
- [ ] 1.3 Android: move
      `android/src/main/java/us/kpmsg/tuya_flutter_ha_sdk/` →
      `android/src/main/java/com/waleedashraf/flutter_tuya_sdk/`;
      rename `TuyaFlutterHaSdkPlugin.java` → `FlutterTuyaSdkPlugin.java`
      (class name + `package` declaration); rename
      `TuyaCameraPlugin.java` package declaration; rename/update the
      test file under `android/src/test/java/...` to match. Update
      `AndroidManifest.xml` and `build.gradle`/`build.gradle.kts`
      package references.
- [ ] 1.4 iOS: rename `tuya_flutter_ha_sdk.podspec` →
      `flutter_tuya_sdk.podspec`, update `s.name`/`s.module_name`;
      rename `TuyaFlutterHaSdkPlugin.swift` →
      `FlutterTuyaSdkPlugin.swift` (class name + `register(with:)`);
      check `BluetoothPairingManager.swift`, `ThingModelExtensions.swift`,
      `TuyaCameraPlugin.swift` for references to the old plugin class
      name and update.
- [ ] 1.5 Dart: rename `lib/tuya_flutter_ha_sdk.dart` →
      `lib/flutter_tuya_sdk.dart`,
      `lib/tuya_flutter_ha_sdk_platform_interface.dart` →
      `lib/flutter_tuya_sdk_platform_interface.dart`,
      `lib/tuya_flutter_ha_sdk_method_channel.dart` →
      `lib/flutter_tuya_sdk_method_channel.dart`. Rename public API
      class `TuyaFlutterHaSdk` → `FlutterTuyaSdk` and update every
      reference within the package (camera classes included).
- [ ] 1.6 Rename method channel `tuya_flutter_ha_sdk` →
      `flutter_tuya_sdk` and event channel
      `tuya_flutter_ha_sdk/pairingEvents` →
      `flutter_tuya_sdk/pairingEvents` **in both the Dart method-channel
      implementation and the native Android/iOS registration** —
      verify the strings match exactly on both sides or the channel
      silently breaks.
- [ ] 1.7 Repo-wide: update root `pubspec.yaml` dependency
      (`tuya_flutter_ha_sdk` → `flutter_tuya_sdk`, path updated) and
      every `import 'package:tuya_flutter_ha_sdk/...'` under root
      `lib/` to `package:flutter_tuya_sdk/...`; update every
      `TuyaFlutterHaSdk.` call site to `FlutterTuyaSdk.`.
- [ ] 1.8 `flutter pub get` at both root and package level; `flutter
      analyze` clean; fix any leftover references the grep passes
      missed.

## 2. License cleanup

- [ ] 2.1 Rewrite `packages/flutter_tuya_sdk/LICENSE`: MIT license,
      `Copyright (c) 2026 Waleed Ashraf`.
- [ ] 2.2 Update the `## License` section in
      `packages/flutter_tuya_sdk/README.md` to match.

## 3. Example app

- [ ] 3.1 Create `packages/flutter_tuya_sdk/example/` with its own
      `pubspec.yaml` (`flutter_tuya_sdk: path: ../`), depending only
      on what the trimmed example actually uses.
- [ ] 3.2 Move a trimmed copy of the root SyncN app into
      `example/lib/`: keep SDK init (`tuya_configuration.dart`), auth
      flow (login/register cubit + pages), home/device list, WiFi/BLE
      onboarding pages, lock control.
- [ ] 3.3 Strip from the example: the custom
      `liquid_pull_to_refresh` widget set, unused `get_it` import,
      app-specific branding/theming not needed to demonstrate the SDK,
      the map-based site widget if it's not pulling its weight.
- [ ] 3.4 Replace the hardcoded Tuya App Key/Secret in
      `tuya_configuration.dart` with placeholders + a README note
      telling consumers to supply their own. **Check whether the real
      keys were ever pushed to a remote/public repo** — if so, they
      need rotating on Tuya's side, not just removing from the
      working tree.
- [ ] 3.5 Decide root repo layout: does the root `example` app
      (currently `pubspec.yaml` name `example`) get replaced entirely
      by pointing at the new `packages/flutter_tuya_sdk/example/`, or
      does it stay as a separate full demo alongside the package's
      minimal example? Resolve this before finishing the move — don't
      leave two divergent copies of the same app.
- [ ] 3.6 `flutter analyze` and a build (`flutter build apk --debug`
      at minimum) clean in `example/`.

## 4. Flutter/Dart compatibility refresh

- [ ] 4.1 Check installed Flutter/Dart version (`flutter --version`)
      and set `environment.sdk` / `flutter:` in
      `packages/flutter_tuya_sdk/pubspec.yaml` to match current
      stable (currently stale `^3.7.2` / `>=3.3.0`).
- [ ] 4.2 `flutter pub outdated` in the package; bump
      `plugin_platform_interface` and `flutter_lints` to current
      majors; fix lints introduced by the bump.
- [ ] 4.3 Android: verify Kotlin/AGP/Gradle wrapper versions against
      current Flutter template defaults; verify
      `thingsmart`/`BizBundlesBom`/`thingsmart-ipcsdk`/
      `thingsmart-lock-sdk`/`soloader` versions still resolve from
      Tuya's Maven repo.
- [ ] 4.4 iOS: verify Swift version and minimum iOS deployment target
      against current Xcode/CocoaPods expectations; verify the
      `ThingSmartCryption` pod setup in the README still matches
      Tuya's current SDK distribution.
- [ ] 4.5 `flutter analyze` and `flutter test` inside the package;
      fix any breakage from the version bumps.

## 5. pub.dev publish compliance

- [ ] 5.1 `pubspec.yaml`: real `description` (60–180 chars), valid
      `homepage`/`repository`/`issue_tracker`, `topics` list, no
      `publish_to: none` on the package itself.
- [ ] 5.2 `CHANGELOG.md`: add a genuine first-release entry (decide
      `0.1.0` vs `1.0.0`) replacing the placeholder line.
- [ ] 5.3 `README.md`:
      - Add a **Prerequisites** section before the installation steps:
        Tuya IoT Platform account + registered app (App Key/Secret),
        downloaded Tuya iOS SDK bundle, minimum Flutter/Dart SDK
        version, minimum Android `minSdkVersion`/iOS deployment
        target, network access to Tuya's Maven/CocoaPods sources.
      - Add Flutter and Tuya icons/badges near the title, sourced from
        their official brand assets, hosted locally under
        `packages/flutter_tuya_sdk/assets/readme/`, referenced via
        relative markdown image links. **Confirm logo usage terms
        before including them** — don't assume blanket permission.
      - Verify heading structure and internal links render cleanly on
        pub.dev.
- [ ] 5.4 Add/verify dartdoc-style comments on the package's public
      API surface (pub.dev scores this).
- [ ] 5.5 Run `flutter pub publish --dry-run` inside the package;
      resolve every warning/error.

## 6. Final verification (do not skip)

- [ ] 6.1 `flutter analyze` clean in both the package and
      `example/`.
- [ ] 6.2 `flutter test` passes in the package.
- [ ] 6.3 `example/` builds for Android; iOS build verified if a
      Mac/Xcode is available in the delegate's environment — flag if
      not, don't fake it.
- [ ] 6.4 `flutter pub publish --dry-run` passes with no errors.

---

## Explicitly out of scope (do not do these)

- Actually running `flutter pub publish` — that's a one-way, public
  action requiring separate explicit sign-off, not part of this task
  list.
- Setting up CI/CD for the package.
- Adding new SDK features beyond what already exists.
