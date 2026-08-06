import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/providers/app_providers.dart';
import 'package:pitakapflutter/core/resources/keys.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref
        .watch(sharedPreferencesProvider)
        .getString(Keys.prefsThemeMode);
    return _decode(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(Keys.prefsThemeMode, _encode(mode));
  }

  Future<void> toggle(Brightness current) => setThemeMode(
        current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
      );

  static ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
