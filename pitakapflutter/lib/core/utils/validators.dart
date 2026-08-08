import 'package:pitakapflutter/core/resources/strings.dart';

abstract final class Validators {
  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$',
  );

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
}
