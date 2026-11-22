import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/kos.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/kos_repository.dart';
import '../widgets/kos_card.dart';
import 'kos_form_screen.dart';

/// Layar beranda dashboard bagi pemilik kos yang telah masuk/login (Modern Green & White).
class OwnerDashboardScreen extends StatelessWidget {
  final AuthRepository? repository;
  final KosRepository? kosRepository;

  const OwnerDashboardScreen({
    super.key,
    this.repository,
    this.kosRepository,
  });

  @override
  Widget build(BuildContext context) {
    Widget view = const _OwnerDashboardView();

    try {
      Provider.of<KosProvider>(context, listen: false);
    } catch (_) {
      view = ChangeNotifierProvider<KosProvider>(
        create: (_) => KosProvider(repository: kosRepository),
        child: view,
      );
    }

    try {
      Provider.of<AuthProvider>(context, listen: false);
    } catch (_) {
      view = ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(repository: repository),
        child: view,
      );
    }

    return view;
  }
}

class _OwnerDashboardView extends StatefulWidget {
  const _OwnerDashboardView();

  @override
  State<_OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<_OwnerDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnerKos();
    });
  }

  void _loadOwnerKos() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      context.read<KosProvider>().fetchOwnerKos(userId);
    }
  }

  Future<void> _navigateToAddKos() async {
    final authProvider = context.read<AuthProvider>();
    final kosProvider = context.read<KosProvider>();

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
          ],
          child: const KosFormScreen(),
        ),
      ),
    );

    if (created == true && mounted) {
      _loadOwnerKos();
    }
  }

  Future<void> _navigateToEditKos(Kos kos) async {
    final authProvider = context.read<AuthProvider>();
    final kosProvider = context.read<KosProvider>();

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
          ],
          child: KosFormScreen(initialKos: kos),
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadOwnerKos();
    }
  }

  /// Pembaruan cepat jumlah sisa kamar kos (T13).
  Future<void> _quickUpdateRooms(Kos kos, int newAvailableRooms) async {
    if (newAvailableRooms < 0 || newAvailableRooms > kos.totalRooms) return;

    final kosProvider = context.read<KosProvider>();
    final success = await kosProvider.updateKos(
      kos.id,
      {'available_rooms': newAvailableRooms},
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newAvailableRooms == 0
              ? 'Status kos diubah menjadi "Penuh"'
              : 'Sisa kamar berhasil diperbarui menjadi $newAvailableRooms'),
          duration: const Duration(seconds: 2),
          backgroundColor:
              newAvailableRooms == 0 ? Colors.orange.shade800 : AppColors.primary,
        ),
      );
    } else {
      final errorMsg =
          kosProvider.errorMessage ?? 'Gagal memperbarui sisa kamar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmDeleteKos(BuildContext context, Kos kos) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Hapus Kos?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            'Apakah Anda yakin ingin menghapus data kos "${kos.name}" secara permanen? Data yang dihapus tidak dapat dipulihkan.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final kosProvider = context.read<KosProvider>();
                final success = await kosProvider.deleteKos(kos.id);
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data kos berhasil dihapus'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                } else {
                  final errorMsg = kosProvider.errorMessage ??
                      'Gagal menghapus data kos. Silakan coba beberapa saat lagi';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Keluar dari Akun?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Anda perlu masuk kembali untuk mengelola atau menambah kos.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final kosProvider = context.watch<KosProvider>();
    final email = authProvider.currentUser?.email ?? 'Pemilik Kos';

    // Statistik Kamar
    final totalKosCount = kosProvider.ownerKosList.length;
    final totalAvailableRooms = kosProvider.ownerKosList.fold<int>(
      0,
      (sum, k) => sum + k.availableRooms,
    );
    final totalFullKos = kosProvider.ownerKosList.where((k) => k.isFull).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dashboard Pemilik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Keluar',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          _loadOwnerKos();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Profil Pemilik Modern
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Ringkasan Statistik 3 Metrik (Total Kos, Kamar Tersedia, Kamar Penuh)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Total Kos',
                      value: '$totalKosCount',
                      icon: Icons.apartment_rounded,
                      color: AppColors.primary,
                      bgColor: AppColors.primarySurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Kamar Sisa',
                      value: '$totalAvailableRooms',
                      icon: Icons.meeting_room_outlined,
                      color: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFF0F9FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Kos Penuh',
                      value: '$totalFullKos',
                      icon: Icons.lock_clock_outlined,
                      color: totalFullKos > 0 ? AppColors.error : AppColors.textMuted,
                      bgColor: totalFullKos > 0
                          ? AppColors.error.withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Header Bagian Kos Saya
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kos Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddKos,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Kos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Daftar Kos Saya atau Empty State
              _buildKosSection(kosProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKosSection(KosProvider kosProvider) {
    if (kosProvider.isLoading && kosProvider.ownerKosList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (kosProvider.isError && kosProvider.ownerKosList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                kosProvider.errorMessage ?? 'Gagal memuat data kos Anda',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadOwnerKos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (kosProvider.ownerKosList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Kos Terdaftar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tekan "Tambah Kos" untuk mulai mempublikasikan kos milik Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kosProvider.ownerKosList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final kos = kosProvider.ownerKosList[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: AppTheme.softShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kos.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                kos.area,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  KosAvailabilityBadge(
                    availableRooms: kos.availableRooms,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${currencyFormatter.format(kos.price)} / bulan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              // Panel Pembaruan Cepat Sisa Kamar (T13)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Kamar:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Kurangi sisa kamar',
                      onPressed: kos.availableRooms > 0
                          ? () => _quickUpdateRooms(kos, kos.availableRooms - 1)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${kos.availableRooms} / ${kos.totalRooms}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kos.isFull
                              ? AppColors.error
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Tambah sisa kamar',
                      onPressed: kos.availableRooms < kos.totalRooms
                          ? () => _quickUpdateRooms(kos, kos.availableRooms + 1)
                          : null,
                    ),
                    const Spacer(),
                    if (!kos.isFull)
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.error,
                        ),
                        onPressed: () => _quickUpdateRooms(kos, 0),
                        child: const Text(
                          'Set Penuh',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: kos.totalRooms > 0
                            ? () => _quickUpdateRooms(kos, 1)
                            : null,
                        child: const Text(
                          'Buka 1 Kamar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // Tombol Aksi: Ubah & Hapus (T11)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _navigateToEditKos(kos),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Ubah'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.border),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDeleteKos(context, kos),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
