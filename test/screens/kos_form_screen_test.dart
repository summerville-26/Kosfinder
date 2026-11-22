import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockFormAuthRepository extends AuthRepository {
  final User? user;
  MockFormAuthRepository([this.user]);

  @override
  User? get currentUser => user;
}

class MockFormKosRepository extends KosRepository {
  Map<String, dynamic>? lastCreatedData;
  Map<String, dynamic>? lastUpdatedData;
  String? lastUpdatedId;
  bool shouldFail = false;
  bool shouldFailUpdate = false;
  bool isRlsError = false;

  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async =>
      [];

  @override
  Future<List<Kos>> getKosByOwner(String ownerId) async => [];

  @override
  Future<Kos> createKos(Map<String, dynamic> data) async {
    if (shouldFail) {
      throw Exception('Gagal menyimpan kos');
    }
    lastCreatedData = data;
    return Kos(
      id: 'generated-kos-id',
      ownerId: data['owner_id'] as String,
      name: data['name'] as String,
      area: data['area'] as String,
      address: data['address'] as String,
      price: data['price'] as int,
      totalRooms: data['total_rooms'] as int,
      availableRooms: data['available_rooms'] as int,
      facilities: List<String>.from(data['facilities'] as Iterable),
      contactNumber: data['contact_number'] as String,
    );
  }

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async {
    if (isRlsError) {
      throw Exception(
          'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
    }
    if (shouldFailUpdate) {
      throw Exception('Gagal memperbarui data kos');
    }
    lastUpdatedId = id;
    lastUpdatedData = data;
    return Kos(
      id: id,
      ownerId: data['owner_id'] as String? ?? 'owner-123',
      name: data['name'] as String? ?? '',
      area: data['area'] as String? ?? '',
      address: data['address'] as String? ?? '',
      price: (data['price'] as int?) ?? 0,
      totalRooms: (data['total_rooms'] as int?) ?? 0,
      availableRooms: (data['available_rooms'] as int?) ?? 0,
      facilities: List<String>.from(data['facilities'] as Iterable? ?? []),
      contactNumber: data['contact_number'] as String? ?? '',
    );
  }

  @override
  Future<void> deleteKos(String id) async => throw UnimplementedError();
}

void main() {
  group('KosFormScreen Widget Tests', () {
    const testUser = User(
      id: 'owner-123',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-11-20T00:00:00Z',
      email: 'owner@test.com',
    );

    final existingKos = Kos(
      id: 'kos-edit-1',
      ownerId: 'owner-123',
      name: 'Kos Asli Sebelum Diubah',
      area: 'Dago Atas',
      address: 'Jl. Dago Atas No. 99',
      price: 1500000,
      totalRooms: 10,
      availableRooms: 5,
      facilities: const ['Wi-Fi', 'AC'],
      contactNumber: '081234567890',
    );

    Widget createTestableWidget({
      required AuthProvider authProvider,
      required KosProvider kosProvider,
      Kos? initialKos,
    }) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
          ],
          child: KosFormScreen(initialKos: initialKos),
        ),
      );
    }

    testWidgets('Renders all input fields and Simpan button',
        (WidgetTester tester) async {
      final authRepo = MockFormAuthRepository(testUser);
      final kosRepo = MockFormKosRepository();

      await tester.pumpWidget(
        createTestableWidget(
          authProvider: AuthProvider(repository: authRepo),
          kosProvider: KosProvider(repository: kosRepo),
        ),
      );

      expect(find.text('Tambah Kos Baru'), findsOneWidget);
      expect(find.text('Nama Kos *'), findsOneWidget);
      expect(find.text('Area / Kampus Terdekat *'), findsOneWidget);
      expect(find.text('Alamat Lengkap *'), findsOneWidget);
      expect(find.text('Harga Sewa per Bulan (Rp) *'), findsOneWidget);
      expect(find.text('Total Kamar *'), findsOneWidget);
      expect(find.text('Kamar Tersedia *'), findsOneWidget);
      expect(find.text('Nomor Kontak Pemilik (WhatsApp/HP) *'), findsOneWidget);
      expect(find.text('Fasilitas Tersedia'), findsOneWidget);
      expect(find.text('Simpan Kos'), findsOneWidget);
    });

    testWidgets('Shows validation errors when submitting empty form (US05-AC2)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authRepo = MockFormAuthRepository(testUser);
      final kosRepo = MockFormKosRepository();

      await tester.pumpWidget(
        createTestableWidget(
          authProvider: AuthProvider(repository: authRepo),
          kosProvider: KosProvider(repository: kosRepo),
        ),
      );

      // Scroll and tap Simpan directly without filling any field
      await tester.ensureVisible(find.text('Simpan Kos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Kos'));
      await tester.pumpAndSettle();

      expect(find.text('Nama kos wajib diisi'), findsOneWidget);
      expect(find.text('Area wajib diisi'), findsOneWidget);
      expect(find.text('Alamat lengkap wajib diisi'), findsOneWidget);
      expect(find.text('Harga sewa wajib diisi'), findsOneWidget);
      expect(find.text('Nomor kontak wajib diisi'), findsOneWidget);
      expect(kosRepo.lastCreatedData, isNull);
    });

    testWidgets(
        'Shows validation error when available rooms > total rooms (US05-AC2)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authRepo = MockFormAuthRepository(testUser);
      final kosRepo = MockFormKosRepository();

      await tester.pumpWidget(
        createTestableWidget(
          authProvider: AuthProvider(repository: authRepo),
          kosProvider: KosProvider(repository: kosRepo),
        ),
      );

      // Fill in fields with available rooms > total rooms
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Kos *'), 'Kos Permata');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Area / Kampus Terdekat *'), 'Dago');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Alamat Lengkap *'), 'Jl. Dago 10');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Harga Sewa per Bulan (Rp) *'), '1000000');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Total Kamar *'), '5');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kamar Tersedia *'), '8'); // 8 > 5
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Kontak Pemilik (WhatsApp/HP) *'),
          '08123456789');

      await tester.ensureVisible(find.text('Simpan Kos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Kos'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak boleh > total'), findsOneWidget);
      expect(kosRepo.lastCreatedData, isNull);
    });

    testWidgets('Submitting valid data calls createKos and pops screen (US05-AC1)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authRepo = MockFormAuthRepository(testUser);
      final kosRepo = MockFormKosRepository();

      await tester.pumpWidget(
        createTestableWidget(
          authProvider: AuthProvider(repository: authRepo),
          kosProvider: KosProvider(repository: kosRepo),
        ),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Kos *'), 'Kos Sejahtera Indah');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Area / Kampus Terdekat *'), 'Coblong');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Alamat Lengkap *'), 'Jl. Dipati Ukur No. 20');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Harga Sewa per Bulan (Rp) *'), '1200000');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Total Kamar *'), '10');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kamar Tersedia *'), '4');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Kontak Pemilik (WhatsApp/HP) *'),
          '081234567890');

      // Select Wi-Fi facility chip
      await tester.ensureVisible(find.widgetWithText(FilterChip, 'Wi-Fi'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Wi-Fi'));
      await tester.pump();

      await tester.ensureVisible(find.text('Simpan Kos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Kos'));
      await tester.pumpAndSettle();

      expect(kosRepo.lastCreatedData, isNotNull);
      expect(kosRepo.lastCreatedData!['name'], 'Kos Sejahtera Indah');
      expect(kosRepo.lastCreatedData!['owner_id'], 'owner-123');
      expect(kosRepo.lastCreatedData!['area'], 'Coblong');
      expect(kosRepo.lastCreatedData!['price'], 1200000);
      expect(kosRepo.lastCreatedData!['total_rooms'], 10);
      expect(kosRepo.lastCreatedData!['available_rooms'], 4);
      expect(kosRepo.lastCreatedData!['facilities'], contains('Wi-Fi'));
      expect(kosRepo.lastCreatedData!['contact_number'], '081234567890');
    });

    // === T11: Mode Edit Tests (US06) ===

    testWidgets('Edit mode renders initial values and updates successfully (US06-AC1)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authRepo = MockFormAuthRepository(testUser);
      final kosRepo = MockFormKosRepository();

      await tester.pumpWidget(
        createTestableWidget(
          authProvider: AuthProvider(repository: authRepo),
          kosProvider: KosProvider(repository: kosRepo),
          initialKos: existingKos,
        ),
      );

      // Verify edit mode title and button
      expect(find.text('Ubah Data Kos'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // Verify initial values are populated
      expect(find.text('Kos Asli Sebelum Diubah'), findsOneWidget);
      expect(find.text('Dago Atas'), findsOneWidget);
      expect(find.text('1500000'), findsOneWidget);

      // Modify price and available rooms
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Harga Sewa per Bulan (Rp) *'), '1800000');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kamar Tersedia *'), '2');

      // Submit changes
      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(kosRepo.lastUpdatedId, 'kos-edit-1');
      expect(kosRepo.lastUpdatedData, isNotNull);
      expect(kosRepo.lastUpdatedData!['price'], 1800000);
      expect(kosRepo.lastUpdatedData!['available_rooms'], 2);
    });

    testWidgets(
        'Edit mode displays RLS violation error message when forbidden (US06-AC2)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authRepo = MockFormAuthRepository(testUser);
      final kosRepo = MockFormKosRepository()..isRlsError = true;

      await tester.pumpWidget(
        createTestableWidget(
          authProvider: AuthProvider(repository: authRepo),
          kosProvider: KosProvider(repository: kosRepo),
          initialKos: existingKos,
        ),
      );

      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini'),
        findsOneWidget,
      );
    });
  });
}
