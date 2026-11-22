import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

// --- Mock Repositories ---

class MockSuccessKosRepository extends KosRepository {
  final List<Kos> mockData;
  Kos? lastCreated;
  Kos? lastUpdated;
  String? lastDeletedId;

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

  @override
  Future<List<Kos>> getKosByOwner(String ownerId) async {
    return mockData.where((k) => k.ownerId == ownerId).toList();
  }

  @override
  Future<Kos> createKos(Map<String, dynamic> data) async {
    final kos = Kos(
      id: 'new-id',
      ownerId: data['owner_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      area: data['area'] as String? ?? '',
      address: data['address'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      totalRooms: (data['total_rooms'] as num?)?.toInt() ?? 0,
      availableRooms: (data['available_rooms'] as num?)?.toInt() ?? 0,
      facilities: data['facilities'] != null
          ? List<String>.from(data['facilities'] as Iterable)
          : <String>[],
      contactNumber: data['contact_number'] as String? ?? '',
    );
    lastCreated = kos;
    return kos;
  }

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async {
    final existing = mockData.firstWhere((k) => k.id == id);
    final updated = existing.copyWith(
      name: data['name'] as String? ?? existing.name,
      price: (data['price'] as num?)?.toInt() ?? existing.price,
    );
    lastUpdated = updated;
    return updated;
  }

  @override
  Future<void> deleteKos(String id) async {
    lastDeletedId = id;
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

  @override
  Future<List<Kos>> getKosByOwner(String ownerId) async {
    throw Exception('Connection failed');
  }

  @override
  Future<Kos> createKos(Map<String, dynamic> data) async {
    throw Exception('Gagal menambahkan data kos: network error');
  }

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async {
    throw Exception('Gagal memperbarui data kos: network error');
  }

  @override
  Future<void> deleteKos(String id) async {
    throw Exception(
        'Gagal menghapus data kos. Silakan coba beberapa saat lagi');
  }
}

class MockRlsErrorKosRepository extends KosRepository {
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
    throw Exception(
        'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
  }

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async {
    throw Exception(
        'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
  }

  @override
  Future<void> deleteKos(String id) async {
    throw Exception(
        'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
  }
}

// --- Tests ---

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

    // === Existing Tests ===

    test('Initial state is correct', () {
      final provider = KosProvider(repository: MockSuccessKosRepository([]));

      expect(provider.status, KosStateStatus.initial);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage, isNull);
      expect(provider.searchQuery, isEmpty);
      expect(provider.minPrice, isNull);
      expect(provider.maxPrice, isNull);
      expect(provider.hasActiveFilter, isFalse);
      expect(provider.ownerKosList, isEmpty);
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

    test('setPriceFilter filters within min and max price (US02-AC1)',
        () async {
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

    // === T09: CRUD Tests ===

    test('fetchOwnerKos() loads kos owned by specific owner', () async {
      final provider =
          KosProvider(repository: MockSuccessKosRepository(allData));

      await provider.fetchOwnerKos('o1');

      expect(provider.isSuccess, isTrue);
      expect(provider.ownerKosList.length, 1);
      expect(provider.ownerKosList.first.ownerId, 'o1');
    });

    test('fetchOwnerKos() handles error gracefully', () async {
      final provider = KosProvider(repository: MockErrorKosRepository());

      await provider.fetchOwnerKos('o1');

      expect(provider.isError, isTrue);
      expect(provider.errorMessage, 'Gagal memuat data kos Anda');
    });

    test('createKos() succeeds and adds to ownerKosList (US05-AC1)', () async {
      final repo = MockSuccessKosRepository(allData);
      final provider = KosProvider(repository: repo);

      final data = {
        'owner_id': 'o1',
        'name': 'Kos Baru',
        'area': 'Renon',
        'address': 'Jl. Renon No. 5',
        'price': 1200000,
        'total_rooms': 10,
        'available_rooms': 10,
        'facilities': ['Wi-Fi', 'AC'],
        'contact_number': '0899999999',
      };

      final result = await provider.createKos(data);

      expect(result, isTrue);
      expect(provider.isSuccess, isTrue);
      expect(provider.ownerKosList.length, 1);
      expect(provider.ownerKosList.first.name, 'Kos Baru');
      expect(provider.errorMessage, isNull);
      expect(repo.lastCreated, isNotNull);
      expect(repo.lastCreated!.name, 'Kos Baru');
    });

    test('createKos() handles network error', () async {
      final provider = KosProvider(repository: MockErrorKosRepository());

      final result = await provider.createKos({'name': 'Test'});

      expect(result, isFalse);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage, isNotNull);
    });

    test('createKos() handles RLS violation error (US06-AC2)', () async {
      final provider = KosProvider(repository: MockRlsErrorKosRepository());

      final result = await provider.createKos({'name': 'Test'});

      expect(result, isFalse);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage,
          'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
    });

    test('updateKos() succeeds and updates ownerKosList and kosList (US06-AC1)',
        () async {
      final repo = MockSuccessKosRepository(allData);
      final provider = KosProvider(repository: repo);

      // Load data first
      await provider.fetchKos();
      await provider.fetchOwnerKos('o1');

      final result = await provider.updateKos('k1', {'price': 1500000});

      expect(result, isTrue);
      expect(provider.isSuccess, isTrue);
      expect(provider.errorMessage, isNull);
      // kosList should have the updated item
      final updatedInList = provider.kosList.firstWhere((k) => k.id == 'k1');
      expect(updatedInList.price, 1500000);
      // ownerKosList should also be updated
      final updatedInOwner =
          provider.ownerKosList.firstWhere((k) => k.id == 'k1');
      expect(updatedInOwner.price, 1500000);
    });

    test('updateKos() handles RLS violation error (US06-AC2)', () async {
      final provider = KosProvider(repository: MockRlsErrorKosRepository());

      final result = await provider.updateKos('k1', {'price': 999});

      expect(result, isFalse);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage,
          'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
    });

    test('updateKos() handles network error', () async {
      final provider = KosProvider(repository: MockErrorKosRepository());

      final result = await provider.updateKos('k1', {'price': 999});

      expect(result, isFalse);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage, isNotNull);
    });

    test('deleteKos() succeeds and removes from both lists (US07-AC1)',
        () async {
      final repo = MockSuccessKosRepository(allData);
      final provider = KosProvider(repository: repo);

      // Load data first
      await provider.fetchKos();
      await provider.fetchOwnerKos('o1');
      expect(provider.kosList.length, 2);

      final result = await provider.deleteKos('k1');

      expect(result, isTrue);
      expect(provider.isSuccess, isTrue);
      expect(provider.errorMessage, isNull);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.any((k) => k.id == 'k1'), isFalse);
      expect(provider.ownerKosList.any((k) => k.id == 'k1'), isFalse);
      expect(repo.lastDeletedId, 'k1');
    });

    test(
        'deleteKos() handles network error with specific message (US07-AC2)',
        () async {
      final provider = KosProvider(repository: MockErrorKosRepository());

      final result = await provider.deleteKos('k1');

      expect(result, isFalse);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage,
          'Gagal menghapus data kos. Silakan coba beberapa saat lagi');
    });

    test('deleteKos() handles RLS violation error', () async {
      final provider = KosProvider(repository: MockRlsErrorKosRepository());

      final result = await provider.deleteKos('k1');

      expect(result, isFalse);
      expect(provider.isError, isTrue);
      expect(provider.errorMessage,
          'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
    });
  });
}
