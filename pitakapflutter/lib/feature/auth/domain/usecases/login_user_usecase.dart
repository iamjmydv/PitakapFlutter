import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class LoginUseCaseParams {
  final String email;
  final String password;

  const LoginUseCaseParams({required this.email, required this.password});
}

class LoginUserUseCase
    implements UseCaseWithParams<UserDetailsEntity, LoginUseCaseParams> {
  final AuthRepository repository;

  const LoginUserUseCase(this.repository);

  @override
  Future<UserDetailsEntity> call(LoginUseCaseParams params) {
    return repository.login(params);
  }
}
