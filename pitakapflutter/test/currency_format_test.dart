import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/utils/currency_format.dart';

void main() {
  group('currencySymbol', () {
    test('returns the peso sign for the default currency', () {
      expect(currencySymbol(Constants.defaultCurrency), Constants.currencySymbol);
    });

    test('returns the dollar sign for USD', () {
      expect(currencySymbol('USD'), r'$');
    });

    test('falls back to the code itself when the currency is unknown', () {
      expect(currencySymbol('ZZZ'), 'ZZZ');
    });
  });

  group('formatCurrency', () {
    test('formats a whole amount with two decimals', () {
      expect(formatCurrency(549), '${Constants.currencySymbol}549.00');
    });

    test('keeps the cents of a fractional amount', () {
      expect(formatCurrency(1234.5), '${Constants.currencySymbol}1,234.50');
    });

    test('groups thousands', () {
      expect(formatCurrency(1000000), '${Constants.currencySymbol}1,000,000.00');
    });

    test('formats zero', () {
      expect(formatCurrency(0), '${Constants.currencySymbol}0.00');
    });

    test('rounds to two decimals', () {
      expect(formatCurrency(99.999), '${Constants.currencySymbol}100.00');
    });

    test('honours an explicit currency code', () {
      expect(formatCurrency(20, currencyCode: 'USD'), r'$20.00');
    });

    test('honours an explicit decimal digit count', () {
      expect(
        formatCurrency(549, decimalDigits: 0),
        '${Constants.currencySymbol}549',
      );
    });
  });
}
