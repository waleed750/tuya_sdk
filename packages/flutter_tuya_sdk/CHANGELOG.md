## 0.1.0

* First public release of `flutter_tuya_sdk` (renamed from `tuya_flutter_ha_sdk`).
* Flutter plugin wrapper for Tuya Home Automation on iOS and Android: user management (login/register, profile, logout), home/room/device management, Wi-Fi/BLE/combo device pairing, device control (DPS, rename, remove, factory reset), smart-lock (BLE/Wi-Fi unlock, dynamic password, Matter), and camera/IPC (list, capabilities, live preview, alerts, DP configs).
* Android package `com.waleedashraf.flutter_tuya_sdk`, iOS module `flutter_tuya_sdk`; method channel `flutter_tuya_sdk` / event channel `flutter_tuya_sdk/pairingEvents`.
* Example app at `example/` demonstrating SDK init, auth flow, home/device list, Wi-Fi/BLE onboarding and lock control.
