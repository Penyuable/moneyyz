import 'package:intl/intl.dart';

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final NumberFormat _decimal = NumberFormat.decimalPattern('id_ID');

/// `1234567` → `Rp 1.234.567`
String formatRupiah(num value) => _rupiah.format(value);

/// `1234567` → `1.234.567`
String formatNumber(num value) => _decimal.format(value);

/// `1234567` → `+Rp 1.234.567` / `-Rp 1.234.567`
String formatSignedRupiah(num value, {required bool isIncome}) {
  final sign = isIncome ? '+' : '-';
  return '$sign${formatRupiah(value.abs())}';
}

/// Format ringkas untuk label grafik.
String formatCompactRupiah(num value) {
  final abs = value.abs();
  final sign = value < 0 ? '-' : '';
  if (abs >= 1000000000) {
    return '$sign${_prefix()} ${_trim((abs / 1000000000))} M';
  }
  if (abs >= 1000000) {
    return '$sign${_prefix()} ${_trim((abs / 1000000))} jt';
  }
  if (abs >= 1000) {
    return '$sign${_prefix()} ${_trim((abs / 1000))} rb';
  }
  return formatRupiah(value);
}

String _prefix() => 'Rp';

String _trim(double value) {
  final fixed = value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return fixed.replaceAll('.', ',');
}

/// `Senin, 24 Oktober 2026`
String formatDateLong(DateTime date) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

/// `24 Okt 2026`
String formatDateShort(DateTime date) =>
    DateFormat('d MMM yyyy', 'id_ID').format(date);

/// `24 Okt`
String formatDayMonth(DateTime date) =>
    DateFormat('d MMM', 'id_ID').format(date);

/// `Oktober 2026`
String formatMonthYear(DateTime date) =>
    DateFormat('MMMM yyyy', 'id_ID').format(date);

/// `Okt`
String formatMonthShort(DateTime date) =>
    DateFormat('MMM', 'id_ID').format(date);

/// `Hari ini` / `Kemarin` / `Senin, 24 Okt 2026`
String formatRelativeDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return formatDateLong(date);
}

/// Inisial untuk avatar: `Samuel Bryant` → `SB`.
String initialsOf(String? name) {
  final clean = (name ?? '').trim();
  if (clean.isEmpty) return 'S';
  final parts = clean
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
