import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';

abstract final class CommonSnackBar {
  static void showSuccess(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      background: colorScheme.primary,
      foreground: colorScheme.onPrimary,
    );
  }

  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      background: colorScheme.error,
      foreground: colorScheme.onError,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Row(
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: foreground),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
