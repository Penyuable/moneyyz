import 'tx_type.dart';

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.title,
    required this.date,
    required this.createdAt,
    this.categoryId,
    this.note,
    this.merchant,
    this.receiptPath,
  });

  final String id;
  final String userId;
  final String? categoryId;
  final TxType type;
  final double amount;
  final String title;
  final String? note;
  final String? merchant;
  final DateTime date;
  final String? receiptPath;
  final DateTime createdAt;

  bool get isIncome => type.isIncome;

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      categoryId: map['category_id'] as String?,
      type: TxType.fromString(map['type'] as String?),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      title: map['title'] as String? ?? 'Transaksi',
      note: map['note'] as String?,
      merchant: map['merchant'] as String?,
      date: _parseDate(map['transaction_date']),
      receiptPath: map['receipt_path'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}


class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amount,
    required this.title,
    required this.date,
    this.categoryId,
    this.note = '',
    this.merchant,
    this.receiptPath,
  });

  final String? categoryId;
  final TxType type;
  final double amount;
  final String title;
  final String note;
  final String? merchant;
  final DateTime date;
  final String? receiptPath;

  Map<String, dynamic> toMap({String? userId}) {
    return {
      if (userId != null) 'user_id': userId,
      'category_id': categoryId,
      'type': type.value,
      'amount': amount,
      'title': title.trim(),
      'note': note.trim().isEmpty ? null : note.trim(),
      'merchant': merchant?.trim().isEmpty == true ? null : merchant?.trim(),
      'transaction_date': _dateOnly(date),
      'receipt_path': receiptPath,
    };
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
