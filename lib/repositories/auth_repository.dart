import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository untuk mengelola operasi autentikasi pengguna melalui Supabase Auth.
class AuthRepository {
  final SupabaseClient? _client;

  AuthRepository([this._client]);

  /// Mengembalikan instance [SupabaseClient] aktif atau melemparkan exception jika belum siap.
  SupabaseClient get client {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase belum diinisialisasi.');
    }
  }

  /// Pengguna yang sedang terautentikasi saat ini.
  User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Sesi autentikasi yang sedang aktif saat ini.
  Session? get currentSession {
    try {
      return client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  /// Memeriksa apakah terdapat sesi pengguna yang valid.
  bool get isAuthenticated => currentUser != null;

  /// Aliran perubahan status autentikasi Supabase.
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  /// Masuk (login) dengan email dan password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Pendaftaran (registrasi) akun baru dengan email dan password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  /// Keluar (logout) dari sesi aktif.
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
