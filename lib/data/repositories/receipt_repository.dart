import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';

class ReceiptRepository {
  ReceiptRepository(this._client);

  final SupabaseClient _client;

  Future<String?> uploadReceipt({required File file}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Belum login');

    final ext = _extensionOf(file.path);
    final name = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final path = '$userId/$name';

    await _client.storage.from(AppConfig.receiptsBucket).upload(
      path,
      file,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    return path;
  }

  Future<String> signedUrl(String path) {
    return _client.storage
        .from(AppConfig.receiptsBucket)
        .createSignedUrl(path, 3600);
  }

  Future<void> deleteReceipt(String path) async {
    try {
      await _client.storage.from(AppConfig.receiptsBucket).remove([path]);
    } catch (_) {
      // Abaikan jika file sudah tidak ada.
    }
  }

  static String _extensionOf(String path) {
    final idx = path.lastIndexOf('.');
    if (idx < 0 || idx == path.length - 1) return '.jpg';
    return '.${path.substring(idx + 1).toLowerCase()}';
  }
}
