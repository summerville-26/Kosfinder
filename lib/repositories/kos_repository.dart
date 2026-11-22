import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos.dart';

/// Repository untuk mengelola akses data kos ke tabel `public.kos` Supabase.
class KosRepository {
  final SupabaseClient? _client;

  KosRepository([this._client]);

  /// Mengembalikan instance [SupabaseClient] aktif atau melemparkan exception jika belum siap.
  SupabaseClient get client {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase belum diinisialisasi.');
    }
  }

  /// Mengambil semua data kos publik dari tabel `kos` dengan opsi pencarian teks dan filter harga.
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      var request = client.from('kos').select();

      if (query != null && query.trim().isNotEmpty) {
        final clean = query.trim();
        request = request.or('name.ilike.%$clean%,area.ilike.%$clean%');
      }

      if (minPrice != null && minPrice > 0) {
        request = request.gte('price', minPrice);
      }

      if (maxPrice != null && maxPrice > 0) {
        request = request.lte('price', maxPrice);
      }

      final response = await request.order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((item) => Kos.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat data kos: $e');
    }
  }

  /// Mengambil daftar kos milik pemilik tertentu berdasarkan [ownerId].
  Future<List<Kos>> getKosByOwner(String ownerId) async {
    try {
      final response = await client
          .from('kos')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((item) => Kos.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat data kos pemilik: $e');
    }
  }

  /// Menambahkan data kos baru ke tabel `kos` (US05-AC1).
  ///
  /// [data] berisi field kos tanpa `id` (di-generate oleh Supabase).
  /// Melempar [PostgrestException] jika RLS menolak operasi.
  Future<Kos> createKos(Map<String, dynamic> data) async {
    try {
      final response =
          await client.from('kos').insert(data).select().single();
      return Kos.fromJson(response);
    } on PostgrestException catch (e) {
      if (_isRlsViolation(e)) {
        throw Exception(
            'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
      }
      rethrow;
    } catch (e) {
      throw Exception('Gagal menambahkan data kos: $e');
    }
  }

  /// Memperbarui data kos berdasarkan [id] (US06-AC1).
  ///
  /// [data] berisi field yang ingin diubah.
  /// Melempar pesan RLS jika pemilik tidak sesuai (US06-AC2).
  Future<Kos> updateKos(String id, Map<String, dynamic> data) async {
    try {
      final response = await client
          .from('kos')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return Kos.fromJson(response);
    } on PostgrestException catch (e) {
      if (_isRlsViolation(e)) {
        throw Exception(
            'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
      }
      rethrow;
    } catch (e) {
      throw Exception('Gagal memperbarui data kos: $e');
    }
  }

  /// Menghapus data kos berdasarkan [id] secara permanen / hard delete (US07-AC1).
  ///
  /// Melempar pesan error jaringan jika koneksi gagal (US07-AC2).
  Future<void> deleteKos(String id) async {
    try {
      await client.from('kos').delete().eq('id', id);
    } on PostgrestException catch (e) {
      if (_isRlsViolation(e)) {
        throw Exception(
            'Akses Ditolak: Anda tidak memiliki izin untuk mengubah data ini');
      }
      rethrow;
    } catch (e) {
      throw Exception(
          'Gagal menghapus data kos. Silakan coba beberapa saat lagi');
    }
  }

  /// Memeriksa apakah [PostgrestException] merupakan pelanggaran RLS.
  bool _isRlsViolation(PostgrestException e) {
    // Kode 42501 = insufficient_privilege (RLS policy violation)
    // Kode 42501 atau message berisi 'policy' / 'permission'
    final code = e.code;
    final msg = (e.message).toLowerCase();
    return code == '42501' ||
        msg.contains('policy') ||
        msg.contains('permission') ||
        msg.contains('row-level security');
  }
}
