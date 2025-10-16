part of 'devices_cubit.dart';

abstract class DevicesState extends Equatable {
  const DevicesState();

  @override
  List<Object?> get props => [];
}

class DevicesInitial extends DevicesState {}

class DevicesLoading extends DevicesState {}

class DevicesRefreshing extends DevicesState {
  const DevicesRefreshing();
}

class DevicesLoaded extends DevicesState {}

class DevicesError extends DevicesState {
  final String message;

  const DevicesError({required this.message});

  @override
  List<Object> get props => [message];
}

class HomesLoaded extends DevicesState {}

class HomesLoading extends DevicesState {}
