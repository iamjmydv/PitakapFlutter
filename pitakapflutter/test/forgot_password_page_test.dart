import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/login_page.dart';

import 'helpers.dart';

void main() {
  group('ForgotPasswordPage layout', () {
    testWidgets('renders the reset form', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text(Strings.forgotPasswordTitle), findsOneWidget);
      expect(find.text(Strings.forgotPasswordSubtitle), findsOneWidget);
      expect(find.text(Strings.emailLabel), findsOneWidget);
      expect(find.text(Strings.forgotPasswordAction), findsOneWidget);
      expect(
        find.textContaining(
          Strings.forgotPasswordSignInLink,
          findRichText: true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('asks only for an email, never a password', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      expect(find.text(Strings.passwordLabel), findsNothing);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders in dark mode without exceptions', (tester) async {
      await pumpPage(
        tester,
        const ForgotPasswordPage(),
        brightness: Brightness.dark,
      );

      expect(tester.takeException(), isNull);
      expect(find.text(Strings.forgotPasswordAction), findsOneWidget);
    });

    testWidgets('prefills the email it was given', (tester) async {
      await pumpPage(
        tester,
        const ForgotPasswordPage(initialEmail: 'diane@pitakap.app'),
      );

      expect(find.text('diane@pitakap.app'), findsOneWidget);
    });

    testWidgets('starts empty when no email was given', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );

      expect(field.controller?.text, isEmpty);
    });
  });

  group('ForgotPasswordPage validation', () {
    testWidgets('an empty email is rejected', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      await tester.tap(find.text(Strings.forgotPasswordAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.emailRequired), findsOneWidget);
    });

    testWidgets('a malformed email is rejected', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.tap(find.text(Strings.forgotPasswordAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.emailInvalid), findsOneWidget);
    });

    testWidgets('a valid email clears the error', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      await tester.tap(find.text(Strings.forgotPasswordAction));
      await tester.pumpAndSettle();
      expect(find.text(Strings.emailRequired), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField),
        'diane@pitakap.app',
      );
      await tester.tap(find.text(Strings.forgotPasswordAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.emailRequired), findsNothing);
      expect(find.text(Strings.emailInvalid), findsNothing);
    });
  });

  group('forgot password navigation', () {
    testWidgets('the login link opens the reset screen', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.tap(find.text(Strings.loginForgotPassword));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('the typed email carries across from login', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.enterText(
        find.byType(TextFormField).first,
        'diane@pitakap.app',
      );
      await tester.tap(find.text(Strings.loginForgotPassword));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('diane@pitakap.app'), findsOneWidget);
    });

    testWidgets('an empty login email does not prefill', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.tap(find.text(Strings.loginForgotPassword));
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );

      expect(field.controller?.text, isEmpty);
    });

    testWidgets('the back arrow returns to login', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.tap(find.text(Strings.loginForgotPassword));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ForgotPasswordPage), findsNothing);
    });

    testWidgets('the sign-in link returns to login', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.tap(find.text(Strings.loginForgotPassword));
      await tester.pumpAndSettle();

      await tester.tapOnText(
        find.textRange.ofSubstring(Strings.forgotPasswordSignInLink),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('opening the reset screen directly still reaches login', (
      tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.forgotPassword);
      expect(find.byType(ForgotPasswordPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
