# tuya_sdk

> **Repository layout note (2026-08-22):** The canonical, pub.dev-ready example for the `flutter_tuya_sdk` plugin lives at `packages/flutter_tuya_sdk/example/` (trimmed minimal demo: SDK init, auth, home/device list, WiFi/BLE onboarding, lock control). The original full SyncN consumer app that remains at the repository root (`lib/`, `android/`, `ios/`) is legacy / to-be-removed and will be deleted once the trimmed example is verified via `flutter analyze` + `flutter build apk --debug` in the next verification step. Do not add new features to the root app. The actual plugin source is `packages/flutter_tuya_sdk/`.

## Getting Started

This repository contains:

- `packages/flutter_tuya_sdk/` — the Flutter plugin (renamed from `tuya_flutter_ha_sdk`, package ID `com.waleedashraf.flutter_tuya_sdk`).
- `packages/flutter_tuya_sdk/example/` — **canonical minimal example** (pub.dev convention).
- `lib/` (repo root) — legacy full SyncN demo app (duplicated before the trimmed example was created).

For plugin usage, see `packages/flutter_tuya_sdk/README.md`.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).
