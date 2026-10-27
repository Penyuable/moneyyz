import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_icons.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_record.dart';
import '../../providers/app_providers.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categoriesAsync,
  });

  final TransactionRecord transaction;
  final AsyncValue categoriesAsync;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserProvider)?.id;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi'),
        content: Text(
          'Yakin mau hapus "${transaction.title}" senilai ${formatRupiah(transaction.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.scheme.error,
              foregroundColor: context.scheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result != true) return;
    try {
      await ref.read(transactionRepositoryProvider).delete(transaction.id);
      if (userId != null) {
        ref.invalidate(transactionsProvider(userId));
        ref.invalidate(monthSummaryProvider(userId));
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus transaksi: $e')),
        );
      }
    }
  }

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

    final color = (category?.color) ??
        (transaction.isIncome
            ? const Color(0xFF10B981)
            : const Color(0xFFF43F5E));
    final icon = categoryIcon(category?.icon);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onLongPress: () => _confirmDelete(context, ref),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(12, 4, 16, 4),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            transaction.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    category?.name ??
                        (transaction.isIncome ? 'Pemasukan' : 'Pengeluaran'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall,
                  ),
                ),
                if (transaction.receiptPath != null) ...[
                  const SizedBox(width: 5),
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 12,
                    color: context.mutedColor.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatSignedRupiah(
                  transaction.amount,
                  isIncome: transaction.isIncome,
                ),
                style: TextStyle(
                  color: transaction.isIncome
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF43F5E),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDayMonth(transaction.date),
                style: context.texts.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
