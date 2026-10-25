import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_icons.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_record.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categoriesAsync,
  });

  final TransactionRecord transaction;
  final AsyncValue categoriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    dynamic category;
    if (categoriesAsync is AsyncData) {
      final items = (categoriesAsync as AsyncData).value;
      for (final item in items) {
        if (item.id == transaction.categoryId) {
          category = item;
          break;
        }
      }
    }

    final color = (category?.color) ?? (transaction.isIncome ? const Color(0xFF10B981) : const Color(0xFFF43F5E));
    final icon = categoryIcon(category?.icon);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          category?.name ?? (transaction.isIncome ? 'Pemasukan' : 'Pengeluaran'),
          style: context.texts.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatSignedRupiah(transaction.amount, isIncome: transaction.isIncome),
              style: TextStyle(
                color: transaction.isIncome ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(formatDayMonth(transaction.date), style: context.texts.bodySmall),
          ],
        ),
      ),
    );
  }
}
