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
  DevicesCubit() : super(DevicesInitial());

  int? currentHomeId;
  List<ThingSmartHomeModel>? currentHomes;
  ThingSmartUserModel? currentDevice;
  String? currentSSID;

  Timer? _scanTimer;
  Timer? _pollTimer;
  bool _isScanning = false;

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
    emit(DevicesLoading());
    final devices = await TuyaFlutterHaSdk.getHomeDevices(
      homeId: currentHomeId ?? 0,
    );
    if (devices.isEmpty) {
      emit(DevicesError(message: 'No devices found'));
      return;
    } else {
      emit(DevicesLoaded());
    }
  }
}
