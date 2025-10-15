import '../../../../core/result.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repo.dart';

class RegisterAfterVerifiedUseCase {
  final IAuthRepository repository;

  RegisterAfterVerifiedUseCase(this.repository);

  Future<Result<AuthUser>> call(String email, String password) {
    return repository.register(email, password);
  }
}