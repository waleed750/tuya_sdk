import '../../../../core/result.dart';
import '../repositories/i_auth_repo.dart';

class SendVerificationUseCase {
  final IAuthRepository repository;

  SendVerificationUseCase(this.repository);

  Future<Result<void>> call(String email) {
    return repository.sendVerificationEmail(email);
  }
}