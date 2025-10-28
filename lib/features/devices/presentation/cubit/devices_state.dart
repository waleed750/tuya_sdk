part of 'devices_cubit.dart';

abstract class DevicesState extends Equatable {
  const DevicesState();

  @override
  List<Object?> get props => [identityHashCode(this)];
}

final class DevicesInitial extends DevicesState {}

final class DevicesLoading extends DevicesState {}

final class DevicesRefreshing extends DevicesState {
  const DevicesRefreshing();
}

final class DevicesLoaded extends DevicesState {}

final class DevicesError extends DevicesState {
  final String message;

  const DevicesError({required this.message});

  @override
  List<Object> get props => [message];
}

final class HomesLoaded extends DevicesState {}

final class HomesLoading extends DevicesState {}

final class HomeSelected extends DevicesState {}

final class SSIDLoaded extends DevicesState {}

class HomeAdded extends DevicesState {}

class DeviceStateLoading extends DevicesState {
  final String deviceId;
  const DeviceStateLoading({required this.deviceId});
}

class DeviceStateChanged extends DevicesState {
  final String deviceId;
  const DeviceStateChanged({required this.deviceId});
}

class DeviceErrorChangedState extends DevicesState {
  final String deviceId;
  final String errorMessage;
  const DeviceErrorChangedState({
    required this.deviceId,
    required this.errorMessage,
  });
}
