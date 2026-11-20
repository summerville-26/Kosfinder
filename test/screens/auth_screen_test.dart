import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/auth_screen.dart';
import 'package:kosfinder/screens/owner_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSuccessAuthRepo extends AuthRepository {
  final User _mockUser = const User(
    id: 'user-1234',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-11-20T00:00:00Z',
    email: 'owner@test.com',
  );

  @override
  User? get currentUser => null;

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
}

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('Renders tabs and switches between Masuk and Daftar',
        (WidgetTester tester) async {
      final provider = AuthProvider(repository: MockSuccessAuthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const AuthScreen(),
          ),
        ),
      );

      expect(find.text('Akun Pemilik Kos'), findsOneWidget);
      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Daftar'), findsOneWidget);

      // Switch to Daftar tab
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Email Baru'), findsOneWidget);
      expect(find.text('Kata Sandi Minimal 6 Karakter'), findsOneWidget);
    });

    testWidgets('Validates empty email and password on login submit',
        (WidgetTester tester) async {
      final provider = AuthProvider(repository: MockSuccessAuthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const AuthScreen(),
          ),
        ),
      );

      // Tap Masuk button with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Shows error message on invalid credentials (US04-AC2)',
        (WidgetTester tester) async {
      final provider = AuthProvider(repository: MockFailureAuthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const AuthScreen(),
          ),
        ),
      );

      // Enter credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'wrong@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kata Sandi'),
        'wrongpass',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Email atau kata sandi tidak sesuai'), findsOneWidget);
    });

    testWidgets('Successful login navigates to OwnerDashboardScreen (US04-AC1)',
        (WidgetTester tester) async {
      final provider = AuthProvider(repository: MockSuccessAuthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const AuthScreen(),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'owner@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kata Sandi'),
        'password123',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(OwnerDashboardScreen), findsOneWidget);
      expect(find.text('Dashboard Pemilik'), findsOneWidget);
    });
  });
}
