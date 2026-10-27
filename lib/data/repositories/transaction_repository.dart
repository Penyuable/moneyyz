import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_record.dart';

class TransactionRepository {
  TransactionRepository(this._client);
  final SupabaseClient _client;
  static const String _table = 'finance_transactions';
  static const String _receiptTable = 'finance_receipts';
  Future<List<TransactionRecord>> fetchRange({
    required String userId,
    required DateTime from,
    required DateTime to,
    String? type,
  }) async {
    var query = _client
        .from(_table)
        .select('*, $_receiptTable(storage_path, merchant_name)')
        .eq('user_id', userId)
        .gte('transaction_date', _dateOnly(from))
        .lte('transaction_date', _dateOnly(to));

    if (type != null) {
      query = query.eq('type', type);
    }

    final rows = await query
        .order('transaction_date', ascending: false)
        .order('created_at', ascending: false);

    return rows
        .map((row) => TransactionRecord.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<TransactionRecord> create(TransactionDraft draft) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Belum login');

    final row = await _client
        .from(_table)
        .insert(draft.toMap(userId: userId))
        .select()
        .single();
    final record = TransactionRecord.fromMap(Map<String, dynamic>.from(row));

    await _saveReceipt(transactionId: record.id, userId: userId, draft: draft);

    return record;
  }

  Future<void> update(String id, TransactionDraft draft) async {
    await _client.from(_table).update(draft.toMap()).eq('id', id);

    if (draft.receiptPath == null) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Belum login');

    // Struk disimpan di tabel terpisah, ganti metadata lama jika ada.
    await _client.from(_receiptTable).delete().eq('transaction_id', id);
    await _saveReceipt(transactionId: id, userId: userId, draft: draft);
  }

  Future<void> delete(String id) async {
    // finance_receipts memiliki foreign key ke finance_transactions.
    await _client.from(_receiptTable).delete().eq('transaction_id', id);
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> deleteAll(String userId) async {
    final receipts = await _client
        .from(_receiptTable)
        .select('transaction_id')
        .eq('user_id', userId);

    if (receipts.isNotEmpty) {
      final ids = receipts
          .map((row) => row['transaction_id'])
          .whereType<String>()
          .toList();
      if (ids.isNotEmpty) {
        await _client.from(_receiptTable).delete().inFilter('transaction_id', ids);
      }
    }

    await _client.from(_table).delete().eq('user_id', userId);
  }

  Future<void> _saveReceipt({
    required String transactionId,
    required String userId,
    required TransactionDraft draft,
  }) async {
    final path = draft.receiptPath;
    if (path == null || path.isEmpty) return;

    try {
      await _client.from(_receiptTable).insert({
        'transaction_id': transactionId,
        'user_id': userId,
        'storage_path': path,
        'file_name': path.split('/').last,
        'merchant_name': draft.merchant?.trim().isEmpty == true
            ? null
            : draft.merchant?.trim(),
      });
    } catch (error) {
      // Transaksi utama tetap tersimpan walau metadata struk gagal dicatat.
      debugPrint('Gagal menyimpan metadata struk: $error');
    }
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
