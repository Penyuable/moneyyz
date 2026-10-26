import 'package:flutter/material.dart';

import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';

class MonthHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Bulan sebelumnya',
            onTap: onPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  formatMonthYear(month),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.titleMedium,
                ),
                const SizedBox(height: 1),
                if (isCurrentMonth)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: context.scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Bulan berjalan',
                        style: context.texts.bodySmall?.copyWith(fontSize: 10.5),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: onToday,
                    child: Text(
                      'Kembali ke bulan ini',
                      style: TextStyle(
                        color: context.scheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Bulan berikutnya',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: context.faintColor,
        foregroundColor: context.scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 21),
    );
  }
}
