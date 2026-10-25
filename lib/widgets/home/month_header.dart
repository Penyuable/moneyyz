import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';

class MonthHeader extends ConsumerWidget {
  const MonthHeader({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              Text(formatMonthYear(month), style: context.texts.titleMedium),
              if (!isCurrentMonth)
                GestureDetector(
                  onTap: onToday,
                  child: Text('Kembali ke bulan ini', style: TextStyle(color: context.scheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
