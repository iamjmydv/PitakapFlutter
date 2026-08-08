import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/common/common_loader.dart';

class CommonPrimaryButton extends StatelessWidget {
  const CommonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.style,
    this.spinnerSize = 20,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final double spinnerSize;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? CommonLoader(
              size: spinnerSize,
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : Text(label),
    );
  }
}
