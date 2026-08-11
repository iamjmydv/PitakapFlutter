import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/providers/auth_providers.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/providers/forgot_password_state.dart';

class ForgotPasswordController extends AsyncNotifier<ForgotPasswordState> {
  @override
  FutureOr<ForgotPasswordState> build() =>
      const ForgotPasswordInitialState();

  bool get isBusy => state.value is ForgotPasswordLoadingState;

  Future<void> submit(SendPasswordResetUseCaseParams params) async {
    if (isBusy) return;

    state = const AsyncValue.data(ForgotPasswordLoadingState());

    final result = await AsyncValue.guard(
      () => ref.read(sendPasswordResetUseCaseProvider).call(params),
    );

    state = AsyncValue.data(
      switch (result) {
        AsyncData() => ForgotPasswordSentState(params.email),
        AsyncError(:final error) =>
          ForgotPasswordFailedState(failureMessage(error)),
        _ => const ForgotPasswordLoadingState(),
      },
    );
  }

  void reset() => state = const AsyncValue.data(ForgotPasswordInitialState());
}

final forgotPasswordControllerProvider = AsyncNotifierProvider.autoDispose<
    ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);
