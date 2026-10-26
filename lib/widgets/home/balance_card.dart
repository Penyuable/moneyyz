import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.summary});

  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    final income = (summary.income as num).toDouble();
    final expense = (summary.expense as num).toDouble();
    final balance = (summary.balance as num).toDouble();
    final ratio = income <= 0 ? 0.0 : (expense / income).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -52,
            top: -64,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            right: 34,
            bottom: -78,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Saldo bulan ini',
                      style: context.texts.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Saku',
                        style: context.texts.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatRupiah(balance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  income <= 0
                      ? 'Belum ada pemasukan bulan ini'
                      : 'Terpakai ${(ratio * 100).toStringAsFixed(0)}% dari pemasukan',
                  style: context.texts.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        label: 'Pemasukan',
                        amount: income,
                        icon: Icons.south_west_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatPill(
                        label: 'Pengeluaran',
                        amount: expense,
                        icon: Icons.north_east_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  formatRupiah(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
