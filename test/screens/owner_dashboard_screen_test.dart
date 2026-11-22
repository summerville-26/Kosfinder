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
  String? lastDeletedId;
  String? lastUpdatedId;
  Map<String, dynamic>? lastUpdatedData;
  bool shouldFailDelete = false;

  MockOwnerKosRepository([List<Kos>? initialData])
      : ownerData = initialData != null ? List.from(initialData) : [];

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
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async {
    lastUpdatedId = id;
    lastUpdatedData = data;
    final index = ownerData.indexWhere((k) => k.id == id);
    if (index != -1) {
      final updated = ownerData[index].copyWith(
        availableRooms: data['available_rooms'] != null
            ? (data['available_rooms'] as num).toInt()
            : ownerData[index].availableRooms,
      );
      ownerData[index] = updated;
      return updated;
    }
    throw Exception('Kos not found');
  }

  @override
  Future<void> deleteKos(String id) async {
    if (shouldFailDelete) {
      throw Exception(
          'Gagal menghapus data kos. Silakan coba beberapa saat lagi');
    }
    lastDeletedId = id;
    ownerData.removeWhere((k) => k.id == id);
  }
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

    testWidgets(
        'Displays list of owner kos with Ubah and Hapus buttons (US05, US06, US07)',
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
      expect(find.text('Ubah'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.text('3 / 12'), findsOneWidget);
    });

    testWidgets(
        'Quick update room count with [+] and [-] buttons (T13, US06-AC1)',
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

      // Tap [+] to increment rooms (from 3 to 4)
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      expect(kosRepo.lastUpdatedData?['available_rooms'], 4);
      expect(find.text('4 / 12'), findsOneWidget);
      expect(find.text('Sisa 4 kamar'), findsOneWidget);

      // Tap [-] to decrement rooms (from 4 to 3)
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pumpAndSettle();

      expect(kosRepo.lastUpdatedData?['available_rooms'], 3);
      expect(find.text('3 / 12'), findsOneWidget);
      expect(find.text('Sisa 3 kamar'), findsOneWidget);
    });

    testWidgets(
        'Quick update "Set Penuh" changes available rooms to 0 and shows "Penuh" badge (T13, US03-AC1, US06-AC1)',
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

      // Tap "Set Penuh"
      await tester.tap(find.text('Set Penuh'));
      await tester.pumpAndSettle();

      expect(kosRepo.lastUpdatedData?['available_rooms'], 0);
      expect(find.text('Penuh'), findsOneWidget);
      expect(find.text('0 / 12'), findsOneWidget);
      expect(find.text('Buka 1 Kamar'), findsOneWidget);

      // Now tap "Buka 1 Kamar" to reopen
      await tester.tap(find.text('Buka 1 Kamar'));
      await tester.pumpAndSettle();

      expect(kosRepo.lastUpdatedData?['available_rooms'], 1);
      expect(find.text('Sisa 1 kamar'), findsOneWidget);
      expect(find.text('1 / 12'), findsOneWidget);
    });

    testWidgets('Tapping Ubah navigates to KosFormScreen in edit mode (US06-AC1)',
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

      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();

      expect(find.byType(KosFormScreen), findsOneWidget);
      expect(find.text('Ubah Data Kos'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Kos Juragan Mewah'), findsOneWidget);
    });

    testWidgets('Tapping Hapus shows confirmation dialog and canceling keeps kos',
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

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Kos?'), findsOneWidget);
      expect(find.textContaining('Apakah Anda yakin ingin menghapus data kos'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Kos Juragan Mewah'), findsOneWidget);
      expect(kosRepo.lastDeletedId, isNull);
    });

    testWidgets(
        'Confirming Hapus deletes kos permanently and shows success snackbar (US07-AC1)',
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

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Confirm Hapus in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(kosRepo.lastDeletedId, 'k-owner-1');
      expect(find.text('Data kos berhasil dihapus'), findsOneWidget);
      expect(find.text('Belum Ada Kos Terdaftar'), findsOneWidget);
    });

    testWidgets(
        'Hapus failure shows error message and keeps kos (US07-AC2)',
        (WidgetTester tester) async {
      final authRepo = MockLoggedInAuthRepo();
      final kosRepo = MockOwnerKosRepository([sampleKos])..shouldFailDelete = true;
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

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(
        find.text('Gagal menghapus data kos. Silakan coba beberapa saat lagi'),
        findsOneWidget,
      );
      expect(find.text('Kos Juragan Mewah'), findsOneWidget);
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
