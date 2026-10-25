import 'package:supabase_flutter/supabase_flutter.dart';

/// Mengubah error teknis menjadi pesan yang ramah pengguna.
String friendlyError(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'Email ini sudah terdaftar. Coba masuk saja.';
    }
    if (message.contains('email not confirmed')) {
      return 'Email belum diverifikasi. Cek kotak masuk kamu.';
    }
    if (message.contains('password should be at least') ||
        message.contains('weak password')) {
      return 'Password minimal 6 karakter.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'Tidak ada koneksi internet. Periksa jaringan kamu.';
    }
    if (message.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    return error.message;
  }

  if (error is PostgrestException) {
    final message = error.message.toLowerCase();
    if (message.contains('row-level security') || error.code == '42501') {
      return 'Kamu tidak punya akses ke data ini.';
    }
    if (error.code == '23514' || message.contains('check constraint')) {
      return 'Data tidak valid. Periksa nominal dan kategori.';
    }
    if (message.contains('relation') && message.contains('does not exist')) {
      return 'Database belum disiapkan. Jalankan file supabase/schema.sql.';
    }
    return 'Gagal menyimpan data: ${error.message}';
  }

  if (error is StorageException) {
    if (error.message.toLowerCase().contains('bucket')) {
      return 'Penyimpanan struk belum siap. Jalankan supabase/schema.sql.';
    }
    return 'Gagal mengunggah foto: ${error.message}';
  }

  if (error is StateError) {
    return error.message;
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
