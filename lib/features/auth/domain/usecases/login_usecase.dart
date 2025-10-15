import '../../../../core/result.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repo.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<AuthUser>> call(String email, String password) {
    return repository.login(email, password);
  }
}