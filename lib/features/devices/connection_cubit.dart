import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../services/tuya_onboarding_service.dart';

part 'connection_state.dart';

class ConnecitonCubit extends Cubit<ConnectionState> {
  final TuyaOnboardingService _service;
  StreamSubscription<DiscoveredDevice>? _wifiSub;
  StreamSubscription<DiscoveredDevice>? _bleSub;
  Timer? _countdownTimer;
  int _secondsLeft = 0;
  bool isScanning = false;
  ConnecitonCubit({TuyaOnboardingService? service})
    : _service = service ?? TuyaOnboardingService.instance,
      super(OnboardingIdle());

  void _startCountdown(int seconds, String protocol) {
    _countdownTimer?.cancel();
    _secondsLeft = seconds;
    emit(OnboardingScanning(protocol: protocol, secondsLeft: _secondsLeft));
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (t) {
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

  Future<void> startWifiScan() async {
    try {
      emit(OnboardingScanning(protocol: 'wifi', secondsLeft: 30));
      await _service.startWifiDiscovery();
      _wifiSub?.cancel();
      isScanning = true;

      final devices = <DiscoveredDevice>[];
      _wifiSub = _service.wifiDiscoveryStream().listen((d) {
        devices.removeWhere((e) => e.id == d.id);
        devices.add(d);
        emit(
          OnboardingDevicesFound(List.unmodifiable(devices), protocol: 'wifi'),
        );
      });
      _startCountdown(30, 'wifi');
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> stopWifiScan() async {
    _wifiSub?.cancel();
    _countdownTimer?.cancel();
    isScanning = false;
    try {
      await _service.stopWifiDiscovery();
    } catch (_) {}
    emit(OnboardingIdle());
  }

  Future<void> startBleScan() async {
    try {
      emit(OnboardingScanning(protocol: 'ble', secondsLeft: 30));
      await _service.startBleScan();
      isScanning = true;
      _bleSub?.cancel();
      final devices = <DiscoveredDevice>[];
      _bleSub = _service.bleDiscoveryStream().listen((d) {
        devices.removeWhere((e) => e.id == d.id);
        devices.add(d);
        emit(
          OnboardingDevicesFound(List.unmodifiable(devices), protocol: 'ble'),
        );
      });
      _startCountdown(30, 'ble');
    } catch (e) {
      isScanning = false;
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> stopBleScan() async {
    _bleSub?.cancel();
    _countdownTimer?.cancel();
    isScanning = false;
    try {
      await _service.stopBleScan();
    } catch (_) {}
    emit(OnboardingIdle());
  }

  Future<void> pairSelected(DiscoveredDevice device) async {
    try {
      emit(OnboardingPairing(device));
      if (device.protocol == 'wifi') {
        await _service.pairWifiDevice(device);
      } else {
        await _service.pairBleDevice(device);
      }
      emit(OnboardingPairedSuccess(device));
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _wifiSub?.cancel();
    _bleSub?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
