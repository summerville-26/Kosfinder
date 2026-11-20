import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSuccessAuthRepo extends AuthRepository {
  final User _mockUser = const User(
    id: 'user-1234',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-11-20T00:00:00Z',
  );

  bool signedOut = false;

  @override
  User? get currentUser => signedOut ? null : null;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return AuthResponse(
      session: Session(
        accessToken: 'mock-token',
        tokenType: 'bearer',
        user: _mockUser,
      ),
      user: _mockUser,
    );
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return AuthResponse(user: _mockUser);
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

class MockFailureAuthRepo extends AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    throw const AuthException('Invalid login credentials');
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    throw const AuthException('User already registered');
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('AuthProvider Tests', () {
    test('Initial state is unauthenticated when no user is logged in', () {
      final provider = AuthProvider(repository: MockSuccessAuthRepo());

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('signIn succeeds and updates status to authenticated (US04-AC1)',
        () async {
      final repo = MockSuccessAuthRepo();
      final provider = AuthProvider(repository: repo);

      final success = await provider.signIn('owner@test.com', 'password123');

      expect(success, isTrue);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.id, 'user-1234');
      expect(provider.errorMessage, isNull);
    });

    test('signIn fails with invalid credentials and sets error (US04-AC2)',
        () async {
      final repo = MockFailureAuthRepo();
      final provider = AuthProvider(repository: repo);

      final success = await provider.signIn('wrong@test.com', 'wrongpass');

      expect(success, isFalse);
      expect(provider.status, AuthStatus.error);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, 'Email atau kata sandi tidak sesuai');
    });

    test('signIn validates empty email and password', () async {
      final provider = AuthProvider(repository: MockSuccessAuthRepo());

      final success = await provider.signIn('', '');

      expect(success, isFalse);
      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, 'Email dan kata sandi wajib diisi');
    });

    test('signUp succeeds and updates status to authenticated', () async {
      final repo = MockSuccessAuthRepo();
      final provider = AuthProvider(repository: repo);

      final success =
          await provider.signUp('newowner@test.com', 'password123');

      expect(success, isTrue);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.currentUser?.id, 'user-1234');
    });

    test('signUp fails when password is less than 6 characters', () async {
      final provider = AuthProvider(repository: MockSuccessAuthRepo());

      final success = await provider.signUp('test@test.com', '12345');

      expect(success, isFalse);
      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, 'Kata sandi minimal 6 karakter');
    });

    test('signOut clears currentUser and returns status to unauthenticated',
        () async {
      final repo = MockSuccessAuthRepo();
      final provider = AuthProvider(repository: repo);

      await provider.signIn('owner@test.com', 'password123');
      expect(provider.isAuthenticated, isTrue);

      await provider.signOut();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.currentUser, isNull);
    });
  });
}
