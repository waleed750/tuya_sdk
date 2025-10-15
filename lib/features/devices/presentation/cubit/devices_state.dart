part of 'devices_cubit.dart';

abstract class DevicesState extends Equatable {
  const DevicesState();

  @override
  List<Object?> get props => [];
}

class DevicesInitial extends DevicesState {}

class DevicesLoading extends DevicesState {}

class DevicesRefreshing extends DevicesState {
  final List<DeviceEntity> devices;

  const DevicesRefreshing({required this.devices});

  @override
  List<Object> get props => [devices];
}

class DevicesLoaded extends DevicesState {
  final List<DeviceEntity> devices;

  const DevicesLoaded({required this.devices});

  @override
  List<Object> get props => [devices];
}

class DevicesError extends DevicesState {
  final String message;

  const DevicesError({required this.message});

  @override
  List<Object> get props => [message];
}