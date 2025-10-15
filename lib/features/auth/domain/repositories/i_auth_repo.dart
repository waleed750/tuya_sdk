import '../../../../core/result.dart';
import '../entities/auth_user.dart';

abstract class IAuthRepository {
  Future<Result<void>> sendVerificationEmail(String email);
  Future<Result<bool>> isEmailVerified(String email);
  Future<Result<AuthUser>> register(String email, String password);
  Future<Result<AuthUser>> login(String email, String password);
  Future<Result<void>> createHome({
    required String name,
    required String timeZoneId,
    required double lat,
    required double lon,
    String? geoName,
  });
}