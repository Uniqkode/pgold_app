import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 2,
    locale: 'en_NG',
  );
  return formatter.format(amount);
}

String formatDate(String isoString) {
  final date = DateTime.parse(isoString);
  final formatter = DateFormat('MMM dd, yyyy · hh:mm a');
  return formatter.format(date.toLocal());
}
