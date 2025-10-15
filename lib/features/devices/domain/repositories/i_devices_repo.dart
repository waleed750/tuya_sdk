import '../../../../core/result.dart';
import '../entities/device_entity.dart';

abstract class IDevicesRepository {
  Future<Result<List<DeviceEntity>>> listDevices();
}