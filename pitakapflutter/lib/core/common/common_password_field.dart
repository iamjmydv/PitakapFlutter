import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class CommonPasswordField extends StatefulWidget {
  const CommonPasswordField({
    super.key,
    this.controller,
    this.label = Strings.passwordLabel,
    this.hint,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool enabled;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  State<CommonPasswordField> createState() => _CommonPasswordFieldState();
}

class _CommonPasswordFieldState extends State<CommonPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          tooltip: _obscure
              ? Strings.passwordShow
              : Strings.passwordHide,
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
        ),
      ),
    );
  }
}
