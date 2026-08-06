import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/providers/app_providers.dart';
import 'package:pitakapflutter/core/providers/settings_providers.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PitakapApp(),
    ),
  );
}

class PitakapApp extends ConsumerWidget {
  const PitakapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const ThemePreviewPage(),
    );
  }
}

class ThemePreviewPage extends ConsumerWidget {
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(themeModeProvider.notifier)
                .toggle(theme.brightness),
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(Strings.appTagline, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent today', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('₱1,245.00', style: theme.textTheme.displaySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const TextField(
            decoration: InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: () {}, child: const Text('Sign In')),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Continue with Google'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            children: AppColors.categoryAccents.entries
                .take(6)
                .map(
                  (entry) => Chip(
                    avatar: CircleAvatar(
                      backgroundColor: AppColors.categoryAccent(entry.key),
                      radius: 6,
                    ),
                    label: Text(entry.key),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(selection.first),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
