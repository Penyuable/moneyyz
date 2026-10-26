import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/category_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/initials.dart' as init;
import '../../data/models/category.dart';
import '../../data/models/transaction_record.dart';
import '../../providers/app_providers.dart';
import '../../widgets/home/balance_card.dart';
import '../../widgets/home/month_header.dart';
import '../../widgets/home/savings_plan_card.dart';
import '../../widgets/home/transaction_tile.dart';
import '../../widgets/transaction/quick_add_sheet.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final pages = [
      _HomeDashboard(userId: user?.id ?? ''),
      const _CategoriesPage(),
      const _SettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(top: false, child: pages[_index]),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const QuickAddSheet(),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Kategori',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final month = ref.watch(monthFilterProvider);
    final summary = ref.watch(monthSummaryProvider(userId));
    final transactions = ref.watch(transactionsProvider(userId));
    final user = ref.watch(currentUserProvider);

    final fullName = user?.userMetadata?['full_name']?.toString().trim() ?? '';
    final displayName = fullName.isEmpty
        ? 'Sahabat Saku'
        : fullName.split(RegExp(r'\s+')).first;
    final count = transactions.asData?.value.length ?? 0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(DateTime.now()),
                            style: context.texts.bodyMedium?.copyWith(
                              color: context.mutedColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.headlineSmall?.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          init.initialsOf(
                            fullName.isEmpty ? user?.email : fullName,
                          ),
                          style: TextStyle(
                            color: context.scheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Semua keuanganmu, rapi di satu tempat.',
                  style: context.texts.bodySmall,
                ),
                const SizedBox(height: 18),
                MonthHeader(
                  month: month,
                  onPrevious: () =>
                      ref.read(monthFilterProvider.notifier).previous(),
                  onNext: () => ref.read(monthFilterProvider.notifier).next(),
                  onToday: () => ref.read(monthFilterProvider.notifier).today(),
                ),
                const SizedBox(height: 14),
                BalanceCard(summary: summary),
                const SizedBox(height: 14),
                SavingsPlanCard(onTap: () => context.push('/savings')),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Transaksi', style: context.texts.titleMedium),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: context.texts.labelSmall?.copyWith(
                            color: context.scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      formatMonthYear(month),
                      style: context.texts.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        transactions.when(
          data: (items) {
            if (items.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 36, 20, 120),
                  child: _EmptyState(),
                ),
              );
            }

            final children = <Widget>[];
            String? lastDay;
            for (final tx in items) {
              final day = formatRelativeDay(tx.date);
              if (day != lastDay) {
                if (children.isNotEmpty) {
                  children.add(const SizedBox(height: 6));
                }
                children.add(_DateHeader(label: day));
                lastDay = day;
              }
              children.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TransactionTile(
                    transaction: tx,
                    categoriesAsync: ref.watch(categoriesProvider(userId)),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(delegate: SliverChildListDelegate(children)),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Text(
                'Gagal memuat transaksi: $err',
                style: context.texts.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _greeting(DateTime now) {
    if (now.hour < 11) return 'Selamat pagi,';
    if (now.hour < 15) return 'Selamat siang,';
    if (now.hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Row(
        children: [
          Text(
            label,
            style: context.texts.labelMedium?.copyWith(
              color: context.mutedColor,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: context.borderColor)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: context.scheme.primary.withValues(alpha: 0.09),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: context.scheme.primary,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        Text('Belum ada transaksi', style: context.texts.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Tekan tombol Tambah untuk mencatat pemasukan\natau pengeluaran pertamamu',
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium?.copyWith(color: context.mutedColor),
        ),
      ],
    );
  }
}

class _CategoriesPage extends ConsumerWidget {
  const _CategoriesPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final categories = ref.watch(categoriesProvider(user?.id ?? ''));
    final transactions = ref.watch(transactionsProvider(user?.id ?? ''));

    final totals = <String, double>{};
    for (final tx
        in transactions.asData?.value ?? const <TransactionRecord>[]) {
      final id = tx.categoryId;
      if (id != null) totals[id] = (totals[id] ?? 0) + tx.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                formatMonthYear(ref.watch(monthFilterProvider)),
                style: context.texts.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: categories.when(
        data: (items) {
          final income = items.where((c) => c.type.isIncome).toList();
          final expense = items.where((c) => !c.type.isIncome).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _CategorySectionHeader(
                title: 'Pemasukan',
                count: income.length,
                color: AppColors.income,
                icon: Icons.south_west_rounded,
              ),
              const SizedBox(height: 10),
              ...income.map(
                (c) => _CategoryTile(category: c, total: totals[c.id] ?? 0),
              ),
              const SizedBox(height: 22),
              _CategorySectionHeader(
                title: 'Pengeluaran',
                count: expense.length,
                color: AppColors.expense,
                icon: Icons.north_east_rounded,
              ),
              const SizedBox(height: 10),
              ...expense.map(
                (c) => _CategoryTile(category: c, total: totals[c.id] ?? 0),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String title;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 9),
        Text(title, style: context.texts.titleSmall),
        const SizedBox(width: 7),
        Text(
          '$count kategori',
          style: context.texts.bodySmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.total});

  final Category category;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(12, 4, 16, 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              categoryIcon(category.icon),
              color: category.color,
              size: 21,
            ),
          ),
          title: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(category.type.label, style: context.texts.bodySmall),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total <= 0 ? '—' : formatRupiah(total),
                style: context.texts.labelLarge?.copyWith(
                  color: category.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'bulan ini',
                style: context.texts.bodySmall?.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPage extends ConsumerWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final name = user?.userMetadata?['full_name']?.toString() ?? 'Pengguna';
    final email = user?.email ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    init.initialsOf(name.isEmpty ? email : name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Tampilan', style: context.texts.titleSmall),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema aplikasi',
                    style: context.texts.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sesuaikan tampilan Saku dengan preferensimu.',
                    style: context.texts.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_rounded, size: 18),
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded, size: 18),
                          label: Text('Terang'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded, size: 18),
                          label: Text('Gelap'),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (selection) => ref
                          .read(themeModeProvider.notifier)
                          .setMode(selection.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Akun', style: context.texts.titleSmall),
          const SizedBox(height: 10),
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.scheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: context.scheme.error,
                  size: 19,
                ),
              ),
              title: const Text('Keluar dari akun'),
              subtitle: Text(
                'Kamu bisa masuk kembali kapan saja',
                style: context.texts.bodySmall,
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: context.mutedColor,
              ),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Text(
                  'Saku',
                  style: context.texts.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.mutedColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Versi 1.0.0', style: context.texts.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}
