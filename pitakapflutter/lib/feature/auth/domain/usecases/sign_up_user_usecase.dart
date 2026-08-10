import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class SignUpUseCaseParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const SignUpUseCaseParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class SignUpUserUseCase
    implements UseCaseWithParams<UserDetailsEntity, SignUpUseCaseParams> {
  final AuthRepository repository;

  const SignUpUserUseCase(this.repository);

  @override
  Future<UserDetailsEntity> call(SignUpUseCaseParams params) {
    return repository.signUp(params);
  }
}
