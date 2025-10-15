import '../../../../core/result.dart';
import '../repositories/i_auth_repo.dart';

class CreateHomeIfNewUseCase {
  final IAuthRepository repository;

  CreateHomeIfNewUseCase(this.repository);

  Future<Result<void>> call({
    required String name,
    required String timeZoneId,
    required double lat,
    required double lon,
    String? geoName,
  }) {
    return repository.createHome(
      name: name,
      timeZoneId: timeZoneId,
      lat: lat,
      lon: lon,
      geoName: geoName,
    );
  }
}