import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_flutter_ha_sdk/models/user_model.dart';
import 'package:tuya_flutter_ha_sdk/models/thing_smart_home_model.dart';

import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk.dart';

part 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  /// Lock the smart lock device (if not already locked)
  Future<void> lockDevice(Map<String, dynamic> deviceMap) async {
    final devId = deviceMap['devId'] ?? deviceMap['id'];
    final dps = deviceMap['dps'] as Map?;
    final isLocked = dps != null && (dps['1'] == 0); // 0 = locked, 1 = unlocked
    if (isLocked) {
      emit(
        DeviceErrorChangedState(
          deviceId: devId,
          errorMessage: 'Device is already locked.',
        ),
      );
      return;
    }
    try {
      await TuyaFlutterHaSdk.controlMatter(
        devId: devId,
        dps: {'1': 0}, // 0 = lock
      );

      emit(DeviceStateChanged(deviceId: devId));
    } catch (e) {
      emit(
        DeviceErrorChangedState(
          deviceId: devId,
          errorMessage: 'Failed to lock: $e',
        ),
      );
    }
  }

  /// Unlock the smart lock device (if not already unlocked)
  Future<void> unlockDevice(Map<String, dynamic> deviceMap) async {
    emit(DeviceStateLoading(deviceId: deviceMap['devId'] ?? deviceMap['id']));
    final devId = deviceMap['devId'] ?? deviceMap['id'];
    final dps = deviceMap['dps'] as Map?;
    final isUnlocked =
        dps != null && (dps['1'] == 1); // 1 = unlocked, 0 = locked
    final ifMatter = await TuyaFlutterHaSdk.checkIsMatter(devId: devId);
    log('isMatter: $ifMatter');
    if (ifMatter) {
      if (isUnlocked) {
        emit(
          DeviceErrorChangedState(
            deviceId: devId,
            errorMessage: 'Device is already unlocked.',
          ),
        );
        return;
      }
      try {
        await TuyaFlutterHaSdk.controlMatter(
          devId: devId,
          dps: {'1': true}, // 1 = unlock
        );
        emit(DeviceStateChanged(deviceId: devId));
      } catch (e) {
        emit(
          DeviceErrorChangedState(
            deviceId: devId,
            errorMessage: 'Failed to unlock: $e',
          ),
        );
      }
    } else {
      try {
        await TuyaFlutterHaSdk.replyRequestUnlock(devId: devId, open: true);
        emit(DeviceStateChanged(deviceId: devId));
      } catch (e) {
        emit(
          DeviceErrorChangedState(
            deviceId: devId,
            errorMessage: 'Failed to unlock: $e',
          ),
        );
      }
    }
  }

  DevicesCubit() : super(DevicesInitial());

  int? currentHomeId;
  List<ThingSmartHomeModel>? currentHomes;
  ThingSmartUserModel? currentDevice;
  String? currentSSID;
  List<Map<String, dynamic>> devices = [];
  final bool _isScanning = false;

  // Map to hold a stream subscription for each device
  final Map<String, StreamSubscription<Map<String, dynamic>>>
  _deviceUnlockStreams = {};

  bool get isScanning => _isScanning;

  Future<void> getCurrentSSID() async {
    try {
      final ssid = await TuyaFlutterHaSdk.getSSID();
      currentSSID = ssid;
      log("← getSSID SUCCESS: ssid=$ssid ");
    } on PlatformException catch (e) {
      log(
        "ERROR getSSID PlatformException -> code=${e.code}, message=${e.message}",
      );
    } catch (e) {
      log("⛔ getSSID FAILED: $e");
    }
    emit(SSIDLoaded());
  }

  Future<void> deleteDevice({required String devId}) async {
    try {
      if (devId.isEmpty) throw Exception('devId is required');
      await TuyaFlutterHaSdk.removeDevice(devId: devId);
      // emit(OnboardingIdle());
      await loadDevices(); // Refresh device list after deletion
    } catch (e) {
      emit(DevicesError(message: e.toString()));
    }
  }

  Future<void> addNewHome({
    required String name,
    required String address,
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    emit(DevicesLoading());
    try {
      final homeId = await TuyaFlutterHaSdk.createHome(
        name: name,
        geoName: address,
        latitude: latitude,
        longitude: longitude,
        rooms: [],
      );
      log("✅ Home created with ID: $homeId");
      emit(HomeAdded());
      await loadHomes(); // Refresh the homes list
    } catch (e) {
      log("⛔ Home creation FAILED: $e");
      emit(DevicesError(message: 'Home creation failed: $e'));
    }
  }

  Future<void> loadHomes() async {
    emit(DevicesLoading());
    currentHomes?.clear();
    final homes = await TuyaFlutterHaSdk.getHomeList();
    if (homes.isEmpty) {
      emit(DevicesError(message: 'No homes found'));
      return;
    } else {
      currentHomes = homes.map((e) => ThingSmartHomeModel.fromJson(e)).toList();
      log(homes.toString());
      emit(HomesLoaded());
    }
  }

  void setHomeId(int homeId) {
    currentHomeId = homeId;
    emit(HomeSelected());
  }

  Future<void> loadDevices() async {
    // Dispose all previous device unlock streams before clearing devices
    for (final sub in _deviceUnlockStreams.values) {
      await sub.cancel();
    }
    _deviceUnlockStreams.clear();
    devices.clear();
    emit(DevicesLoading());
    devices = await TuyaFlutterHaSdk.getHomeDevices(homeId: currentHomeId ?? 0);
    if (devices.isEmpty) {
      emit(DevicesError(message: 'No devices found'));
      return;
    } else {
      // Listen to remote unlock events for each device
      for (final device in devices) {
        final devId = device['devId'] ?? device['id'];
        if (devId != null) {
          await listenToRemoteUnlock(devId);
        }
      }
      emit(DevicesLoaded());
    }
  }

  /// Call this when adding a new device to start listening for remote unlock events
  Future<void> listenToRemoteUnlock(String devId) async {
    // Set the remote unlock listener on the native side
    await TuyaFlutterHaSdk.setRemoteUnlockListener(devId);
    // Cancel any previous subscription for this device
    await _deviceUnlockStreams[devId]?.cancel();
    // Listen to the unlock event stream for this device
    final sub = TuyaFlutterHaSdk.remoteUnlockEventStream?.listen((event) async {
      if (event['devId'] == devId) {
        log('Remote unlock event for $devId: $event');
        // Emit state to show unlock request message
        emit(DeviceRemoteUnlockRequested(deviceId: devId, event: event));
        // Do NOT call replyRemoteUnlock here; let the UI handle unlock action
      }
    });
    if (sub != null) {
      _deviceUnlockStreams[devId] = sub;
    }
  }

  /// Call this to stop listening for a device (e.g., when removing a device)
  Future<void> stopListeningToRemoteUnlock(String devId) async {
    await _deviceUnlockStreams[devId]?.cancel();
    _deviceUnlockStreams.remove(devId);
  }

  @override
  Future<void> close() async {
    // Cancel all device unlock streams when cubit is closed
    for (final sub in _deviceUnlockStreams.values) {
      await sub.cancel();
    }
    _deviceUnlockStreams.clear();
    return super.close();
  }
}
