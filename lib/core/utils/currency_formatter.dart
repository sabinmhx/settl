import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

String formatMoney(double amount) => _currency.format(amount);

String formatCompact(double amount) {
  if (amount.abs() >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(1)}k';
  }
  return formatMoney(amount);
}
