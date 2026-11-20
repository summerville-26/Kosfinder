import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockSuccessKosRepository extends KosRepository {
  final List<Kos> mockData;

  MockSuccessKosRepository(this.mockData);

  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async {
    return mockData.where((kos) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = kos.name.toLowerCase().contains(q);
        final matchArea = kos.area.toLowerCase().contains(q);
        if (!matchName && !matchArea) return false;
      }
      if (minPrice != null && minPrice > 0 && kos.price < minPrice) {
        return false;
      }
      if (maxPrice != null && maxPrice > 0 && kos.price > maxPrice) {
        return false;
      }
      return true;
    }).toList();
  }
}

class MockErrorKosRepository extends KosRepository {
  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async {
    throw Exception('Connection failed');
  }
}

void main() {
  group('KosProvider Tests', () {
    final kos1 = Kos(
      id: 'k1',
      ownerId: 'o1',
      name: 'Kos Sejahtera Dago',
      area: 'Dago',
      address: 'Jl. Dago No. 1',
      price: 1000000,
      totalRooms: 5,
      availableRooms: 2,
      facilities: const ['Wi-Fi'],
      contactNumber: '0811111111',
    );

    final kos2 = Kos(
      id: 'k2',
      ownerId: 'o2',
      name: 'Kos Coblong Indah',
      area: 'Coblong',
      address: 'Jl. Tubagus Ismail',
      price: 2000000,
      totalRooms: 8,
      availableRooms: 0,
      facilities: const ['AC'],
      contactNumber: '0822222222',
    );

    final allData = [kos1, kos2];

    test('Initial state is correct', () {
      final provider = KosProvider(repository: MockSuccessKosRepository([]));

      expect(provider.status, KosStateStatus.initial);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage, isNull);
      expect(provider.searchQuery, isEmpty);
      expect(provider.minPrice, isNull);
      expect(provider.maxPrice, isNull);
      expect(provider.hasActiveFilter, isFalse);
    });

    test('fetchKos() succeeds and updates kosList', () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository(allData));

      await provider.fetchKos();

      expect(provider.isSuccess, isTrue);
      expect(provider.kosList.length, 2);
      expect(provider.errorMessage, isNull);
    });

    test('fetchKos() handles error gracefully with error message', () async {
      final provider = KosProvider(repository: MockErrorKosRepository());

      await provider.fetchKos();

      expect(provider.isError, isTrue);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage,
          'Gagal memuat data. Periksa koneksi internet Anda');
    });

    test('setSearchQuery filters by name or area (US02-AC1)', () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository(allData));

      // Filter by name
      await provider.setSearchQuery('Sejahtera');
      expect(provider.searchQuery, 'Sejahtera');
      expect(provider.hasActiveFilter, isTrue);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Sejahtera Dago');

      // Filter by area
      await provider.setSearchQuery('Coblong');
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Coblong Indah');
    });

    test('setPriceFilter filters within min and max price (US02-AC1)', () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository(allData));

      await provider.setPriceFilter(minPrice: 1500000);
      expect(provider.hasActiveFilter, isTrue);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.price, 2000000);

      await provider.setPriceFilter(maxPrice: 1200000);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.price, 1000000);
    });

    test('Filters result in empty list for unmatched criteria (US02-AC2)',
        () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository(allData));

      await provider.setSearchQuery('AreaTidakAda999');
      expect(provider.kosList, isEmpty);
      expect(provider.hasActiveFilter, isTrue);
    });

    test('clearFilters resets all filter values and reloads full data',
        () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository(allData));

      await provider.setSearchQuery('Dago');
      await provider.setPriceFilter(minPrice: 500000, maxPrice: 1500000);
      expect(provider.hasActiveFilter, isTrue);

      await provider.clearFilters();
      expect(provider.searchQuery, isEmpty);
      expect(provider.minPrice, isNull);
      expect(provider.maxPrice, isNull);
      expect(provider.hasActiveFilter, isFalse);
      expect(provider.kosList.length, 2);
    });
  });
}
