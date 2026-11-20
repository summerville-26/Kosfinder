import 'package:flutter/foundation.dart';
import '../models/kos.dart';
import '../repositories/kos_repository.dart';

enum KosStateStatus { initial, loading, success, error }

/// Provider untuk mengelola state daftar kos, loading, dan pesan error.
class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  KosStateStatus _status = KosStateStatus.initial;
  List<Kos> _kosList = [];
  String? _errorMessage;

  KosStateStatus get status => _status;
  List<Kos> get kosList => _kosList;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == KosStateStatus.loading;
  bool get isError => _status == KosStateStatus.error;
  bool get isSuccess => _status == KosStateStatus.success;

  /// Mengambil semua kos publik dari repository.
  Future<void> fetchKos() async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _kosList = await _repository.getAllKos();
      _status = KosStateStatus.success;
    } catch (_) {
      _status = KosStateStatus.error;
      _errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda';
    } finally {
      notifyListeners();
    }
  }
}
