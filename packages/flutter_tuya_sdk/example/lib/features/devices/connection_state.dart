part of 'connection_cubit.dart';

@immutable
abstract class ConnectionState {
  const ConnectionState();
}

class OnboardingIdle extends ConnectionState {
  const OnboardingIdle();
}

class OnboardingScanning extends ConnectionState {
  final String protocol; // 'wifi' | 'ble'
  final int secondsLeft;
  const OnboardingScanning({required this.protocol, required this.secondsLeft});
}

class OnboardingDevicesFound extends ConnectionState {
  final List<DiscoveredDevice> devices;
  final String protocol;
  const OnboardingDevicesFound(this.devices, {required this.protocol});
}

class OnboardingPairing extends ConnectionState {
  final DiscoveredDevice device;
  const OnboardingPairing(this.device);
}

class OnboardingPairedSuccess extends ConnectionState {
  final DiscoveredDevice device;
  const OnboardingPairedSuccess(this.device);
}

class OnboardingError extends ConnectionState {
  final String message;
  const OnboardingError(this.message);
}
