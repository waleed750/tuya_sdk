import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  PermissionsService._private();
  static final PermissionsService instance = PermissionsService._private();

  Future<bool> ensureWifiScanPermissions(BuildContext context) async {
    // On many platforms Wi-Fi scanning requires location.
    final status = await Permission.location.status;
    if (status.isGranted) return true;

    final result = await Permission.location.request();
    if (result.isGranted) return true;

    // Show rationale
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Permission required'),
          content: Text(
            'Location permission is required to discover devices over Wi‑Fi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
    return false;
  }

  Future<bool> ensureBlePermissions(BuildContext context) async {
    // Request Bluetooth permissions where applicable.
    final List<Permission> perms = [];
    // Android 12+ split Bluetooth permissions
    perms.add(Permission.bluetoothScan);
    perms.add(Permission.bluetoothConnect);
    perms.add(Permission.location);

    final statuses = await perms.request();
    final ok = statuses.values.every((s) => s.isGranted || s.isLimited);
    if (ok) return true;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Bluetooth permission'),
          content: Text(
            'Bluetooth permissions are required to scan and pair devices.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
    return false;
  }
}
