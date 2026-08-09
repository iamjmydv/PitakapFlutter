import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/login_page.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/sign_up_page.dart';

import 'helpers.dart';

Finder fieldWithLabel(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(TextFormField),
    );

void main() {
  group('SignUpPage layout', () {
    testWidgets('renders every element from the design', (tester) async {
      await pumpPage(tester, const SignUpPage());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text(Strings.signUpTitle), findsOneWidget);
      expect(find.text(Strings.signUpSubtitle), findsOneWidget);
      expect(find.text(Strings.firstNameLabel), findsOneWidget);
      expect(find.text(Strings.lastNameLabel), findsOneWidget);
      expect(find.text(Strings.emailLabel), findsOneWidget);
      expect(find.text(Strings.passwordLabel), findsOneWidget);
      expect(find.text(Strings.confirmPasswordLabel), findsOneWidget);
      expect(find.text(Strings.signUpAction), findsOneWidget);
      expect(find.text(Strings.signUpTerms), findsOneWidget);
      expect(
        find.textContaining(Strings.signUpSignInLink, findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('has no Google sign-in, matching the design', (tester) async {
      await pumpPage(tester, const SignUpPage());

      expect(find.text(Strings.loginContinueWithGoogle), findsNothing);
    });

    testWidgets('renders in dark mode without exceptions', (tester) async {
      await pumpPage(tester, const SignUpPage(), brightness: Brightness.dark);

      expect(tester.takeException(), isNull);
      expect(find.text(Strings.signUpAction), findsOneWidget);
    });
  });

  group('SignUpPage validation', () {
    testWidgets('an empty form reports every required field', (tester) async {
      await pumpPage(tester, const SignUpPage());

      await tester.tap(find.text(Strings.signUpAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.firstNameRequired), findsOneWidget);
      expect(find.text(Strings.lastNameRequired), findsOneWidget);
      expect(find.text(Strings.emailRequired), findsOneWidget);
      expect(find.text(Strings.passwordRequired), findsOneWidget);
      expect(find.text(Strings.confirmPasswordRequired), findsOneWidget);
    });

    testWidgets('mismatched passwords are rejected', (tester) async {
      await pumpPage(tester, const SignUpPage());

      await tester.enterText(
        fieldWithLabel(Strings.passwordLabel),
        'secret123',
      );
      await tester.enterText(
        fieldWithLabel(Strings.confirmPasswordLabel),
        'secret124',
      );
      await tester.tap(find.text(Strings.signUpAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.passwordsDoNotMatch), findsOneWidget);
    });

    testWidgets('a fully valid form clears every error', (tester) async {
      await pumpPage(tester, const SignUpPage());

      await tester.tap(find.text(Strings.signUpAction));
      await tester.pumpAndSettle();
      expect(find.text(Strings.firstNameRequired), findsOneWidget);

      await tester.enterText(fieldWithLabel(Strings.firstNameLabel), 'Diane');
      await tester.enterText(fieldWithLabel(Strings.lastNameLabel), 'Magno');
      await tester.enterText(
        fieldWithLabel(Strings.emailLabel),
        'diane@pitakap.app',
      );
      await tester.enterText(
        fieldWithLabel(Strings.passwordLabel),
        'secret123',
      );
      await tester.enterText(
        fieldWithLabel(Strings.confirmPasswordLabel),
        'secret123',
      );
      await tester.tap(find.text(Strings.signUpAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.firstNameRequired), findsNothing);
      expect(find.text(Strings.lastNameRequired), findsNothing);
      expect(find.text(Strings.emailRequired), findsNothing);
      expect(find.text(Strings.emailInvalid), findsNothing);
      expect(find.text(Strings.passwordRequired), findsNothing);
      expect(find.text(Strings.passwordsDoNotMatch), findsNothing);
    });

    testWidgets('both password fields hide their input independently', (
      tester,
    ) async {
      await pumpPage(tester, const SignUpPage());

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('auth navigation', () {
    testWidgets('the login link opens sign up', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);
      expect(find.byType(LoginPage), findsOneWidget);

      await tester.tapOnText(
        find.textRange.ofSubstring(Strings.loginSignUpLink),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SignUpPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('the back arrow returns to login', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.tapOnText(
        find.textRange.ofSubstring(Strings.loginSignUpLink),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(SignUpPage), findsNothing);
    });

    testWidgets('the sign-in link returns to login', (tester) async {
      await pumpAppAt(tester, AppRoutes.login);

      await tester.tapOnText(
        find.textRange.ofSubstring(Strings.loginSignUpLink),
      );
      await tester.pumpAndSettle();

      await tester.tapOnText(
        find.textRange.ofSubstring(Strings.signUpSignInLink),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(SignUpPage), findsNothing);
    });

    testWidgets('opening sign up directly still reaches login', (tester) async {
      await pumpAppAt(tester, AppRoutes.signUp);
      expect(find.byType(SignUpPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
