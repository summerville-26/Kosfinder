import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/owner_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockLoggedInAuthRepo extends AuthRepository {
  final User _user = const User(
    id: 'user-owner-1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-11-20T00:00:00Z',
    email: 'juragankos@gmail.com',
  );

  bool loggedOut = false;

  @override
  User? get currentUser => loggedOut ? null : _user;

  @override
  Future<void> signOut() async {
    loggedOut = true;
  }
}

void main() {
  group('OwnerDashboardScreen Widget Tests', () {
    testWidgets('Displays user email and Kos Saya section',
        (WidgetTester tester) async {
      final repo = MockLoggedInAuthRepo();
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const OwnerDashboardScreen(),
          ),
        ),
      );

      expect(find.text('Dashboard Pemilik'), findsOneWidget);
      expect(find.text('juragankos@gmail.com'), findsOneWidget);
      expect(find.text('Kos Saya'), findsOneWidget);
      expect(find.text('Belum Ada Kos Terdaftar'), findsOneWidget);
    });

    testWidgets('Tapping logout button shows confirmation dialog and signs out',
        (WidgetTester tester) async {
      final repo = MockLoggedInAuthRepo();
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const OwnerDashboardScreen(),
          ),
        ),
      );

      // Tap logout icon
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Keluar dari Akun?'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(provider.isAuthenticated, isFalse);
    });
  });
}
