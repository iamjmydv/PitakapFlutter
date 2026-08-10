import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/providers/auth_providers.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/providers/login_state.dart';

class LoginController extends AsyncNotifier<LoginState> {
  @override
  FutureOr<LoginState> build() => const LoginInitialState();

  Future<void> submit(LoginUseCaseParams params) async {
    state = const AsyncValue.data(LoginLoadingState());

    final result = await AsyncValue.guard(
      () => ref.read(loginUserUseCaseProvider).call(params),
    );

    state = AsyncValue.data(
      switch (result) {
        AsyncData(:final value) => LoginSuccessState(value),
        AsyncError(:final error) => LoginFailedState(failureMessage(error)),
        _ => const LoginLoadingState(),
      },
    );
  }

  void reset() => state = const AsyncValue.data(LoginInitialState());
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, LoginState>(
  LoginController.new,
);
