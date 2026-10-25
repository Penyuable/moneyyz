import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_record.dart';

class TransactionRepository {
  TransactionRepository(this._client);

  final SupabaseClient _client;

  Future<List<TransactionRecord>> fetchRange({
    required String userId,
    required DateTime from,
    required DateTime to,
    String? type,
  }) async {
    var query = _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .gte('transaction_date', _dateOnly(from))
        .lte('transaction_date', _dateOnly(to));

    if (type != null) {
      query = query.eq('type', type);
    }

    final rows = await query.order('transaction_date', ascending: false).order(
      'created_at',
      ascending: false,
    );

    return rows
        .map((row) => TransactionRecord.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<TransactionRecord> create(TransactionDraft draft) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Belum login');

    final row = await _client
        .from('transactions')
        .insert(draft.toMap(userId: userId))
        .select()
        .single();
    return TransactionRecord.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> update(String id, TransactionDraft draft) async {
    await _client
        .from('transactions')
        .update(draft.toMap())
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
