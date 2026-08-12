import 'package:intl/intl.dart';

import 'package:pitakapflutter/core/resources/constants.dart';

String currencySymbol(String currencyCode) {
  if (currencyCode == Constants.defaultCurrency) return Constants.currencySymbol;

  try {
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  } catch (_) {
    return currencyCode;
  }
}

String formatCurrency(
  num amount, {
  String currencyCode = Constants.defaultCurrency,
  int decimalDigits = 2,
}) {
  return NumberFormat.currency(
    symbol: currencySymbol(currencyCode),
    decimalDigits: decimalDigits,
  ).format(amount);
}
