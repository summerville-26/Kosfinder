import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/kos_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/kos_card.dart';
import '../widgets/search_filter_bar.dart';
import 'about_screen.dart';
import 'auth_screen.dart';
import 'kos_detail_screen.dart';
import 'owner_dashboard_screen.dart';

/// Layar beranda publik dengan pencarian nama/area dan filter harga.
class HomeScreen extends StatelessWidget {
  final KosRepository? repository;
  final AuthRepository? authRepository;
  final ValueChanged<Kos>? onKosSelected;

  const HomeScreen({
    super.key,
    this.repository,
    this.authRepository,
    this.onKosSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = _HomeScreenView(onKosSelected: onKosSelected);

    // Membungkus dengan KosProvider jika belum tersedia di tree
    try {
      Provider.of<KosProvider>(context, listen: false);
    } catch (_) {
      child = ChangeNotifierProvider<KosProvider>(
        create: (_) => KosProvider(repository: repository)..fetchKos(),
        child: child,
      );
    }

    // Membungkus dengan AuthProvider jika belum tersedia di tree
    try {
      Provider.of<AuthProvider>(context, listen: false);
    } catch (_) {
      child = ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(repository: authRepository),
        child: child,
      );
    }

    return child;
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

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<KosProvider>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _FilterPriceSheet(
          initialMin: provider.minPrice,
          initialMax: provider.maxPrice,
          onApply: (min, max) {
            provider.setPriceFilter(minPrice: min, maxPrice: max);
          },
          onReset: () {
            provider.setPriceFilter(minPrice: null, maxPrice: null);
          },
        );
      },
    );
  }

  void _handleAccountNavigation(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const OwnerDashboardScreen(),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const AuthScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KosProvider>();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Akun Pemilik',
            onPressed: () => _handleAccountNavigation(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bilah Pencarian & Tombol Filter
          SearchFilterBar(
            initialQuery: provider.searchQuery,
            hasActiveFilter: provider.hasActiveFilter,
            onSearchChanged: (query) => provider.setSearchQuery(query),
            onFilterTap: () => _showFilterSheet(context),
          ),

          // Indikator Filter Aktif
          if (provider.hasActiveFilter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getFilterLabel(provider),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.clearFilters(),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Area Konten Utama
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                  if (provider.hasActiveFilter) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Kos tidak ditemukan',
                      message: 'Coba gunakan kata kunci atau filter lain',
                      actionLabel: 'Hapus Filter',
                      onAction: () => provider.clearFilters(),
                    );
                  }

                  return const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Belum Ada Kos',
                    message: 'Belum ada data kos yang tersedia saat ini.',
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
                          if (widget.onKosSelected != null) {
                            widget.onKosSelected!(kos);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KosDetailScreen(kos: kos),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(KosProvider provider) {
    final parts = <String>[];
    if (provider.searchQuery.isNotEmpty) {
      parts.add('Cari: "${provider.searchQuery}"');
    }
    if (provider.minPrice != null && provider.maxPrice != null) {
      parts.add('Rp${provider.minPrice} - Rp${provider.maxPrice}');
    } else if (provider.minPrice != null) {
      parts.add('>= Rp${provider.minPrice}');
    } else if (provider.maxPrice != null) {
      parts.add('<= Rp${provider.maxPrice}');
    }
    return parts.join(' | ');
  }
}

/// Bottom Sheet untuk memilih rentang filter harga sewa.
class _FilterPriceSheet extends StatefulWidget {
  final int? initialMin;
  final int? initialMax;
  final void Function(int? min, int? max) onApply;
  final VoidCallback onReset;

  const _FilterPriceSheet({
    this.initialMin,
    this.initialMax,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterPriceSheet> createState() => _FilterPriceSheetState();
}

class _FilterPriceSheetState extends State<_FilterPriceSheet> {
  int? _min;
  int? _max;

  @override
  void initState() {
    super.initState();
    _min = widget.initialMin;
    _max = widget.initialMax;
  }

  void _selectPreset(int? min, int? max) {
    setState(() {
      _min = min;
      _max = max;
    });
  }

  bool _isPresetSelected(int? min, int? max) {
    return _min == min && _max == max;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Harga Sewa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua Harga'),
                selected: _min == null && _max == null,
                onSelected: (_) => _selectPreset(null, null),
              ),
              ChoiceChip(
                label: const Text('< Rp1.000.000'),
                selected: _isPresetSelected(null, 1000000),
                onSelected: (_) => _selectPreset(null, 1000000),
              ),
              ChoiceChip(
                label: const Text('Rp1 Juta - Rp2 Juta'),
                selected: _isPresetSelected(1000000, 2000000),
                onSelected: (_) => _selectPreset(1000000, 2000000),
              ),
              ChoiceChip(
                label: const Text('> Rp2.000.000'),
                selected: _isPresetSelected(2000000, null),
                onSelected: (_) => _selectPreset(2000000, null),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_min, _max);
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
