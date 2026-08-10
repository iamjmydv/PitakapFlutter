import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class SignOutUseCase implements UseCase<void> {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  @override
  Future<void> call() => repository.signOut();
}
