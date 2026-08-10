import 'package:pitakapflutter/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  const AuthRepositoryImpl(this.remote);

  @override
  Future<UserDetailsEntity> signUp(SignUpUseCaseParams params) {
    return remote.signUp(params);
  }

  @override
  Future<UserDetailsEntity> login(LoginUseCaseParams params) {
    return remote.login(params);
  }

  @override
  Future<void> sendPasswordReset(SendPasswordResetUseCaseParams params) {
    return remote.sendPasswordReset(params);
  }

  @override
  Future<void> signOut() => remote.signOut();
}
