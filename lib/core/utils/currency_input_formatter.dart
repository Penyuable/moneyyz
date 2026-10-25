import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _decimal = NumberFormat.decimalPattern('id_ID');

/// Menampilkan nominal dengan pemisah ribuan saat pengguna mengetik.
class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    if (digits.length > 15) {
      return oldValue;
    }
    final formatted = _decimal.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// `1.234.567` → `1234567`
double parseCurrencyInput(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  return double.tryParse(digits) ?? 0;
}
