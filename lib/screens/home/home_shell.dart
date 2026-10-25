import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_ext.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/initials.dart' as init;
import '../../providers/app_providers.dart';
import '../../widgets/home/balance_card.dart';
import '../../widgets/home/month_header.dart';
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
                            'Halo, ${(ref.watch(currentUserProvider)?.userMetadata?['full_name']?.toString() ?? '').isNotEmpty ? (ref.watch(currentUserProvider)?.userMetadata?['full_name']?.toString().split(' ').first ?? 'kamu') : 'kamu'}',
                            style: context.texts.titleLarge,
                          ),
                          Text(
                            'Yuk, pantau keuangan bulan ini',
                            style: context.texts.bodyMedium?.copyWith(color: context.mutedColor),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: context.scheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        init.initialsOf(ref.watch(currentUserProvider)?.userMetadata?['full_name']?.toString() ?? ref.watch(currentUserProvider)?.email),
                        style: TextStyle(color: context.scheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                MonthHeader(
                  month: month,
                  onPrevious: () => ref.read(monthFilterProvider.notifier).previous(),
                  onNext: () => ref.read(monthFilterProvider.notifier).next(),
                  onToday: () => ref.read(monthFilterProvider.notifier).today(),
                ),
                const SizedBox(height: 14),
                BalanceCard(summary: summary),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Transaksi', style: context.texts.titleMedium),
                    const Spacer(),
                    Text('${formatMonthYear(month)}', style: context.texts.bodySmall),
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
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 120),
                  child: _EmptyState(),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final tx = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TransactionTile(
                      transaction: tx,
                      categoriesAsync: ref.watch(categoriesProvider(userId)),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Text('Gagal memuat transaksi: $err', style: context.texts.bodyMedium),
            ),
          ),
        ),
      ],
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
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: context.scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.receipt_long_rounded, color: context.scheme.primary, size: 34),
        ),
        const SizedBox(height: 14),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: categories.when(
        data: (items) {
          final income = items.where((c) => c.type.isIncome).toList();
          final expense = items.where((c) => !c.type.isIncome).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              Text('Pemasukan', style: context.texts.titleSmall),
              const SizedBox(height: 10),
              ...income.map((c) => _CategoryTile(category: c)),
              const SizedBox(height: 20),
              Text('Pengeluaran', style: context.texts.titleSmall),
              const SizedBox(height: 10),
              ...expense.map((c) => _CategoryTile(category: c)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final dynamic category;

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
          leading: CircleAvatar(
            backgroundColor: (category.color as Color).withValues(alpha: 0.14),
            child: Icon(Icons.category_rounded, color: category.color as Color),
          ),
          title: Text(category.name as String),
          subtitle: Text(category.type.label as String, style: context.texts.bodySmall),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: context.scheme.primary.withValues(alpha: 0.12),
                child: Text(
                  init.initialsOf(user?.userMetadata?['full_name']?.toString() ?? user?.email),
                  style: TextStyle(color: context.scheme.primary, fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(user?.userMetadata?['full_name']?.toString() ?? 'Pengguna'),
              subtitle: Text(user?.email ?? '-'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Akun', style: context.texts.titleSmall),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Keluar'),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text('Saku v1.0.0', style: context.texts.bodySmall),
          ),
        ],
      ),
    );
  }
}
