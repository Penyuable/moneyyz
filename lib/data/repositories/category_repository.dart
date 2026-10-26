import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/category_icons.dart';
import '../models/category.dart';
import '../models/tx_type.dart';

class CategoryRepository {
  CategoryRepository(this._client);

  final SupabaseClient _client;

  Future<List<Category>> fetchAll(String userId) async {
    final rows = await _client
        .from('finance_categories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return rows
        .map((row) => Category.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Category> create(Category category) async {
    final row = await _client
        .from('finance_categories')
        .insert(category.toInsert(userId: category.userId))
        .select()
        .single();
    return Category.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> update(Category category) async {
    await _client
        .from('finance_categories')
        .update(category.toUpdate())
        .eq('id', category.id);
  }

  Future<void> delete(String id) async {
    await _client.from('finance_categories').delete().eq('id', id);
  }

  /// Mengisi kategori bawaan untuk pengguna baru.
  Future<void> seedDefaults(String userId) async {
    final rows = kDefaultCategories.map((seed) => seed.toMap(userId)).toList();

    final existing = await _client
        .from('finance_categories')
        .select('name, type')
        .eq('user_id', userId);

    final existingKeys = existing
        .map((row) => '${row['type']}|${row['name']}')
        .toSet();

    final missing = rows
        .where((row) => !existingKeys.contains('${row['type']}|${row['name']}'))
        .toList();

    if (missing.isEmpty) return;
    await _client.from('finance_categories').insert(missing);
  }

  /// Warna default untuk kategori baru.
  static int nextColorIndex(int currentCount) {
    return kCategoryColors[currentCount % kCategoryColors.length];
  }

  static TxType? typeFromIndex(int index) {
    return index == 0 ? TxType.income : TxType.expense;
  }
}
