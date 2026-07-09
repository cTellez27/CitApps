import 'package:intl/intl.dart';

/// Currency formatting utilities.
///
/// Formats amounts according to the barbershop's
/// configured currency (defaults to MXN).
abstract class CurrencyUtils {
  static final _formatter = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formats a number as currency. Example: 150.5 → "\$150.50"
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Formats with custom symbol. Example: format(150.5, '€') → "€150.50"
  static String formatWithSymbol(double amount, String symbol) {
    final formatter = NumberFormat.currency(
      locale: 'es_MX',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats compact for KPIs. Example: 15000 → "\$15K"
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
