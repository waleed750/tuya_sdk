import '../../../../core/result.dart';
import '../entities/device_entity.dart';
import '../repositories/i_devices_repo.dart';

class ListDevicesUseCase {
  final IDevicesRepository repository;

  ListDevicesUseCase(this.repository);

  Future<Result<List<DeviceEntity>>> call() {
    return repository.listDevices();
  }
}