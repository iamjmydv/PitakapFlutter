import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_out_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const diane = UserDetailsEntity(
  uid: 'uid-1',
  firstName: 'Diane',
  lastName: 'Magno',
  email: 'diane@pitakap.app',
);

void main() {
  late MockAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const LoginUseCaseParams(email: '', password: ''),
    );
    registerFallbackValue(
      const SignUpUseCaseParams(
        firstName: '',
        lastName: '',
        email: '',
        password: '',
      ),
    );
    registerFallbackValue(const SendPasswordResetUseCaseParams(email: ''));
  });

  setUp(() => repository = MockAuthRepository());

  group('LoginUserUseCase', () {
    const params = LoginUseCaseParams(
      email: 'diane@pitakap.app',
      password: 'secret123',
    );

    test('returns the user the repository resolves', () async {
      when(() => repository.login(any())).thenAnswer((_) async => diane);

      final result = await LoginUserUseCase(repository).call(params);

      expect(result, diane);
      verify(() => repository.login(params)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('passes the params through untouched', () async {
      when(() => repository.login(any())).thenAnswer((_) async => diane);

      await LoginUserUseCase(repository).call(params);

      final captured =
          verify(() => repository.login(captureAny())).captured.single
              as LoginUseCaseParams;

      expect(captured.email, 'diane@pitakap.app');
      expect(captured.password, 'secret123');
    });

    test('lets repository failures propagate untouched', () {
      when(() => repository.login(any())).thenThrow(
        const ServerFailure('Incorrect email or password'),
      );

      expect(
        () => LoginUserUseCase(repository).call(params),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Incorrect email or password',
          ),
        ),
      );
    });
  });

  group('SignUpUserUseCase', () {
    const params = SignUpUseCaseParams(
      firstName: 'Diane',
      lastName: 'Magno',
      email: 'diane@pitakap.app',
      password: 'secret123',
    );

    test('returns the created profile', () async {
      when(() => repository.signUp(any())).thenAnswer((_) async => diane);

      final result = await SignUpUserUseCase(repository).call(params);

      expect(result, diane);
      verify(() => repository.signUp(params)).called(1);
    });

    test('carries every field the form collected', () async {
      when(() => repository.signUp(any())).thenAnswer((_) async => diane);

      await SignUpUserUseCase(repository).call(params);

      final captured =
          verify(() => repository.signUp(captureAny())).captured.single
              as SignUpUseCaseParams;

      expect(captured.firstName, 'Diane');
      expect(captured.lastName, 'Magno');
      expect(captured.email, 'diane@pitakap.app');
      expect(captured.password, 'secret123');
    });

    test('lets a duplicate-email failure propagate', () {
      when(() => repository.signUp(any())).thenThrow(
        const ServerFailure('That email is already registered'),
      );

      expect(
        () => SignUpUserUseCase(repository).call(params),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('SendPasswordResetUseCase', () {
    const params = SendPasswordResetUseCaseParams(
      email: 'diane@pitakap.app',
    );

    test('delegates to the repository', () async {
      when(() => repository.sendPasswordReset(any()))
          .thenAnswer((_) async {});

      await SendPasswordResetUseCase(repository).call(params);

      verify(() => repository.sendPasswordReset(params)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('lets failures propagate', () {
      when(() => repository.sendPasswordReset(any()))
          .thenThrow(const NetworkFailure('No internet connection'));

      expect(
        () => SendPasswordResetUseCase(repository).call(params),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('SignOutUseCase', () {
    test('delegates to the repository and takes no params', () async {
      when(() => repository.signOut()).thenAnswer((_) async {});

      await SignOutUseCase(repository).call();

      verify(() => repository.signOut()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('lets failures propagate', () {
      when(() => repository.signOut())
          .thenThrow(const UnknownFailure('boom'));

      expect(
        () => SignOutUseCase(repository).call(),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}
