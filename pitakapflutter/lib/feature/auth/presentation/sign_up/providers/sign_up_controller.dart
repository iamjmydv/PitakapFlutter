import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/providers/auth_providers.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/providers/sign_up_state.dart';

class SignUpController extends AsyncNotifier<SignUpState> {
  @override
  FutureOr<SignUpState> build() => const SignUpInitialState();

  bool get isBusy => state.value is SignUpLoadingState;

  Future<void> submit(SignUpUseCaseParams params) async {
    if (isBusy) return;

    state = const AsyncValue.data(SignUpLoadingState());

    final result = await AsyncValue.guard(
      () => ref.read(signUpUserUseCaseProvider).call(params),
    );

    state = AsyncValue.data(
      switch (result) {
        AsyncData(:final value) => SignUpSuccessState(value),
        AsyncError(:final error) => SignUpFailedState(failureMessage(error)),
        _ => const SignUpLoadingState(),
      },
    );
  }

  void reset() => state = const AsyncValue.data(SignUpInitialState());
}

final signUpControllerProvider =
    AsyncNotifierProvider.autoDispose<SignUpController, SignUpState>(
  SignUpController.new,
);
