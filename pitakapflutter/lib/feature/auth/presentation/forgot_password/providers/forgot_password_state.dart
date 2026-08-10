sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitialState extends ForgotPasswordState {
  const ForgotPasswordInitialState();
}

class ForgotPasswordLoadingState extends ForgotPasswordState {
  const ForgotPasswordLoadingState();
}

class ForgotPasswordSentState extends ForgotPasswordState {
  final String email;

  const ForgotPasswordSentState(this.email);
}

class ForgotPasswordFailedState extends ForgotPasswordState {
  final String message;

  const ForgotPasswordFailedState(this.message);
}
