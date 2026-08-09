import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/core/router/main_shell.dart';
import 'package:pitakapflutter/feature/auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:pitakapflutter/feature/auth/presentation/login/login_page.dart';
import 'package:pitakapflutter/feature/auth/presentation/sign_up/sign_up_page.dart';
import 'package:pitakapflutter/feature/dashboard/presentation/dashboard_page.dart';
import 'package:pitakapflutter/feature/expense/presentation/expenses_page.dart';
import 'package:pitakapflutter/feature/onboarding/presentation/onboarding_page.dart';
import 'package:pitakapflutter/feature/profile/presentation/settings_page.dart';
import 'package:pitakapflutter/feature/splash/presentation/splash_page.dart';
import 'package:pitakapflutter/feature/stats/presentation/stats_page.dart';
import 'package:pitakapflutter/feature/subscription/presentation/subscriptions_list_page.dart';

StatefulShellBranch _branch(String path, Widget page) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => page)],
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => ForgotPasswordPage(
          initialEmail: state.uri.queryParameters[AppRoutes.emailQueryParam],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.dashboard, const DashboardPage()),
          _branch(AppRoutes.subscriptions, const SubscriptionsListPage()),
          _branch(AppRoutes.expenses, const ExpensesPage()),
          _branch(AppRoutes.stats, const StatsPage()),
          _branch(AppRoutes.settings, const SettingsPage()),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
});
