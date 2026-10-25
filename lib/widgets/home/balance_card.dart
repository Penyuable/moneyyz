import 'package:flutter/material.dart';

import '../../core/theme/theme_ext.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.summary});

  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D5DFB), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DFB).withValues(alpha: 0.26),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Bulan Ini',
            style: context.texts.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 6),
          Text(
            'Rp ${_format(summary.balance)}',
            style: context.texts.displaySmall?.copyWith(color: Colors.white, fontSize: 38),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Pemasukan',
                  amount: summary.income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatPill(
                  label: 'Pengeluaran',
                  amount: summary.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _format(double value) {
    final str = value.toStringAsFixed(0);
    final buf = StringBuffer();
    var count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write('.');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join('');
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.texts.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                Text('Rp ${BalanceCard._format(amount)}', style: context.texts.labelLarge?.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
