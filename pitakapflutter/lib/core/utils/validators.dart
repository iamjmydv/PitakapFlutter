import 'package:pitakapflutter/core/resources/strings.dart';

abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static const int minPasswordLength = 6;

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return Strings.emailRequired;
    if (!_emailPattern.hasMatch(email)) return Strings.emailInvalid;

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return Strings.passwordRequired;
    if (password.length < minPasswordLength) return Strings.passwordTooShort;

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return Strings.confirmPasswordRequired;
    if (value != password) return Strings.passwordsDoNotMatch;

    return null;
  }

  static String? notEmpty(String? value, String message) {
    return (value?.trim() ?? '').isEmpty ? message : null;
  }

  static String? amount(String? value) {
    final raw = value?.trim() ?? '';

    if (raw.isEmpty) return Strings.amountRequired;

    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) return Strings.amountInvalid;

    return null;
  }
}
