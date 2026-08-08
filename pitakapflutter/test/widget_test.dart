import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pitakapflutter/core/providers/app_providers.dart';
import 'package:pitakapflutter/core/providers/onboarding_providers.dart';
import 'package:pitakapflutter/core/providers/settings_providers.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/feature/onboarding/presentation/onboarding_page.dart';

import 'helpers.dart';

void main() {
  group('themeModeProvider', () {
    test('defaults to system when nothing is stored', () async {
      final container = await containerWith({});
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('restores the persisted theme mode', () async {
      final container = await containerWith({Keys.prefsThemeMode: 'dark'});
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('persists the selected theme mode', () async {
      final container = await containerWith({});
      addTearDown(container.dispose);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(
        container
            .read(sharedPreferencesProvider)
            .getString(Keys.prefsThemeMode),
        'dark',
      );
    });

    test('toggle switches between light and dark', () async {
      final container = await containerWith({Keys.prefsThemeMode: 'light'});
      addTearDown(container.dispose);

      final controller = container.read(themeModeProvider.notifier);

      await controller.toggle(Brightness.light);
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await controller.toggle(Brightness.dark);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('toggle from system follows the rendered brightness', () async {
      final container = await containerWith({});
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.system);

      await container.read(themeModeProvider.notifier).toggle(Brightness.dark);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });

  group('AppTheme', () {
    test('light and dark use the Inter family and Material 3', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.useMaterial3, isTrue);
        expect(theme.textTheme.titleMedium?.fontFamily, 'Inter');
      }
    });

    test('brightness matches the requested variant', () {
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
    });

    test('category accents are unique across every known category', () {
      final values = AppColors.categoryAccents.values.toList();

      expect(values.toSet().length, values.length);
    });

    test('unknown categories fall back to the muted ink tone', () {
      expect(AppColors.categoryAccent('not-a-category'), AppColors.inkSub);
      expect(AppColors.categoryAccent('food'), AppColors.categoryFood);
    });
  });

  group('routing', () {
    testWidgets('splash shows the brand before routing away', (tester) async {
      await tester.pumpWidget(await appWith(onboarded));
      await tester.pump();

      expect(find.text(Strings.appName), findsOneWidget);
      expect(find.text(Strings.appTagline), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await pumpPastSplash(tester);
    });

    testWidgets('splash routes into the dashboard shell', (tester) async {
      await tester.pumpWidget(await appWith(onboarded));
      await pumpPastSplash(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text(Strings.dashboardTitle), findsWidgets);
      expect(find.text(Strings.appTagline), findsNothing);
    });

    testWidgets('bottom navigation reaches every tab', (tester) async {
      await tester.pumpWidget(await appWith(onboarded));
      await pumpPastSplash(tester);

      final tabs = <IconData, String>{
        Icons.autorenew_outlined: Strings.subscriptionsTitle,
        Icons.account_balance_wallet_outlined: Strings.expensesTitle,
        Icons.pie_chart_outline: Strings.statsTitle,
        Icons.settings_outlined: Strings.settingsTitle,
        Icons.home_outlined: Strings.dashboardTitle,
      };

      for (final tab in tabs.entries) {
        await tester.tap(find.byIcon(tab.key));
        await tester.pumpAndSettle();

        expect(find.text(tab.value), findsWidgets);
      }
    });

    testWidgets('a visited tab stays alive off screen', (tester) async {
      await tester.pumpWidget(await appWith(onboarded));
      await pumpPastSplash(tester);

      expect(
        find.text(Strings.statsTitle, skipOffstage: false),
        findsNothing,
      );

      await tester.tap(find.byIcon(Icons.pie_chart_outline));
      await tester.pumpAndSettle();
      expect(find.text(Strings.statsTitle), findsWidgets);

      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      expect(find.text(Strings.dashboardTitle), findsWidgets);
      expect(find.text(Strings.statsTitle), findsNothing);
      expect(
        find.text(Strings.statsTitle, skipOffstage: false),
        findsWidgets,
      );
    });

    testWidgets('app renders in dark mode when persisted', (tester) async {
      await tester.pumpWidget(
        await appWith({...onboarded, Keys.prefsThemeMode: 'dark'}),
      );
      await pumpPastSplash(tester);

      final context = tester.element(find.byType(NavigationBar));
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });

  group('onboardingSeenProvider', () {
    test('defaults to false when nothing is stored', () async {
      final container = await containerWith({});
      addTearDown(container.dispose);

      expect(container.read(onboardingSeenProvider), isFalse);
    });

    test('restores the persisted flag', () async {
      final container = await containerWith(onboarded);
      addTearDown(container.dispose);

      expect(container.read(onboardingSeenProvider), isTrue);
    });

    test('markSeen persists the flag', () async {
      final container = await containerWith({});
      addTearDown(container.dispose);

      await container.read(onboardingSeenProvider.notifier).markSeen();

      expect(container.read(onboardingSeenProvider), isTrue);
      expect(
        container
            .read(sharedPreferencesProvider)
            .getBool(Keys.prefsOnboardingSeen),
        isTrue,
      );
    });
  });

  group('onboarding', () {
    testWidgets('first launch lands on onboarding, not the shell', (
      tester,
    ) async {
      await tester.pumpWidget(await appWith({}));
      await pumpPastSplash(tester);

      expect(find.text(Strings.onboardingSubscriptionsTitle), findsOneWidget);
      expect(find.text(Strings.onboardingNext), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('advancing through every slide reveals the final call to '
        'action', (tester) async {
      await tester.pumpWidget(await appWith({}));
      await pumpPastSplash(tester);

      for (var i = 0; i < onboardingSlides.length - 1; i++) {
        expect(find.text(Strings.onboardingNext), findsOneWidget);
        await tester.tap(find.text(Strings.onboardingNext));
        await tester.pumpAndSettle();
      }

      expect(find.text(Strings.onboardingNext), findsNothing);
      expect(find.text(Strings.onboardingStart), findsOneWidget);
    });

    testWidgets('finishing marks onboarding seen and opens the shell', (
      tester,
    ) async {
      await tester.pumpWidget(await appWith({}));
      await pumpPastSplash(tester);

      for (var i = 0; i < onboardingSlides.length - 1; i++) {
        await tester.tap(find.text(Strings.onboardingNext));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text(Strings.onboardingStart));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text(Strings.dashboardTitle), findsWidgets);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(Keys.prefsOnboardingSeen), isTrue);
    });

    testWidgets('skipping marks onboarding seen and opens the shell', (
      tester,
    ) async {
      await tester.pumpWidget(await appWith({}));
      await pumpPastSplash(tester);

      await tester.tap(find.text(Strings.onboardingSkip));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(Keys.prefsOnboardingSeen), isTrue);
    });
  });
}
