import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/providers/login_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/providers/login_state.dart';

import 'helpers.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  group('SignInWithGoogleUseCase', () {
    test('returns the signed in user', () async {
      when(() => repository.signInWithGoogle())
          .thenAnswer((_) async => testUser);

      final result = await SignInWithGoogleUseCase(repository).call();

      expect(result, testUser);
      verify(() => repository.signInWithGoogle()).called(1);
    });

    test('returns null when the user cancels', () async {
      when(() => repository.signInWithGoogle()).thenAnswer((_) async => null);

      expect(await SignInWithGoogleUseCase(repository).call(), isNull);
    });

    test('lets failures propagate', () {
      when(() => repository.signInWithGoogle())
          .thenThrow(const NetworkFailure('No internet connection'));

      expect(
        () => SignInWithGoogleUseCase(repository).call(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('LoginController.submitGoogle', () {
    test('reaches success and carries the user', () async {
      when(() => repository.signInWithGoogle())
          .thenAnswer((_) async => testUser);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submitGoogle();

      final state = container.read(loginControllerProvider).value;
      expect(state, isA<LoginSuccessState>());
      expect((state as LoginSuccessState).user, testUser);
    });

    test('treats cancellation as a no-op, not a failure', () async {
      when(() => repository.signInWithGoogle()).thenAnswer((_) async => null);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submitGoogle();

      final state = container.read(loginControllerProvider).value;
      expect(state, isA<LoginInitialState>());
      expect(state, isNot(isA<LoginFailedState>()));
    });

    test('surfaces a real failure', () async {
      when(() => repository.signInWithGoogle())
          .thenThrow(const NetworkFailure('No internet connection'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submitGoogle();

      final state = container.read(loginControllerProvider).value;
      expect(
        (state as LoginFailedState).message,
        'No internet connection',
      );
    });

    test('hides unexpected errors behind a generic message', () async {
      when(() => repository.signInWithGoogle())
          .thenThrow(StateError('internals'));

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      await container.read(loginControllerProvider.notifier).submitGoogle();

      final state = container.read(loginControllerProvider).value;
      expect((state as LoginFailedState).message, Strings.genericError);
    });

    test('email sign in and google sign in use distinct loading states', () {
      expect(
        const LoginGoogleLoadingState(),
        isNot(isA<LoginLoadingState>()),
      );
    });
  });
}
