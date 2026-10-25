/// Konfigurasi aplikasi.
///
/// Nilai default sudah menunjuk ke project Supabase Saku. Kamu bisa
/// menimpanya saat build tanpa mengubah kode:
///
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
/// ```
class AppConfig {
  const AppConfig();

  static const String appName = 'Saku';
  static const String appTagline = 'Catatan keuangan yang rapi, tanpa ribet.';
  static const String appVersion = '1.0.0';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zinercfursugqdwizipc.supabase.co',
  );

  /// Publishable key aman dipakai di client selama RLS aktif.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_AxSnL3O2vPYO07ngkyj6FQ_2HShWeAT',
  );

  static const String receiptsBucket = 'receipts';
}
