import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

/// Provider untuk mengelola state autentikasi, sesi login/register, dan logout pemilik kos.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _initCurrentUser();
  }

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;
  User? _currentUser;

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.authenticating;
  bool get isError => _status == AuthStatus.error;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;

  void _initCurrentUser() {
    final user = _repository.currentUser;
    if (user != null) {
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  /// Masuk (login) menggunakan email dan password terdaftar.
  Future<bool> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _status = AuthStatus.error;
      _errorMessage = 'Email dan kata sandi wajib diisi';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapAuthException(e);
      notifyListeners();
      return false;
    } catch (_) {
      _status = AuthStatus.error;
      _errorMessage = 'Gagal masuk. Periksa koneksi internet Anda';
      notifyListeners();
      return false;
    }
  }

  /// Mendaftarkan akun pemilik kos baru.
  Future<bool> signUp(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _status = AuthStatus.error;
      _errorMessage = 'Email dan kata sandi wajib diisi';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _status = AuthStatus.error;
      _errorMessage = 'Kata sandi minimal 6 karakter';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapAuthException(e);
      notifyListeners();
      return false;
    } catch (_) {
      _status = AuthStatus.error;
      _errorMessage = 'Gagal mendaftar. Periksa koneksi internet Anda';
      notifyListeners();
      return false;
    }
  }

  /// Keluar dari sesi akun saat ini.
  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Menghapus pesan kesalahan.
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  String _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Email atau kata sandi tidak sesuai';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already exists')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain atau masuk.';
    }
    if (msg.contains('invalid email')) {
      return 'Format email tidak valid';
    }
    return e.message;
  }
}
