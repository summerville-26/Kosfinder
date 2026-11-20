/// Konfigurasi aplikasi yang membaca variabel lingkungan dari `--dart-define`.
class AppConfig {
  /// URL proyek Supabase.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Kunci anonim publik Supabase.
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Memeriksa apakah URL dan Kunci Anonim sudah dikonfigurasi.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
