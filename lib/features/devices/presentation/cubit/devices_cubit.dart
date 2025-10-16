import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_flutter_ha_sdk/models/user_model.dart';
import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk.dart';

part 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  DevicesCubit() : super(DevicesInitial());

  int? currentHomeId;
  Future<void> loadHomes() async {
    emit(DevicesLoading());
    final homes = await TuyaFlutterHaSdk.getHomeList();
    if (homes.isEmpty) {
      emit(DevicesError(message: 'No homes found'));
      return;
    } else {
      emit(HomesLoaded());
    }
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
