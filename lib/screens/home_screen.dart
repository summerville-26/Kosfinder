import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
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

/// Layar beranda publik dengan desain Modern Green & White (KosFinder).
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'KosFinder',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Akun Pemilik',
            onPressed: () => _handleAccountNavigation(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Temukan Kos Impianmu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pilihan hunian nyaman & strategis',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Bilah Pencarian & Tombol Filter
          SearchFilterBar(
            initialQuery: provider.searchQuery,
            hasActiveFilter: provider.hasActiveFilter,
            onSearchChanged: (query) => provider.setSearchQuery(query),
            onFilterTap: () => _showFilterSheet(context),
          ),

          // Quick Filter Categories Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildQuickFilterChip(
                  label: 'Semua',
                  icon: Icons.grid_view_rounded,
                  isSelected: provider.minPrice == null && provider.maxPrice == null,
                  onTap: () => provider.setPriceFilter(minPrice: null, maxPrice: null),
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: '< 1 Juta',
                  icon: Icons.savings_outlined,
                  isSelected: provider.minPrice == null && provider.maxPrice == 1000000,
                  onTap: () => provider.setPriceFilter(minPrice: null, maxPrice: 1000000),
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: '1 - 2 Juta',
                  icon: Icons.payments_outlined,
                  isSelected: provider.minPrice == 1000000 && provider.maxPrice == 2000000,
                  onTap: () => provider.setPriceFilter(minPrice: 1000000, maxPrice: 2000000),
                ),
                const SizedBox(width: 8),
                _buildQuickFilterChip(
                  label: '> 2 Juta',
                  icon: Icons.diamond_outlined,
                  isSelected: provider.minPrice == 2000000 && provider.maxPrice == null,
                  onTap: () => provider.setPriceFilter(minPrice: 2000000, maxPrice: null),
                ),
              ],
            ),
          ),

          // Indikator Filter Aktif
          if (provider.hasActiveFilter)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getFilterLabel(provider),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.clearFilters(),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Area Konten Utama
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.isError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage ??
                                'Gagal memuat data. Periksa koneksi internet Anda',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchKos(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                  color: AppColors.primary,
                  onRefresh: () => provider.fetchKos(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
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

  Widget _buildQuickFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected ? null : AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
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

/// Bottom Sheet untuk memilih rentang filter harga sewa dengan desain Modern Emerald.
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter Harga Sewa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua Harga'),
                selected: _min == null && _max == null,
                selectedColor: AppColors.primarySurface,
                side: BorderSide(
                  color: _min == null && _max == null
                      ? AppColors.primary
                      : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: _min == null && _max == null
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: _min == null && _max == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (_) => _selectPreset(null, null),
              ),
              ChoiceChip(
                label: const Text('< Rp1.000.000'),
                selected: _isPresetSelected(null, 1000000),
                selectedColor: AppColors.primarySurface,
                side: BorderSide(
                  color: _isPresetSelected(null, 1000000)
                      ? AppColors.primary
                      : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: _isPresetSelected(null, 1000000)
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: _isPresetSelected(null, 1000000)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (_) => _selectPreset(null, 1000000),
              ),
              ChoiceChip(
                label: const Text('Rp1 Juta - Rp2 Juta'),
                selected: _isPresetSelected(1000000, 2000000),
                selectedColor: AppColors.primarySurface,
                side: BorderSide(
                  color: _isPresetSelected(1000000, 2000000)
                      ? AppColors.primary
                      : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: _isPresetSelected(1000000, 2000000)
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: _isPresetSelected(1000000, 2000000)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (_) => _selectPreset(1000000, 2000000),
              ),
              ChoiceChip(
                label: const Text('> Rp2.000.000'),
                selected: _isPresetSelected(2000000, null),
                selectedColor: AppColors.primarySurface,
                side: BorderSide(
                  color: _isPresetSelected(2000000, null)
                      ? AppColors.primary
                      : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: _isPresetSelected(2000000, null)
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: _isPresetSelected(2000000, null)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (_) => _selectPreset(2000000, null),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    widget.onApply(_min, _max);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Terapkan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
