import '../../../../core/result.dart';
import '../repositories/i_auth_repo.dart';

class PollVerificationUseCase {
  final IAuthRepository repository;

  PollVerificationUseCase(this.repository);

  Future<Result<bool>> call(String email) {
    return repository.isEmailVerified(email);
  }
}