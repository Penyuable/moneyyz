import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../core/services/image_picker_service.dart';
import '../core/services/ocr_service.dart';
import '../core/utils/receipt_parser.dart';
import '../data/models/category.dart';
import '../data/models/transaction_record.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/receipt_repository.dart';
import '../data/repositories/transaction_repository.dart';

/// Supabase client global.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// SharedPreferences (diinisialisasi di main).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider harus di-inisialisasi');
});

/// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(supabaseClientProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(supabaseClientProvider));
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(supabaseClientProvider));
});

/// Services
final imagePickerProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(ImagePicker());
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});

/// Auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user ?? Supabase.instance.client.auth.currentUser,
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (_, __) => Supabase.instance.client.auth.currentUser,
  );
});

/// Kategori pengguna
final categoriesProvider = FutureProvider.family<List<Category>, String>((ref, userId) async {
  final repo = ref.watch(categoryRepositoryProvider);
  await repo.seedDefaults(userId);
  return repo.fetchAll(userId);
});

/// Filter bulan aktif
class MonthFilter extends StateNotifier<DateTime> {
  MonthFilter() : super(_startOfMonth(DateTime.now()));

  static DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  void previous() => state = DateTime(state.year, state.month - 1, 1);

  void next() => state = DateTime(state.year, state.month + 1, 1);

  void setMonth(DateTime date) => state = _startOfMonth(date);

  void today() => state = _startOfMonth(DateTime.now());
}

final monthFilterProvider = StateNotifierProvider<MonthFilter, DateTime>((ref) {
  return MonthFilter();
});

/// Transaksi per bulan
final transactionsProvider =
    FutureProvider.family<List<TransactionRecord>, String>((ref, userId) async {
  final month = ref.watch(monthFilterProvider);
  final from = DateTime(month.year, month.month, 1);
  final to = DateTime(month.year, month.month + 1, 0);
  return ref
      .watch(transactionRepositoryProvider)
      .fetchRange(userId: userId, from: from, to: to);
});

/// Summary
class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;
}

final monthSummaryProvider = Provider.family<MonthSummary, String>((ref, userId) {
  final transactions = ref.watch(transactionsProvider(userId));
  return transactions.when(
    data: (items) {
      double income = 0;
      double expense = 0;
      for (final tx in items) {
        if (tx.isIncome) {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }
      return MonthSummary(
        income: income,
        expense: expense,
        balance: income - expense,
      );
    },
    loading: () => const MonthSummary(income: 0, expense: 0, balance: 0),
    error: (_, __) => const MonthSummary(income: 0, expense: 0, balance: 0),
  );
});

/// Scan struk
class ReceiptScanState {
  const ReceiptScanState({
    this.file,
    this.rawText = '',
    this.result = ReceiptParseResult.empty,
    this.isScanning = false,
    this.isUploading = false,
    this.error,
    this.receiptPath,
  });

  final File? file;
  final String rawText;
  final ReceiptParseResult result;
  final bool isScanning;
  final bool isUploading;
  final String? error;
  final String? receiptPath;

  ReceiptScanState copyWith({
    File? file,
    String? rawText,
    ReceiptParseResult? result,
    bool? isScanning,
    bool? isUploading,
    String? error,
    String? receiptPath,
    bool clearError = false,
    bool clearFile = false,
    bool clearPath = false,
  }) {
    return ReceiptScanState(
      file: clearFile ? null : (file ?? this.file),
      rawText: rawText ?? this.rawText,
      result: result ?? this.result,
      isScanning: isScanning ?? this.isScanning,
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : (error ?? this.error),
      receiptPath: clearPath ? null : (receiptPath ?? this.receiptPath),
    );
  }
}

class ReceiptScanNotifier extends StateNotifier<ReceiptScanState> {
  ReceiptScanNotifier(this.ref) : super(const ReceiptScanState());

  final Ref ref;

  Future<void> pickAndScan(BuildContext context) async {
    final picker = ref.read(imagePickerProvider);

    final file = await picker.pickImage(context);
    if (file == null) return;

    state = state.copyWith(
      file: file,
      isScanning: true,
      clearError: true,
      clearPath: true,
    );

    try {
      final text = await ref.read(ocrServiceProvider).scanReceipt(file);
      final parsed = ReceiptParser.parse(text);
      state = state.copyWith(
        rawText: text,
        result: parsed,
        isScanning: false,
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: 'Gagal membaca teks struk. Coba foto yang lebih jelas.',
      );
    }
  }

  Future<void> uploadReceipt() async {
    final file = state.file;
    if (file == null) return;
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final path = await ref.read(receiptRepositoryProvider).uploadReceipt(
        file: file,
      );
      state = state.copyWith(isUploading: false, receiptPath: path);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Gagal mengunggah foto struk.',
      );
    }
  }

  void reset() {
    state = const ReceiptScanState();
  }
}



final receiptScanProvider =
    StateNotifierProvider<ReceiptScanNotifier, ReceiptScanState>((ref) {
  return ReceiptScanNotifier(ref);
});

/// App config
final appConfigProvider = Provider((ref) => AppConfig());
