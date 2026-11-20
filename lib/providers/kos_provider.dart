import 'package:flutter/foundation.dart';
import '../models/kos.dart';
import '../repositories/kos_repository.dart';

enum KosStateStatus { initial, loading, success, error }

/// Provider untuk mengelola state daftar kos, kueri pencarian nama/area, dan filter harga.
class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  KosStateStatus _status = KosStateStatus.initial;
  List<Kos> _kosList = [];
  String? _errorMessage;

  String _searchQuery = '';
  int? _minPrice;
  int? _maxPrice;

  KosStateStatus get status => _status;
  List<Kos> get kosList => _kosList;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;

  bool get isLoading => _status == KosStateStatus.loading;
  bool get isError => _status == KosStateStatus.error;
  bool get isSuccess => _status == KosStateStatus.success;

  /// Memeriksa apakah ada filter aktif (kata kunci pencarian atau batas harga).
  bool get hasActiveFilter =>
      _searchQuery.isNotEmpty || _minPrice != null || _maxPrice != null;

  /// Mengambil semua kos publik dari repository dengan kueri dan filter yang aktif.
  Future<void> fetchKos() async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _kosList = await _repository.getAllKos(
        query: _searchQuery,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      _status = KosStateStatus.success;
    } catch (_) {
      _status = KosStateStatus.error;
      _errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda';
    } finally {
      notifyListeners();
    }
  }

  /// Memperbarui kata kunci pencarian (nama atau area) dan memicu pembaruan data.
  Future<void> setSearchQuery(String query) async {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    await fetchKos();
  }

  /// Menerapkan filter rentang harga sewa (minPrice dan/atau maxPrice).
  Future<void> setPriceFilter({int? minPrice, int? maxPrice}) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    await fetchKos();
  }

  /// Menghapus semua kata kunci pencarian dan filter harga.
  Future<void> clearFilters() async {
    _searchQuery = '';
    _minPrice = null;
    _maxPrice = null;
    await fetchKos();
  }
}
