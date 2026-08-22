# iOS verification checklist — flutter_tuya_sdk

Everything below was renamed/edited on Windows and never compiled on
iOS (no Xcode/macOS available in that environment). Text-level review
looks consistent, but only a real build proves it. Run through this on
a Mac.

## 0. One-time setup

- [ ] Download the Tuya iOS SDK bundle from your Tuya IoT Platform app
      page (contains `ios_core_sdk/` + a sample `Podfile`).
- [ ] Copy `ios_core_sdk/` into `packages/flutter_tuya_sdk/example/ios/`.
- [ ] The example has **no `Podfile` yet** — it was never created,
      since it depends on the Tuya bundle above. Create
      `packages/flutter_tuya_sdk/example/ios/Podfile` following
      `packages/flutter_tuya_sdk/README.md`'s installation section:
      add the `TuyaPublicSpecs`/`tuya-pod-specs` sources, `platform
      :ios, '12.0'`, `pod 'ThingSmartCryption', :path => 'ios_core_sdk'`,
      and `use_frameworks! :linkage => :static`.
- [ ] Fill in real Tuya App Key/Secret in
      `example/lib/tuya_configuration.dart` (currently placeholders —
      `YOUR_TUYA_IOS_APP_KEY` / `YOUR_TUYA_IOS_APP_SECRET`).

## 1. Pod install / dependency resolution

- [ ] `cd packages/flutter_tuya_sdk/example/ios && pod install` —
      confirm it resolves `ThingSmartPanelBizBundle`,
      `ThingSmartCameraRNPanelBizBundle`, `ThingSmartHomeKit`,
      `ThingSmartOTABizBundle`, `ThingAdvancedFunctionsBizBundle`,
      `ThingSmartLockKit`, `ThingSmartCameraPanelBizBundle`,
      `ThingSmartCameraKit`, `ThingSmartCameraSettingBizBundle`,
      `ThingSmartActivatorExtraBizBundle`, `ThingSmartActivatorBizBundle`,
      `ThingSmartFamilyBizBundle`, `ThingSmartDeviceKit`, and
      `ThingSmartCryption` (from `ios_core_sdk`) without version
      conflicts. These are all pinned to `~> 6.2.0` /
      `~> 5.10.3` in `flutter_tuya_sdk.podspec` — flag here if any of
      them have moved past what's compatible.
- [ ] Confirm no CocoaPods errors about the module name — the podspec
      was renamed `tuya_flutter_ha_sdk` → `flutter_tuya_sdk`
      (`s.name`, `s.module_name`) and the plugin class went
      `TuyaFlutterHaSdkPlugin` → `FlutterTuyaSdkPlugin`. A stale
      derived-data cache or `Podfile.lock` referencing the old name is
      the most likely failure mode — `pod deintegrate && pod install`
      if anything looks inconsistent.

## 2. Build

- [ ] Open `example/ios/Runner.xcworkspace` in Xcode (not `.xcodeproj`).
- [ ] Build for a Simulator target first (faster iteration).
- [ ] Build for a real device — the podspec excludes `i386` for
      simulator but real-device architectures aren't excluded; confirm
      no arch-related link errors against Tuya's binary frameworks.
- [ ] Watch for Swift compiler errors in `Classes/FlutterTuyaSdkPlugin.swift`,
      `Classes/BluetoothPairingManager.swift`,
      `Classes/ThingModelExtensions.swift`,
      `Classes/TuyaCameraPlugin.swift` — these were carried over
      unchanged except the plugin's own class rename; any reference to
      the old class name that a plain grep missed would show up here
      as a compile error, not silently.

## 3. Runtime — method channel wiring

- [ ] Launch the example app, confirm `FlutterTuyaSdk.tuyaSdkInit(...)`
      succeeds at startup (no immediate crash/exception from a
      channel name mismatch — the method channel was renamed
      `tuya_flutter_ha_sdk` → `flutter_tuya_sdk` and the event channel
      `tuya_flutter_ha_sdk/pairingEvents` → `flutter_tuya_sdk/pairingEvents`
      on **both** the Dart and native Swift sides; a typo on either
      side fails silently as "channel not found" rather than a build
      error).
- [ ] Exercise login/register (`FlutterTuyaSdk.loginWithEmail` /
      `registerAccountWithEmail`) — confirms the basic MethodChannel
      round-trip works end-to-end on iOS.
- [ ] Exercise BLE device discovery (`discoverDeviceInfo` /
      `smartBlePairing`) — this is the path most likely to be
      sensitive to entitlements/Info.plist Bluetooth usage strings;
      confirm `Info.plist` still has the Bluetooth permission
      descriptions the original app had.
- [ ] Exercise WiFi pairing (`startConfigWiFi`) and the WiFi+BLE combo
      flow (`startWifiComboPairing` / `wifiBleComboConfig`) — confirms
      the `pairingEvents` EventChannel stream delivers native events
      (`wifi.onStep`, `ble.onScanResult`, etc.) correctly under the
      renamed channel.
- [ ] Exercise camera listing (`TuyaCameraMethods.listCameras`) if you
      have a Tuya camera device available — `TuyaCameraPlugin.swift`
      is a separate plugin registration from the main one, worth
      confirming independently.
- [ ] Exercise a lock action (`unlockBLELock`/`lockBLELock` or
      `controlMatter`) if you have a lock device available.

## 4. Things that are known-unverified and worth double-checking

- [ ] `s.platform = :ios, '12.0'` in the podspec — confirm this is
      still Tuya's actual minimum supported iOS version (unchanged
      from before this task, not re-verified against Tuya's current
      docs).
- [ ] `s.swift_version = '5.0'` — confirm this doesn't trigger a
      warning/error on whatever Xcode version you're using.
- [ ] `s.author` in the podspec still has a placeholder email
      (`waleed@example.com`) — cosmetic, but worth fixing before
      publishing.
- [ ] `PrivacyInfo.xcprivacy` under `ios/Resources/` was carried over
      unchanged — confirm its declared data-use categories still match
      what the renamed plugin actually does (nothing functional
      changed, so this should be fine, but Apple's privacy manifest
      checks are strict about this at App Store review time for
      *your* app, not the plugin itself).

## Report back

Once you've run through this, let me know: which steps passed,
anything that failed (paste the actual Xcode/pod error), and whether
the checklist itself missed anything obvious once you had it open in
Xcode.
