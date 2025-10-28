import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00');

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return _numberFormat.format(amount);
  }

  static double? parse(String amountString) {
    try {
      // Remove currency symbol and commas
      final cleanString = amountString.replaceAll(RegExp(r'[₹,\s]'), '');
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return format(amount);
    }
  }
}

