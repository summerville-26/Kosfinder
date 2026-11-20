import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/widgets/kos_card.dart';
import 'package:provider/provider.dart';

class MockSuccessRepo extends KosRepository {
  final List<Kos> data;
  MockSuccessRepo(this.data);

  @override
  Future<List<Kos>> getAllKos() async => data;
}

class MockErrorRepo extends KosRepository {
  @override
  Future<List<Kos>> getAllKos() async => throw Exception('Network error');
}

void main() {
  group('HomeScreen Widget Tests', () {
    final sampleKos = Kos(
      id: 'k1',
      ownerId: 'o1',
      name: 'Kos Cemara Indah',
      area: 'Cisitu',
      address: 'Jl. Cisitu Indah',
      price: 1500000,
      totalRooms: 4,
      availableRooms: 2,
      facilities: const ['Wi-Fi'],
      contactNumber: '081234567890',
    );

    testWidgets('Shows loading indicator initially, then displays list of kos',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo([sampleKos]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<KosProvider>.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(KosCard), findsOneWidget);
      expect(find.text('Kos Cemara Indah'), findsOneWidget);
    });

    testWidgets(
        'Shows error message and "Coba Lagi" button on network failure (US01-AC2)',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockErrorRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<KosProvider>.value(
            value: provider,
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

    testWidgets('Shows empty state when kos list is empty',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo([]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<KosProvider>.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Belum ada data kos yang tersedia saat ini.'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping a kos card navigates to KosDetailScreen',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo([sampleKos]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<KosProvider>.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(KosCard));
      await tester.pumpAndSettle();

      expect(find.byType(KosDetailScreen), findsOneWidget);
      expect(find.text('Alamat Lengkap'), findsOneWidget);
      expect(find.text('Jl. Cisitu Indah'), findsOneWidget);
    });

    testWidgets('Tapping info icon in AppBar navigates to AboutScreen',
        (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo([sampleKos]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<KosProvider>.value(
            value: provider,
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
  });
}
