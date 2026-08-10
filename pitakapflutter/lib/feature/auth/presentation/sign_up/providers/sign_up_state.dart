import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';

sealed class SignUpState {
  const SignUpState();
}

class SignUpInitialState extends SignUpState {
  const SignUpInitialState();
}

class SignUpLoadingState extends SignUpState {
  const SignUpLoadingState();
}

class SignUpSuccessState extends SignUpState {
  final UserDetailsEntity user;

  const SignUpSuccessState(this.user);
}

class SignUpFailedState extends SignUpState {
  final String message;

  const SignUpFailedState(this.message);
}
