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

  /// Daftar kos milik pemilik yang sedang login.
  List<Kos> _ownerKosList = [];

  KosStateStatus get status => _status;
  List<Kos> get kosList => _kosList;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;

  List<Kos> get ownerKosList => _ownerKosList;

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

  /// Mengambil daftar kos milik pemilik tertentu berdasarkan [ownerId].
  Future<void> fetchOwnerKos(String ownerId) async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _ownerKosList = await _repository.getKosByOwner(ownerId);
      _status = KosStateStatus.success;
    } catch (_) {
      _status = KosStateStatus.error;
      _errorMessage = 'Gagal memuat data kos Anda';
    } finally {
      notifyListeners();
    }
  }

  /// Menambahkan kos baru ke Supabase (US05-AC1).
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  /// Menyimpan pesan error yang sesuai termasuk pelanggaran RLS.
  Future<bool> createKos(Map<String, dynamic> data) async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newKos = await _repository.createKos(data);
      _ownerKosList = [newKos, ..._ownerKosList];
      _status = KosStateStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = KosStateStatus.error;
      _errorMessage = _extractMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Memperbarui data kos berdasarkan [id] (US06-AC1).
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  /// Menangani error RLS dengan pesan khusus (US06-AC2).
  Future<bool> updateKos(String id, Map<String, dynamic> data) async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateKos(id, data);
      // Perbarui item di ownerKosList
      _ownerKosList = _ownerKosList.map((k) {
        return k.id == id ? updated : k;
      }).toList();
      // Perbarui juga di kosList publik jika ada
      _kosList = _kosList.map((k) {
        return k.id == id ? updated : k;
      }).toList();
      _status = KosStateStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = KosStateStatus.error;
      _errorMessage = _extractMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Menghapus kos berdasarkan [id] secara permanen (US07-AC1).
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  /// Menangani error koneksi dengan pesan khusus (US07-AC2).
  Future<bool> deleteKos(String id) async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteKos(id);
      _ownerKosList = _ownerKosList.where((k) => k.id != id).toList();
      _kosList = _kosList.where((k) => k.id != id).toList();
      _status = KosStateStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = KosStateStatus.error;
      _errorMessage = _extractMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Mengekstrak pesan error dari [Exception].
  String _extractMessage(Object e) {
    if (e is Exception) {
      final msg = e.toString();
      // Exception: message → hapus prefix "Exception: "
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }
    return e.toString();
  }
}
