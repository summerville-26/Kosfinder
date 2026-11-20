import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos.dart';
import '../providers/kos_provider.dart';
import '../repositories/kos_repository.dart';
import '../widgets/kos_card.dart';

/// Layar beranda publik untuk menampilkan daftar tempat kos.
class HomeScreen extends StatelessWidget {
  final KosRepository? repository;
  final ValueChanged<Kos>? onKosSelected;

  const HomeScreen({
    super.key,
    this.repository,
    this.onKosSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Membungkus dengan ChangeNotifierProvider mandiri jika belum tersedia di tree
    try {
      Provider.of<KosProvider>(context, listen: false);
      return _HomeScreenView(onKosSelected: onKosSelected);
    } catch (_) {
      return ChangeNotifierProvider<KosProvider>(
        create: (_) => KosProvider(repository: repository)..fetchKos(),
        child: _HomeScreenView(onKosSelected: onKosSelected),
      );
    }
  }
}

class _HomeScreenView extends StatefulWidget {
  final ValueChanged<Kos>? onKosSelected;

  const _HomeScreenView({this.onKosSelected});

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<KosProvider>();
      if (provider.status == KosStateStatus.initial) {
        provider.fetchKos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.home_work_rounded),
            SizedBox(width: 8),
            Text(
              'KosFinder',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ??
                          'Gagal memuat data. Periksa koneksi internet Anda',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchKos(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final list = provider.kosList;

          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada data kos yang tersedia saat ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchKos(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final kos = list[index];
                return KosCard(
                  kos: kos,
                  onTap: () {
                    widget.onKosSelected?.call(kos);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
