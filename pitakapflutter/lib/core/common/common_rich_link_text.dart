import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CommonRichLinkText extends StatefulWidget {
  const CommonRichLinkText({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;
  final TextAlign textAlign;

  @override
  State<CommonRichLinkText> createState() => _CommonRichLinkTextState();
}

class _CommonRichLinkTextState extends State<CommonRichLinkText> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void didUpdateWidget(CommonRichLinkText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTap != widget.onTap) {
      _recognizer.onTap = widget.onTap;
    }
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;

    return Text.rich(
      TextSpan(
        text: widget.text,
        style: baseStyle,
        children: [
          TextSpan(
            text: widget.linkText,
            style: baseStyle?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: _recognizer,
          ),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
