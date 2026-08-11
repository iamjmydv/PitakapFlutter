import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/providers/forgot_password_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/login_page.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/providers/login_controller.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/providers/sign_up_controller.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';

import 'helpers.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  group('re-entry guards', () {
    const loginParams = LoginUseCaseParams(
      email: 'diane@pitakap.app',
      password: 'secret123',
    );

    test('a second sign in is ignored while the first is in flight', () async {
      final gate = Completer<UserDetailsEntity>();
      when(() => repository.login(any())).thenAnswer((_) => gate.future);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      final controller = container.read(loginControllerProvider.notifier);
      final first = controller.submit(loginParams);
      final second = controller.submit(loginParams);

      gate.complete(testUser);
      await Future.wait([first, second]);

      verify(() => repository.login(any())).called(1);
    });

    test('google sign in is ignored while email sign in runs', () async {
      final gate = Completer<UserDetailsEntity>();
      when(() => repository.login(any())).thenAnswer((_) => gate.future);
      when(() => repository.signInWithGoogle())
          .thenAnswer((_) async => testUser);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      final controller = container.read(loginControllerProvider.notifier);
      final first = controller.submit(loginParams);
      final second = controller.submitGoogle();

      gate.complete(testUser);
      await Future.wait([first, second]);

      verifyNever(() => repository.signInWithGoogle());
    });

    test('a second sign up is ignored while the first is in flight', () async {
      const params = SignUpUseCaseParams(
        firstName: 'Diane',
        lastName: 'Magno',
        email: 'diane@pitakap.app',
        password: 'secret123',
      );

      final gate = Completer<UserDetailsEntity>();
      when(() => repository.signUp(any())).thenAnswer((_) => gate.future);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      final controller = container.read(signUpControllerProvider.notifier);
      final first = controller.submit(params);
      final second = controller.submit(params);

      gate.complete(testUser);
      await Future.wait([first, second]);

      verify(() => repository.signUp(any())).called(1);
    });

    test('a second reset request is ignored while one is in flight', () async {
      const params = SendPasswordResetUseCaseParams(
        email: 'diane@pitakap.app',
      );

      final gate = Completer<void>();
      when(() => repository.sendPasswordReset(any()))
          .thenAnswer((_) => gate.future);

      final container = await containerWithAuth(repository);
      addTearDown(container.dispose);

      final controller =
          container.read(forgotPasswordControllerProvider.notifier);
      final first = controller.submit(params);
      final second = controller.submit(params);

      gate.complete();
      await Future.wait([first, second]);

      verify(() => repository.sendPasswordReset(any())).called(1);
    });
  });

  group('inputs lock while a request is in flight', () {
    testWidgets('login disables its fields and both buttons', (tester) async {
      final gate = Completer<UserDetailsEntity>();
      when(() => repository.login(any())).thenAnswer((_) => gate.future);

      await pumpPage(
        tester,
        const LoginPage(),
        overrides: authOverrides(repository: repository),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'diane@pitakap.app',
      );
      await tester.enterText(find.byType(TextFormField).last, 'secret123');
      await tester.tap(find.text(Strings.loginSignIn));
      await tester.pump();

      final email = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(email.enabled, isFalse);

      final forgot = tester.widget<TextButton>(find.byType(TextButton));
      expect(forgot.onPressed, isNull);

      final google = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(google.onPressed, isNull);

      gate.complete(testUser);
      await tester.pumpAndSettle();
    });

    testWidgets('reset disables its field while sending', (tester) async {
      final gate = Completer<void>();
      when(() => repository.sendPasswordReset(any()))
          .thenAnswer((_) => gate.future);

      await pumpPage(
        tester,
        const ForgotPasswordPage(initialEmail: 'diane@pitakap.app'),
        overrides: authOverrides(repository: repository),
      );

      await tester.tap(find.text(Strings.forgotPasswordAction));
      await tester.pump();

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(field.enabled, isFalse);

      gate.completeError(const NetworkFailure('No internet connection'));
      await tester.pumpAndSettle();

      final unlocked = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(unlocked.enabled, isTrue);
    });
  });
}
