import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk.dart';

import 'data/model/discover_device_model.dart';

part 'connection_state.dart';

class ConnecitonCubit extends Cubit<ConnectionState> {
  ConnecitonCubit() : super(OnboardingIdle());

  StreamSubscription<DiscoveredDevice>? _wifiSub;
  StreamSubscription<DiscoveredDevice>? _bleSub;

  Timer? _countdownTimer;
  Timer? _pollTimer;

  int _secondsLeft = 0;
  bool isScanning = false;

  DiscoveredDevice? device; // last found (Wi-Fi)
  DiscoveredDevice? bleDevice; // last found (BLE)
  StreamSubscription<Map<String, dynamic>>? _pairingSub;

  void _ensurePairingEventsSubscribed() {
    _pairingSub ??= TuyaFlutterHaSdk.pairingEvents.listen(
      (ev) {
        final type = ev['type'] as String? ?? '';

        switch (type) {
          // Wi-Fi activator
          case 'wifi.onStep':
            final step = (ev['step'] ?? '') as String;
            // Optional: reflect steps to UI (e.g., smart_config, device_found, active, etc.)
            // emit a progress state or log
            break;

          case 'wifi.onError':
            final msg = (ev['errorMessage'] ?? 'Activation error') as String;
            emit(OnboardingError(msg));
            break;

          case 'wifi.onActiveSuccess':
            final found = _mapSingle(ev, fallbackType: 'wifi');
            if (found != null) {
              device = found;
              emit(OnboardingDevicesFound([found], protocol: 'wifi'));
              emit(OnboardingPairedSuccess(found));
            }
            break;

          // BLE discovery helper (if you want realtime instead of polling)
          case 'ble.onScanResult':
            final found = _mapSingle(ev, fallbackType: 'ble');
            if (found != null) {
              bleDevice = found;
              emit(OnboardingDevicesFound([found], protocol: 'ble'));
            }
            break;

          // Device lifecycle (after pairing)
          case 'device.onStatusChanged':
            final online = ev['online'] == true;
            // emit some device status state, if you keep it in Cubit
            break;

          case 'device.onDpUpdate':
            // parse ev['dps'] json string if you need, then update UI/state
            break;

          case 'device.onRemoved':
            // handle removal
            break;
        }
      },
      onError: (e) {
        emit(OnboardingError('Pairing stream error: $e'));
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Wi-Fi (EZ / AP)
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> startWifiScan({
    required int homeId,
    required String ssid,
    required String wifiPassword,
    required String mode, // "EZ" or "AP"
    int timeoutSeconds = 120,
  }) async {
    try {
      if (isScanning) await _stopAll();
      isScanning = true;

      _startCountdown(timeoutSeconds, 'wifi');

      final token = await TuyaFlutterHaSdk.getToken(homeId: homeId);
      if (token == null || token.isEmpty) {
        emit(OnboardingError("Failed to get token for homeId: $homeId"));
        await _stopAll();
        return;
      }

      final raw = await TuyaFlutterHaSdk.startConfigWiFi(
        mode: mode,
        ssid: ssid,
        password: wifiPassword,
        token: token,
        timeout: timeoutSeconds,
      );

      final found = _mapSingle(raw, fallbackType: 'wifi');
      if (found != null) {
        device = found;
        emit(OnboardingDevicesFound([device!], protocol: 'wifi'));
        emit(OnboardingPairedSuccess(device!)); // activator = paired
      } else {
        emit(const OnboardingError('Activator returned no device details'));
      }

      await _stopAll();
    } catch (e) {
      emit(OnboardingError(e.toString()));
      await _stopAll();
    }
  }

  Future<void> stopWifiScan() async {
    await _stopAll();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BLE (Bluetooth Low Energy)
  // NOTE: discoverDeviceInfo (native) “Scans for the first inactivated BLE device
  // advertising Tuya packets” and then stops the scan internally.
  // So we poll it; once it returns a device ONCE, we emit it and STOP polling.
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> startBleScan({int timeoutSeconds = 30}) async {
    try {
      if (isScanning) await _stopAll();
      isScanning = true;
      bleDevice = null;

      _startCountdown(timeoutSeconds, 'ble');

      // Poll every 2s. Each call starts a short scan under the hood and returns
      // the FIRST inactivated Tuya BLE device if found, then ends the native scan.
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        if (!isScanning || bleDevice != null) return;
        try {
          final raw = await TuyaFlutterHaSdk.discoverDeviceInfo();
          final found = _mapSingle(raw, fallbackType: 'ble');
          if (found != null) {
            bleDevice = found;
            emit(OnboardingDevicesFound([bleDevice!], protocol: 'ble'));

            // We STOP polling right after the first result, because the native
            // method already stops scanning after first hit.
            _pollTimer?.cancel();
            _pollTimer = null;
          }
        } catch (e) {
          log('discoverDeviceInfo (ble) error: $e');
        }
      });
    } catch (e) {
      emit(OnboardingError(e.toString()));
      await _stopAll();
    }
  }

  Future<void> stopBleScan() async {
    await _stopAll();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Pair button
  // Wi-Fi: pairing happens during startConfigWiFi → just stop & success.
  // BLE: call pairBleDevice with homeId, uuid, productId (and optional extras).
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> pairSelected(
    DiscoveredDevice selected, {
    int? homeId, // REQUIRED for BLE
    int timeoutSeconds = 120,
  }) async {
    try {
      emit(OnboardingPairing(selected));

      final type = (selected.deviceType ?? '').toLowerCase().trim();
      if (type == 'wifi') {
        await _stopAll();
        emit(OnboardingPairedSuccess(selected));
        return;
      }

      if (type == 'ble' || type.isEmpty) {
        if (homeId == null) {
          throw Exception('homeId is required to pair BLE device');
        }
        final uuid = selected.uuid ?? selected.id;
        final productId = selected.productId ?? '';
        if (uuid.isEmpty || productId.isEmpty) {
          throw Exception('Missing BLE identifiers (uuid/productId)');
        }

        // Optional extras if available
        await TuyaFlutterHaSdk.pairBleDevice(
          uuid: uuid,
          productId: productId,
          homeId: homeId,
          address: selected.address,
          deviceType: 0, // use 0 unless you know exact type
          timeout: timeoutSeconds,
          flag: selected.flag != null ? int.tryParse(selected.flag!) : null,
        );

        await _stopAll();
        emit(OnboardingPairedSuccess(selected));
        return;
      }

      throw Exception(
        'Unsupported device type for pairing: ${selected.deviceType}',
      );
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> _stopAll() async {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _pollTimer = null;
    _countdownTimer = null;
    isScanning = false;

    // Safe to call even if Wi-Fi activator isn’t running.
    try {
      await TuyaFlutterHaSdk.stopConfigWiFi();
    } catch (_) {}

    emit(OnboardingIdle());
  }

  void _startCountdown(int seconds, String protocol) {
    _secondsLeft = seconds;
    emit(OnboardingScanning(protocol: protocol, secondsLeft: _secondsLeft));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isScanning) {
        t.cancel();
        return;
      }
      _secondsLeft -= 1;
      if (_secondsLeft <= 0) {
        t.cancel();
        if (protocol == 'wifi') {
          stopWifiScan();
        } else {
          stopBleScan();
        }
      } else {
        emit(OnboardingScanning(protocol: protocol, secondsLeft: _secondsLeft));
      }
    });
  }

  /// Map a **single** device (Map or first of List) → DiscoveredDevice
  DiscoveredDevice? _mapSingle(dynamic raw, {required String fallbackType}) {
    if (raw == null) return null;

    Map<String, dynamic>? src;
    if (raw is Map) {
      src = raw.cast<String, dynamic>();
    } else if (raw is List && raw.isNotEmpty && raw.first is Map) {
      src = (raw.first as Map).cast<String, dynamic>();
    } else {
      return null;
    }

    final m = <String, dynamic>{
      'id': (src['devId'] ?? src['id'] ?? src['uuid'] ?? '').toString(),
      'name': (src['name'] ?? src['deviceName'] ?? 'Device').toString(),
      'productId': src['productId'] ?? src['pid'],
      'uuid': src['uuid'],
      'mac': src['mac'],
      'providerName': src['providerName'],
      'flag': src['flag']?.toString(),
      'address': src['address'],
      'bleType': src['bleType'],
      'deviceType': (src['deviceType'] ?? fallbackType).toString(),
      'configType': src['configType'],
      'ip': src['ip'],
    };

    final id = (m['id'] as String);
    if (id.isEmpty) return null;
    return DiscoveredDevice.fromMap(m);
  }

  @override
  Future<void> close() {
    _wifiSub?.cancel();
    _bleSub?.cancel();
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
