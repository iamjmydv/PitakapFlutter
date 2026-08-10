import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/providers/forgot_password_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/providers/forgot_password_state.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/providers/login_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/providers/login_state.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/providers/sign_up_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/providers/sign_up_state.dart';

import 'helpers.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  group('LoginController', () {
    const params = LoginUseCaseParams(
      email: 'spiderman@pitakap.app',
      password: 'secret123',
    );

    test('starts in the initial state', () async {
      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      expect(
        container.read(loginControllerProvider).value,
        isA<LoginInitialState>(),
      );
    });

    test('reaches success and carries the user', () async {
      when(() => repository.login(any())).thenAnswer((_) async => testUser);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submit(params);

      final state = container.read(loginControllerProvider).value;
      expect(state, isA<LoginSuccessState>());
      expect((state as LoginSuccessState).user, testUser);
    });

    test('surfaces the failure message rather than the raw error', () async {
      when(
        () => repository.login(any()),
      ).thenThrow(const ServerFailure('Incorrect email or password'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submit(params);

      final state = container.read(loginControllerProvider).value;
      expect(state, isA<LoginFailedState>());
      expect(
        (state as LoginFailedState).message,
        'Incorrect email or password',
      );
    });

    test('hides unexpected errors behind a generic message', () async {
      when(() => repository.login(any())).thenThrow(StateError('internals'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submit(params);

      final state = container.read(loginControllerProvider).value;
      expect((state as LoginFailedState).message, Strings.genericError);
    });

    test('reset returns to the initial state', () async {
      when(
        () => repository.login(any()),
      ).thenThrow(const ServerFailure('nope'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submit(params);
      container.read(loginControllerProvider.notifier).reset();

      expect(
        container.read(loginControllerProvider).value,
        isA<LoginInitialState>(),
      );
    });
  });

  group('SignUpController', () {
    const params = SignUpUseCaseParams(
      firstName: 'Diane',
      lastName: 'Magno',
      email: 'diane@pitakap.app',
      password: 'secret123',
    );

    test('reaches success and carries the created user', () async {
      when(() => repository.signUp(any())).thenAnswer((_) async => testUser);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(signUpControllerProvider.notifier).submit(params);

      final state = container.read(signUpControllerProvider).value;
      expect(state, isA<SignUpSuccessState>());
      expect((state as SignUpSuccessState).user, testUser);
    });

    test('surfaces a duplicate email message', () async {
      when(
        () => repository.signUp(any()),
      ).thenThrow(const ServerFailure('That email is already registered'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(signUpControllerProvider.notifier).submit(params);

      final state = container.read(signUpControllerProvider).value;
      expect(
        (state as SignUpFailedState).message,
        'That email is already registered',
      );
    });
  });

  group('ForgotPasswordController', () {
    const params = SendPasswordResetUseCaseParams(email: 'diane@pitakap.app');

    test('reaches sent and remembers the address', () async {
      when(() => repository.sendPasswordReset(any())).thenAnswer((_) async {});

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container
          .read(forgotPasswordControllerProvider.notifier)
          .submit(params);

      final state = container.read(forgotPasswordControllerProvider).value;
      expect(state, isA<ForgotPasswordSentState>());
      expect((state as ForgotPasswordSentState).email, 'diane@pitakap.app');
    });

    test('surfaces a network failure message', () async {
      when(
        () => repository.sendPasswordReset(any()),
      ).thenThrow(const NetworkFailure('No internet connection'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container
          .read(forgotPasswordControllerProvider.notifier)
          .submit(params);

      final state = container.read(forgotPasswordControllerProvider).value;
      expect(
        (state as ForgotPasswordFailedState).message,
        'No internet connection',
      );
    });
  });
}
