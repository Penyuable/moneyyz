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
    final receipt = _firstReceipt(map['finance_receipts']);
    return TransactionRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      categoryId: map['category_id'] as String?,
      type: TxType.fromString(map['type'] as String?),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      // Tabel finance_transactions memakai kolom description/notes.
      title: (map['description'] ?? map['title']) as String? ?? 'Transaksi',
      note: (map['notes'] ?? map['note']) as String?,
      merchant:
          (map['merchant'] as String?) ??
          (receipt?['merchant_name'] as String?),
      date: _parseDate(map['transaction_date']),
      receiptPath:
          (map['receipt_path'] as String?) ??
          (receipt?['storage_path'] as String?),
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  /// Mengambil data struk pertama dari hasil join `finance_receipts`.
  static Map<String, dynamic>? _firstReceipt(Object? value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) return Map<String, dynamic>.from(first);
    } else if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
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
      'user_id': ?userId,
      'category_id': categoryId,
      'type': type.value,
      'amount': amount,
      'description': title.trim(),
      'notes': note.trim().isEmpty ? null : note.trim(),
      'transaction_date': _dateOnly(date),
    };
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
