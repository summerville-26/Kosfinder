import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';
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

class MockOwnerKosRepository extends KosRepository {
  final List<Kos> ownerData;

  MockOwnerKosRepository([this.ownerData = const []]);

  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async =>
      [];

  @override
  Future<List<Kos>> getKosByOwner(String ownerId) async {
    return ownerData.where((k) => k.ownerId == ownerId).toList();
  }

  @override
  Future<Kos> createKos(Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteKos(String id) async => throw UnimplementedError();
}

void main() {
  group('OwnerDashboardScreen Widget Tests', () {
    final sampleKos = Kos(
      id: 'k-owner-1',
      ownerId: 'user-owner-1',
      name: 'Kos Juragan Mewah',
      area: 'Dipati Ukur',
      address: 'Jl. Dipati Ukur No. 50',
      price: 2500000,
      totalRooms: 12,
      availableRooms: 3,
      facilities: const ['Wi-Fi', 'AC'],
      contactNumber: '081234567890',
    );

    testWidgets('Displays user email and empty state when owner has no kos',
        (WidgetTester tester) async {
      final authRepo = MockLoggedInAuthRepo();
      final kosRepo = MockOwnerKosRepository([]);
      final authProvider = AuthProvider(repository: authRepo);
      final kosProvider = KosProvider(repository: kosRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
            ],
            child: const OwnerDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dashboard Pemilik'), findsOneWidget);
      expect(find.text('juragankos@gmail.com'), findsOneWidget);
      expect(find.text('Kos Saya'), findsOneWidget);
      expect(find.text('Belum Ada Kos Terdaftar'), findsOneWidget);
      expect(find.text('Tambah Kos'), findsOneWidget);
    });

    testWidgets('Displays list of owner kos when owner has kos (US05-AC1)',
        (WidgetTester tester) async {
      final authRepo = MockLoggedInAuthRepo();
      final kosRepo = MockOwnerKosRepository([sampleKos]);
      final authProvider = AuthProvider(repository: authRepo);
      final kosProvider = KosProvider(repository: kosRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
            ],
            child: const OwnerDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kos Juragan Mewah'), findsOneWidget);
      expect(find.text('Dipati Ukur'), findsOneWidget);
      expect(find.text('Sisa 3 kamar'), findsOneWidget);
      expect(find.text('Belum Ada Kos Terdaftar'), findsNothing);
    });

    testWidgets('Tapping Tambah Kos navigates to KosFormScreen',
        (WidgetTester tester) async {
      final authRepo = MockLoggedInAuthRepo();
      final kosRepo = MockOwnerKosRepository([]);
      final authProvider = AuthProvider(repository: authRepo);
      final kosProvider = KosProvider(repository: kosRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
            ],
            child: const OwnerDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah Kos'));
      await tester.pumpAndSettle();

      expect(find.byType(KosFormScreen), findsOneWidget);
      expect(find.text('Tambah Kos Baru'), findsOneWidget);
    });

    testWidgets('Tapping logout button shows confirmation dialog and signs out',
        (WidgetTester tester) async {
      final authRepo = MockLoggedInAuthRepo();
      final kosRepo = MockOwnerKosRepository([]);
      final authProvider = AuthProvider(repository: authRepo);
      final kosProvider = KosProvider(repository: kosRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
            ],
            child: const OwnerDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap logout icon
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Keluar dari Akun?'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(authProvider.isAuthenticated, isFalse);
    });
  });
}
