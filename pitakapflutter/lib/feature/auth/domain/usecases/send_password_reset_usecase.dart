import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class SendPasswordResetUseCaseParams {
  final String email;

  const SendPasswordResetUseCaseParams({required this.email});
}

class SendPasswordResetUseCase
    implements UseCaseWithParams<void, SendPasswordResetUseCaseParams> {
  final AuthRepository repository;

  const SendPasswordResetUseCase(this.repository);

  @override
  Future<void> call(SendPasswordResetUseCaseParams params) {
    return repository.sendPasswordReset(params);
  }
}
