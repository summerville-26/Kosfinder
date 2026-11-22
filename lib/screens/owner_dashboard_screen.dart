import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/kos_repository.dart';
import 'kos_form_screen.dart';

/// Layar beranda dashboard bagi pemilik kos yang telah masuk/login.
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

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari Akun?'),
          content: const Text(
            'Anda perlu masuk kembali untuk mengelola atau menambah kos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pemilik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadOwnerKos();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Profil Pemilik
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _navigateToAddKos,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Kos'),
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

  Widget _buildKosSection(KosProvider kosProvider) {
    if (kosProvider.isLoading && kosProvider.ownerKosList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
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
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadOwnerKos,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
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
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Kos Terdaftar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tekan "Tambah Kos" untuk mulai mempublikasikan kos milik Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
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
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final kos = kosProvider.ownerKosList[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        kos.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kos.isFull
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kos.isFull
                            ? 'Penuh'
                            : 'Sisa ${kos.availableRooms} kamar',
                        style: TextStyle(
                          fontSize: 12,
                          color: kos.isFull
                              ? Colors.red.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  kos.area,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${currencyFormatter.format(kos.price)} / bulan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
