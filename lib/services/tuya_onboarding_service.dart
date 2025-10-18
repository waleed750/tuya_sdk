import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DiscoveredDevice {
  final String id;
  final String name;
  final String protocol; // 'wifi' | 'ble'
  final int? rssi;
  final IconData? icon;

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.protocol,
    this.rssi,
    this.icon,
  });
}

/// Simple wrapper for the Tuya onboarding SDK.
/// Replace TODOs with calls into the real SDK implementation.
class TuyaOnboardingService {
  // Singleton for convenience
  TuyaOnboardingService._private();
  static final TuyaOnboardingService instance =
      TuyaOnboardingService._private();

  // Internal controllers for streams so UI can listen.
  final StreamController<DiscoveredDevice> _wifiController =
      StreamController.broadcast();
  final StreamController<DiscoveredDevice> _bleController =
      StreamController.broadcast();

  Future<void> startWifiDiscovery() async {
    // TODO: call actual Tuya SDK to start Wi-Fi discovery (EZ/AP)
    // For now emit a fake device after a short delay to simulate discovery.
    Future.delayed(Duration(seconds: 2), () {
      _wifiController.add(
        DiscoveredDevice(
          id: 'wifi-001',
          name: 'Tuya WiFi Device',
          protocol: 'wifi',
          rssi: null,
          icon: Icons.electrical_services,
        ),
      );
    });
  }

  Future<void> stopWifiDiscovery() async {
    // TODO: call SDK stop
  }

  Stream<DiscoveredDevice> wifiDiscoveryStream() => _wifiController.stream;

  Future<void> pairWifiDevice(DiscoveredDevice device) async {
    // TODO: call SDK pair api
    await Future.delayed(Duration(seconds: 3));
  }

  Future<void> startBleScan() async {
    // TODO: start BLE scan via SDK
    Future.delayed(Duration(seconds: 1), () {
      _bleController.add(
        DiscoveredDevice(
          id: 'ble-001',
          name: 'Tuya BLE Device',
          protocol: 'ble',
          rssi: -60,
          icon: Icons.radar,
        ),
      );
    });
  }

  Future<void> stopBleScan() async {
    // TODO: stop BLE scan
  }

  Stream<DiscoveredDevice> bleDiscoveryStream() => _bleController.stream;

  Future<void> pairBleDevice(DiscoveredDevice device) async {
    // TODO: call SDK pair api for BLE
    await Future.delayed(Duration(seconds: 2));
  }

  void dispose() {
    _wifiController.close();
    _bleController.close();
  }
}
