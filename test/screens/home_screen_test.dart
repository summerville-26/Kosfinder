import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/auth_screen.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/screens/owner_dashboard_screen.dart';
import 'package:kosfinder/widgets/empty_state.dart';
import 'package:kosfinder/widgets/kos_card.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSuccessRepo extends KosRepository {
  final List<Kos> data;
  MockSuccessRepo(this.data);

  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async {
    return data.where((k) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final match = k.name.toLowerCase().contains(q) ||
            k.area.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (minPrice != null && k.price < minPrice) return false;
      if (maxPrice != null && k.price > maxPrice) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<Kos>> getKosByOwner(String ownerId) async =>
      data.where((k) => k.ownerId == ownerId).toList();

  @override
  Future<Kos> createKos(Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteKos(String id) async =>
      throw UnimplementedError();
}

class MockErrorRepo extends KosRepository {
  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async =>
      throw Exception('Network error');

  @override
  Future<List<Kos>> getKosByOwner(String ownerId) async =>
      throw Exception('Network error');

  @override
  Future<Kos> createKos(Map<String, dynamic> data) async =>
      throw Exception('Network error');

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async =>
      throw Exception('Network error');

  @override
  Future<void> deleteKos(String id) async =>
      throw Exception('Network error');
}

class MockUnauthRepo extends AuthRepository {
  @override
  User? get currentUser => null;
}

class MockAuthRepoWithUser extends AuthRepository {
  @override
  User? get currentUser => const User(
        id: 'u1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-11-20T00:00:00Z',
        email: 'logged@test.com',
      );
}

void main() {
  group('HomeScreen Widget Tests', () {
    final kosDago = Kos(
      id: 'k1',
      ownerId: 'o1',
      name: 'Kos Cemara Dago',
      area: 'Dago',
      address: 'Jl. Dago Indah No. 1',
      price: 1500000,
      totalRooms: 4,
      availableRooms: 2,
      facilities: const ['Wi-Fi'],
      contactNumber: '081234567890',
    );

    final kosCoblong = Kos(
      id: 'k2',
      ownerId: 'o2',
      name: 'Kos Asri Coblong',
      area: 'Coblong',
      address: 'Jl. Coblong Raya',
      price: 800000,
      totalRooms: 6,
      availableRooms: 1,
      facilities: const ['Kasur'],
      contactNumber: '081999999999',
    );

    final allData = [kosDago, kosCoblong];

    testWidgets('Shows loading indicator initially, then displays list of kos',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(KosCard), findsNWidgets(2));
      expect(find.text('Kos Cemara Dago'), findsOneWidget);
      expect(find.text('Kos Asri Coblong'), findsOneWidget);
    });

    testWidgets(
        'Shows error message and "Coba Lagi" button on network failure (US01-AC2)',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockErrorRepo());
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Gagal memuat data. Periksa koneksi internet Anda'),
        findsOneWidget,
      );
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets(
        'Searching for an area filters the list (US02-AC1)',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'Dago');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kos Cemara Dago'), findsOneWidget);
      expect(find.text('Kos Asri Coblong'), findsNothing);
    });

    testWidgets(
        'Shows EmptyState "Kos tidak ditemukan" when search has no match (US02-AC2)',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'AreaTidakAda999');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Kos tidak ditemukan'), findsOneWidget);

      await tester.tap(find.text('Hapus Filter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(KosCard), findsNWidgets(2));
    });

    testWidgets('Tapping filter button opens filter sheet and applies price filter',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Filter Harga Sewa'), findsOneWidget);

      await tester.tap(find.text('< Rp1.000.000'));
      await tester.pump();

      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(find.text('Kos Asri Coblong'), findsOneWidget);
      expect(find.text('Kos Cemara Dago'), findsNothing);
    });

    testWidgets('Tapping a kos card navigates to KosDetailScreen',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Kos Cemara Dago'));
      await tester.pumpAndSettle();

      expect(find.byType(KosDetailScreen), findsOneWidget);
      expect(find.text('Alamat Lengkap'), findsOneWidget);
      expect(find.text('Jl. Dago Indah No. 1'), findsOneWidget);
    });

    testWidgets('Tapping info icon in AppBar navigates to AboutScreen',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('2415051085'), findsOneWidget);
    });

    testWidgets('Tapping account icon navigates to AuthScreen when unauthenticated',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockUnauthRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Akun Pemilik Kos'), findsOneWidget);
    });

    testWidgets('Tapping account icon navigates to OwnerDashboardScreen when authenticated',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo(allData));
      final authProvider = AuthProvider(repository: MockAuthRepoWithUser());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<KosProvider>.value(value: provider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(OwnerDashboardScreen), findsOneWidget);
      expect(find.text('Dashboard Pemilik'), findsOneWidget);
      expect(find.text('logged@test.com'), findsOneWidget);
    });
  });
}
