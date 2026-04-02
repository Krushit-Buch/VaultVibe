import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency and amount formatting utilities.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String? symbol}) {
    final sym = symbol ?? AppConstants.defaultCurrencySymbol;
    final formatter = NumberFormat.currency(
      symbol: sym,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String? symbol}) {
    final sym = symbol ?? AppConstants.defaultCurrencySymbol;
    if (amount >= 1000000) {
      return '$sym${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$sym${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: sym);
  }

  static String formatWithSign(double amount, {String? symbol}) {
    final formatted = format(amount.abs(), symbol: symbol);
    return amount < 0 ? '-$formatted' : '+$formatted';
  }
}
