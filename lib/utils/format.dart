import 'package:intl/intl.dart';

extension CurrencyFormat on int {
  String formatCurrency() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }
}
