import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';

/// Halaman placeholder fitur rencana tabungan.
///
/// Belum ada data atau form yang disimpan. Halaman ini hanya menampilkan
/// pratinjau fitur yang sedang disiapkan.
class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rencana Tabungan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const _ComingSoonHero(),
          const SizedBox(height: 26),
          Text('Yang akan datang', style: context.texts.titleSmall),
          const SizedBox(height: 10),
          const _FeatureTile(
            icon: Icons.flag_rounded,
            color: AppColors.brand,
            title: 'Target fleksibel',
            description: 'Tentukan nominal target dan tanggal akhir tabungan.',
          ),
          const SizedBox(height: 10),
          const _FeatureTile(
            icon: Icons.trending_up_rounded,
            color: AppColors.accent,
            title: 'Progres otomatis',
            description: 'Pantau persentase dana yang sudah terkumpul.',
          ),
          const SizedBox(height: 10),
          const _FeatureTile(
            icon: Icons.notifications_active_rounded,
            color: AppColors.warning,
            title: 'Pengingat target',
            description: 'Dapatkan pengingat agar tabungan tetap on track.',
          ),
          const SizedBox(height: 26),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock_clock_rounded),
            label: const Text('Buat Target Baru'),
          ),
          const SizedBox(height: 10),
          Text(
            'Fitur ini sedang disiapkan. Pantau terus ya!',
            textAlign: TextAlign.center,
            style: context.texts.bodySmall?.copyWith(color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonHero extends StatelessWidget {
  const _ComingSoonHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.26),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -54,
            top: -62,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: -80,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: Colors.white,
                        size: 23,
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
                        'SEGERA HADIR',
                        style: context.texts.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Rencana Tabungan',
                  style: context.texts.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tentukan target, sisihkan dana, dan lihat progresnya '
                  'dalam satu tempat.',
                  style: context.texts.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.45,
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

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        title: Text(
          title,
          style: context.texts.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(description, style: context.texts.bodySmall),
        ),
      ),
    );
  }
}
