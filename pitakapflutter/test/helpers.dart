import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pitakapflutter/core/providers/app_providers.dart';
import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/core/router/app_router.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/main.dart';

const Map<String, Object> onboarded = {Keys.prefsOnboardingSeen: true};

Future<ProviderContainer> containerWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

Future<Widget> appWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const PitakapApp(),
  );
}

Future<void> pumpPage(
  WidgetTester tester,
  Widget page, {
  Brightness brightness = Brightness.light,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light(),
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpPastSplash(WidgetTester tester) async {
  await tester.pump(Constants.splashMinimumDuration);
  await tester.pumpAndSettle();
}

Future<ProviderContainer> pumpAppAt(
  WidgetTester tester,
  String location, {
  Map<String, Object> values = onboarded,
}) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const PitakapApp(),
    ),
  );

  container.read(goRouterProvider).go(location);
  await tester.pumpAndSettle();

  return container;
}
