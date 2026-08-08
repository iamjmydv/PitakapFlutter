import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects an empty or whitespace-only value', () {
      expect(Validators.email(null), Strings.emailRequired);
      expect(Validators.email(''), Strings.emailRequired);
      expect(Validators.email('   '), Strings.emailRequired);
    });

    test('rejects addresses that are not well formed', () {
      const invalid = [
        'spiderman',
        'spiderman@',
        '@gmail.com',
        'spiderman@gmail',
        'spider man@gmail.com',
        'spiderman@@gmail.com',
      ];

      for (final value in invalid) {
        expect(Validators.email(value), Strings.emailInvalid, reason: value);
      }
    });

    test('accepts well formed addresses and ignores surrounding space', () {
      const valid = [
        'spiderman@gmail.com',
        '  spiderman@gmail.com  ',
        'peter.parker+news@daily-bugle.co.uk',
        'diane_1@sub.domain.ph',
      ];

      for (final value in valid) {
        expect(Validators.email(value), isNull, reason: value);
      }
    });
  });

  group('Validators.password', () {
    test('rejects an empty value', () {
      expect(Validators.password(null), Strings.passwordRequired);
      expect(Validators.password(''), Strings.passwordRequired);
    });

    test('rejects values below the minimum length', () {
      expect(Validators.password('12345'), Strings.passwordTooShort);
    });

    test('accepts values at or above the minimum length', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('a-longer-passphrase'), isNull);
    });

    test('does not trim, because spaces are valid password characters', () {
      expect(Validators.password('   a  '), isNull);
    });
  });
}
