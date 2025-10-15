import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/list_devices_usecase.dart';

part 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final ListDevicesUseCase _listDevicesUseCase;

  DevicesCubit({
    required ListDevicesUseCase listDevicesUseCase,
  })  : _listDevicesUseCase = listDevicesUseCase,
        super(DevicesInitial());

  Future<void> loadDevices() async {
    emit(DevicesLoading());

    final result = await _listDevicesUseCase();

    result.fold(
      (failure) => emit(DevicesError(message: failure.message)),
      (devices) => emit(DevicesLoaded(devices: devices)),
    );
  }

  Future<void> refreshDevices() async {
    // Keep current devices visible during refresh
    final currentState = state;
    if (currentState is DevicesLoaded) {
      emit(DevicesRefreshing(devices: currentState.devices));
    } else {
      emit(DevicesLoading());
    }

    final result = await _listDevicesUseCase();

    result.fold(
      (failure) => emit(DevicesError(message: failure.message)),
      (devices) => emit(DevicesLoaded(devices: devices)),
    );
  }
}