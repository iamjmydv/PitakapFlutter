import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitialState extends LoginState {
  const LoginInitialState();
}

class LoginLoadingState extends LoginState {
  const LoginLoadingState();
}

class LoginGoogleLoadingState extends LoginState {
  const LoginGoogleLoadingState();
}

class LoginSuccessState extends LoginState {
  final UserDetailsEntity user;

  const LoginSuccessState(this.user);
}

class LoginFailedState extends LoginState {
  final String message;

  const LoginFailedState(this.message);
}
