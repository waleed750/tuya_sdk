import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Returns true only if:
/// 1) Required Bluetooth permissions are granted
/// 2) Bluetooth adapter is ON
///
/// It will SHOW the runtime permission prompt when needed.
/// It does NOT scan or connect to any device.
class BluetoothUtils {
  static Future<bool> ensureBluetoothReady() async {
    // Determine Android SDK (affects which permissions we ask for)
    int androidSdk = 0;
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      androidSdk = info.version.sdkInt;
    }

    // Pick proper permissions for the platform/version
    final perms = <Permission>[
      if (Platform.isAndroid && androidSdk >= 31) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ] else if (Platform.isAndroid) ...[
        // Pre-Android 12: classic permissions (no runtime “scan/connect”)
        Permission.bluetooth,
      ] else if (Platform.isIOS) ...[
        Permission.bluetooth,
      ],
    ];

    // Request permissions (shows the system dialog if not granted)
    final statuses = await perms.request();

    // If any permanently denied, return false (you can direct user to settings in UI)
    if (statuses.values.any((s) => s.isPermanentlyDenied)) {
      return false;
    }
    // If any denied (not granted), return false
    if (statuses.values.any((s) => !s.isGranted)) {
      return false;
    }

    // Check adapter state (no scanning)
    final state = await FlutterBluePlus.adapterState.first;
    return state.name == BluetoothAdapterState.on.name;
  }
}
