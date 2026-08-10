import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/providers/auth_providers.dart';
import 'package:pitakapflutter/core/providers/onboarding_providers.dart';
import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/core/widgets/app_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Constants.splashMinimumDuration, _openNextRoute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openNextRoute() {
    if (!mounted) return;

    if (!ref.read(onboardingSeenProvider)) {
      context.go(AppRoutes.onboarding);
      return;
    }

    final isSignedIn = ref.read(authStateProvider).value != null;
    context.go(isSignedIn ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(),
            const SizedBox(height: AppSpacing.md),
            Text(Strings.appName, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(Strings.appTagline, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
