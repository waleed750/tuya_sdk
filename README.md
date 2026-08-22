# tuya_sdk

> **Repository layout note (2026-08-22):** This repo intentionally holds two separate projects. `packages/flutter_tuya_sdk/` is the publishable plugin, with its own pub.dev-ready example at `packages/flutter_tuya_sdk/example/` (trimmed minimal demo: SDK init, auth, home/device list, WiFi/BLE onboarding, lock control). The full SyncN app at the repository root (`lib/`, `android/`, `ios/`) is a separate, ongoing consumer project — it is kept, not legacy, and is not scheduled for removal. The plugin is pushed to its own GitHub repository (`flutter_tuya_sdk`) for publishing; this repository continues to host the SyncN app work.

## Getting Started

This repository contains two independent projects:

- `packages/flutter_tuya_sdk/` — the Flutter plugin (renamed from `tuya_flutter_ha_sdk`, package ID `com.waleedashraf.flutter_tuya_sdk`), published from its own GitHub repository.
- `packages/flutter_tuya_sdk/example/` — the plugin's canonical minimal example (pub.dev convention).
- `lib/` (repo root) — the SyncN app, a separate ongoing project that consumes the plugin via a local path dependency.

For plugin usage, see `packages/flutter_tuya_sdk/README.md`.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).
