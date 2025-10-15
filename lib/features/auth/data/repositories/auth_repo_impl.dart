import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repo.dart';
import '../datasources/tuya_auth_api.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final TuyaAuthApi _authApi;

  AuthRepositoryImpl(this._authApi);

  @override
  Future<Result<void>> sendVerificationEmail(String email) async {
    try {
      await _authApi.sendVerificationEmail(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(VerificationFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isEmailVerified(String email) async {
    try {
      final isVerified = await _authApi.isEmailVerified(email);
      return Result.success(isVerified);
    } catch (e) {
      return Result.failure(VerificationFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> register(String email, String password) async {
    try {
      final token = await _authApi.register(email, password);
      return Result.success(
        AuthUser(
          uid: token,
          email: email,
          displayName: email.split('@').first,
          token: token,
        ),
      );
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> login(String email, String password) async {
    try {
      final token = await _authApi.login(email, password);
      return Result.success(
        AuthUser(
          uid: token,
          email: email,
          displayName: email.split('@').first,
          token: token,
        ),
      );
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> createHome({
    required String name,
    required String timeZoneId,
    required double lat,
    required double lon,
    String? geoName,
  }) async {
    try {
      await _authApi.createHome(
        name: name,
        timeZoneId: timeZoneId,
        lat: lat,
        lon: lon,
        geoName: geoName,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(HomeCreationFailure(message: e.toString()));
    }
  }
}