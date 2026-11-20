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

  /// Mengambil semua data kos publik dari tabel `kos` terurut dari yang terbaru.
  Future<List<Kos>> getAllKos() async {
    try {
      final response = await client
          .from('kos')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((item) => Kos.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat data kos: $e');
    }
  }
}
