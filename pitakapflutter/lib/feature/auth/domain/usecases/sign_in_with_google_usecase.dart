import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<UserDetailsEntity?> {
  final AuthRepository repository;

  const SignInWithGoogleUseCase(this.repository);

  @override
  Future<UserDetailsEntity?> call() => repository.signInWithGoogle();
}
