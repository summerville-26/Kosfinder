import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockSuccessKosRepository extends KosRepository {
  final List<Kos> mockData;

  MockSuccessKosRepository(this.mockData);

  @override
  Future<List<Kos>> getAllKos() async {
    return mockData;
  }
}

class MockErrorKosRepository extends KosRepository {
  @override
  Future<List<Kos>> getAllKos() async {
    throw Exception('Connection failed');
  }
}

void main() {
  group('KosProvider Tests', () {
    final sampleKos = Kos(
      id: 'k1',
      ownerId: 'o1',
      name: 'Kos Sejahtera',
      area: 'Coblong',
      address: 'Jl. Tubagus Ismail',
      price: 1200000,
      totalRooms: 5,
      availableRooms: 2,
      facilities: const ['Wi-Fi'],
      contactNumber: '0811111111',
    );

    test('Initial state is correct', () {
      final provider = KosProvider(repository: MockSuccessKosRepository([]));

      expect(provider.status, KosStateStatus.initial);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('fetchKos() succeeds and updates kosList', () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository([sampleKos]));

      expect(provider.status, KosStateStatus.initial);
      final future = provider.fetchKos();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isSuccess, isTrue);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Sejahtera');
      expect(provider.errorMessage, isNull);
    });

    test('fetchKos() handles error gracefully with error message', () async {
      final provider =
          KosProvider(repository: MockErrorKosRepository());

      await provider.fetchKos();

      expect(provider.isError, isTrue);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage,
          'Gagal memuat data. Periksa koneksi internet Anda');
    });
  });
}
