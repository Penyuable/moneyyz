import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/category_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/error_messages.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/receipt_parser.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction_record.dart';
import '../../data/models/tx_type.dart';
import '../../providers/app_providers.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _merchant = TextEditingController();

  TxType _type = TxType.expense;
  Category? _category;
  DateTime _date = DateTime.now();
  File? _receiptFile;
  String? _receiptPath;
  bool _loading = false;
  bool _scanning = false;

  @override
  void dispose() {
    _tab.dispose();
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    _merchant.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ref.read(imagePickerProvider);
    final file = await picker.pickImage(context);
    if (file == null) return;
    setState(() {
      _receiptFile = file;
      _scanning = true;
    });
    try {
      final text = await ref.read(ocrServiceProvider).scanReceipt(file);
      final parsed = ReceiptParser.parse(text);
      setState(() {
        if (parsed.amount != null) {
          _amount.text = formatNumber(parsed.amount!.round());
        }
        if (parsed.merchant != null && _title.text.isEmpty) {
          _title.text = parsed.merchant!;
        }
        if (parsed.date != null) {
          _date = parsed.date!;
        }
        if (parsed.merchant != null) {
          _merchant.text = parsed.merchant!;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membaca teks struk. Kamu bisa isi manual.')),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      String? receiptPath = _receiptPath;
      if (_receiptFile != null && receiptPath == null) {
        receiptPath = await ref.read(receiptRepositoryProvider).uploadReceipt(
          file: _receiptFile!,
        );
      }

      final amount = parseCurrencyInput(_amount.text);
      final draft = TransactionDraft(
        type: _type,
        amount: amount,
        title: _title.text.trim(),
        date: _date,
        categoryId: _category!.id,
        note: _note.text,
        merchant: _merchant.text.trim().isEmpty ? null : _merchant.text.trim(),
        receiptPath: receiptPath,
      );

      await ref.read(transactionRepositoryProvider).create(draft);
      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null) {
        ref.invalidate(transactionsProvider(userId));
        ref.invalidate(monthSummaryProvider(userId));
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_type.isIncome ? 'Pemasukan berhasil dicatat' : 'Pengeluaran berhasil dicatat'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final categories = ref.watch(categoriesProvider(user?.id ?? ''));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, controller) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: context.scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Text('Tambah Transaksi', style: context.texts.titleLarge),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tab,
                  onTap: (index) => setState(() => _type = index == 0 ? TxType.expense : TxType.income),
                  tabs: const [
                    Tab(text: 'Pengeluaran'),
                    Tab(text: 'Pemasukan'),
                  ],
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
                    children: [
                      _ScanReceiptCard(
                        file: _receiptFile,
                        scanning: _scanning,
                        onPick: _pickReceipt,
                        onRemove: () => setState(() {
                          _receiptFile = null;
                          _receiptPath = null;
                        }),
                      ),
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nominal', style: context.texts.labelLarge),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _amount,
                              keyboardType: TextInputType.number,
                              inputFormatters: const [CurrencyInputFormatter()],
                              style: context.texts.headlineSmall?.copyWith(fontSize: 28),
                              decoration: const InputDecoration(
                                prefixText: 'Rp ',
                                hintText: '0',
                              ),
                              validator: (v) {
                                final parsed = parseCurrencyInput(v ?? '');
                                if (parsed <= 0) return 'Nominal wajib diisi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text('Judul', style: context.texts.labelLarge),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _title,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Contoh: Belanja bulanan',
                                prefixIcon: Icon(Icons.edit_outlined),
                              ),
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) return 'Judul wajib diisi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text('Kategori', style: context.texts.labelLarge),
                            const SizedBox(height: 10),
                            categories.when(
                              data: (items) {
                                final filtered = items.where((c) => c.type == _type).toList();
                                if (filtered.isEmpty) {
                                  return Text('Belum ada kategori untuk jenis ini', style: context.texts.bodySmall);
                                }
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: filtered.map((cat) {
                                    final selected = _category?.id == cat.id;
                                    return ChoiceChip(
                                      selected: selected,
                                      onSelected: (_) => setState(() => _category = cat),
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(categoryIcon(cat.icon), size: 18, color: selected ? cat.color : context.mutedColor),
                                          const SizedBox(width: 6),
                                          Text(cat.name),
                                        ],
                                      ),
                                      selectedColor: cat.color.withValues(alpha: 0.16),
                                      side: BorderSide(color: selected ? cat.color : context.borderColor),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (err, _) => Text('Gagal memuat kategori: $err', style: context.texts.bodySmall),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tanggal', style: context.texts.labelLarge),
                                      const SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        onPressed: _pickDate,
                                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                                        label: Text(DateFormat('d MMM yyyy', 'id_ID').format(_date),
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Merchant (opsional)', style: context.texts.labelLarge),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _merchant,
                                        decoration: const InputDecoration(
                                          hintText: 'Nama toko',
                                          prefixIcon: Icon(Icons.storefront_outlined),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Catatan (opsional)', style: context.texts.labelLarge),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _note,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Tambah catatan...',
                              ),
                            ),
                            const SizedBox(height: 22),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(_type.isIncome ? 'Simpan Pemasukan' : 'Simpan Pengeluaran'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScanReceiptCard extends StatelessWidget {
  const _ScanReceiptCard({
    required this.file,
    required this.scanning,
    required this.onPick,
    required this.onRemove,
  });

  final File? file;
  final bool scanning;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              file!,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton.filledTonal(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          if (scanning)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 10),
                      Text('Membaca struk...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.scanGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.document_scanner_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan Struk Belanja', style: context.texts.titleMedium?.copyWith(color: Colors.white)),
                  Text(
                    'Otomatis isi nominal & nama toko',
                    style: context.texts.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
