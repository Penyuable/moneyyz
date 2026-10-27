import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction_record.dart';
import '../../providers/app_providers.dart';
import '../../widgets/home/month_header.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final month = ref.watch(monthFilterProvider);
    final transactions = ref.watch(transactionsProvider(userId));
    final categories = ref.watch(categoriesProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          MonthHeader(
            month: month,
            onPrevious: () => ref.read(monthFilterProvider.notifier).previous(),
            onNext: () => ref.read(monthFilterProvider.notifier).next(),
            onToday: () => ref.read(monthFilterProvider.notifier).today(),
          ),
          const SizedBox(height: 16),
          if (userId.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            transactions.when(
              data: (items) => _StatisticsContent(
                month: month,
                transactions: items,
                categories: categories.asData?.value ?? const <Category>[],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Gagal memuat statistik: $err',
                  style: context.texts.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.month,
    required this.transactions,
    required this.categories,
  });

  final DateTime month;
  final List<TransactionRecord> transactions;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptyStatistics();
    }

    var income = 0.0;
    var expense = 0.0;
    final expenseByCategory = <String, double>{};

    for (final tx in transactions) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
        final key = tx.categoryId ?? '__none__';
        expenseByCategory[key] = (expenseByCategory[key] ?? 0) + tx.amount;
      }
    }

    return Column(
      children: [
        _CashFlowPieCard(income: income, expense: expense),
        const SizedBox(height: 14),
        _WeeklyCashFlowCard(month: month, transactions: transactions),
        if (expenseByCategory.isNotEmpty) ...[
          const SizedBox(height: 14),
          _CategoryBreakdownCard(
            totals: expenseByCategory,
            categories: categories,
            totalExpense: expense,
          ),
        ],
      ],
    );
  }
}

class _CashFlowPieCard extends StatelessWidget {
  const _CashFlowPieCard({required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final incomeShare = total <= 0 ? 0.0 : income / total;
    final expenseShare = total <= 0 ? 0.0 : expense / total;

    final sections = <PieChartSectionData>[
      if (income > 0)
        PieChartSectionData(
          value: income,
          color: AppColors.income,
          radius: 40,
          showTitle: incomeShare >= 0.08,
          title: '${(incomeShare * 100).round()}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      if (expense > 0)
        PieChartSectionData(
          value: expense,
          color: AppColors.expense,
          radius: 40,
          showTitle: expenseShare >= 0.08,
          title: '${(expenseShare * 100).round()}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
    ];

    return _StatsCard(
      title: 'Komposisi arus kas',
      subtitle: 'Perbandingan pemasukan dan pengeluaran',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 4,
                    centerSpaceRadius: 58,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCompactRupiah(total),
                      style: context.texts.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LegendAmount(
                  color: AppColors.income,
                  label: 'Pemasukan',
                  amount: income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LegendAmount(
                  color: AppColors.expense,
                  label: 'Pengeluaran',
                  amount: expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyCashFlowCard extends StatelessWidget {
  const _WeeklyCashFlowCard({required this.month, required this.transactions});

  final DateTime month;
  final List<TransactionRecord> transactions;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final buckets = List.generate(5, (_) => _CashFlowBucket());

    for (final tx in transactions) {
      final index = ((tx.date.day - 1) ~/ 7).clamp(0, 4);
      final bucket = buckets[index];
      if (tx.isIncome) {
        bucket.income += tx.amount;
      } else {
        bucket.expense += tx.amount;
      }
    }

    var maxValue = 0.0;
    for (final bucket in buckets) {
      maxValue = math.max(maxValue, math.max(bucket.income, bucket.expense));
    }
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.25;
    final interval = maxY / 4;

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < buckets.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: buckets[i].income,
              color: AppColors.income,
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: buckets[i].expense,
              color: AppColors.expense,
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return _StatsCard(
      title: 'Arus kas mingguan',
      subtitle: 'Pemasukan vs pengeluaran per minggu',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(color: AppColors.income, label: 'Masuk'),
              const SizedBox(width: 14),
              _LegendDot(color: AppColors.expense, label: 'Keluar'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barGroups: groups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: context.borderColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value <= 0) return const SizedBox.shrink();
                        return Text(
                          formatCompactRupiah(value),
                          style: context.texts.bodySmall?.copyWith(
                            fontSize: 9,
                            color: context.mutedColor,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= buckets.length) {
                          return const SizedBox.shrink();
                        }
                        final start = index * 7 + 1;
                        if (start > daysInMonth) {
                          return const SizedBox.shrink();
                        }
                        final end = math.min((index + 1) * 7, daysInMonth);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '$start-$end',
                            style: context.texts.bodySmall?.copyWith(
                              fontSize: 9.5,
                              color: context.mutedColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.brandDeep,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatRupiah(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.totals,
    required this.categories,
    required this.totalExpense,
  });

  final Map<String, double> totals;
  final List<Category> categories;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = entries.take(5).toList();
    final categoryById = {
      for (final category in categories) category.id: category,
    };

    return _StatsCard(
      title: 'Pengeluaran per kategori',
      subtitle: topEntries.length == entries.length
          ? 'Semua kategori bulan ini'
          : '5 kategori terbesar bulan ini',
      child: Column(
        children: [
          for (var i = 0; i < topEntries.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _CategoryBar(
              entry: topEntries[i],
              category: categoryById[topEntries[i].key],
              totalExpense: totalExpense,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.entry,
    required this.category,
    required this.totalExpense,
  });

  final MapEntry<String, double> entry;
  final Category? category;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? context.mutedColor;
    final name = category?.name ?? 'Tanpa kategori';
    final ratio = totalExpense <= 0
        ? 0.0
        : (entry.value / totalExpense).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(categoryIcon(category?.icon), color: color, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRupiah(entry.value),
                    style: context.texts.labelLarge?.copyWith(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 5,
                  backgroundColor: context.faintColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: context.texts.bodySmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LegendAmount extends StatelessWidget {
  const _LegendAmount({
    required this.color,
    required this.label,
    required this.amount,
  });

  final Color color;
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.texts.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            formatRupiah(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: context.texts.bodySmall?.copyWith(fontSize: 10.5)),
      ],
    );
  }
}

class _EmptyStatistics extends StatelessWidget {
  const _EmptyStatistics();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.scheme.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: context.scheme.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text('Belum ada data bulan ini', style: context.texts.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Tambahkan transaksi untuk melihat grafik\npemasukan dan pengeluaranmu.',
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium?.copyWith(
              color: context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashFlowBucket {
  double income = 0;
  double expense = 0;
}
