import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/i_devices_repo.dart';
import '../datasources/tuya_devices_api.dart';

class DevicesRepositoryImpl implements IDevicesRepository {
  final TuyaDevicesApi _devicesApi;

  DevicesRepositoryImpl(this._devicesApi);

  @override
  Future<Result<List<DeviceEntity>>> listDevices() async {
    try {
      final devices = await _devicesApi.listDevices();
      return Result.success(devices);
    } catch (e) {
      return Result.failure(DevicesFailure(message: e.toString()));
    }
  }
}