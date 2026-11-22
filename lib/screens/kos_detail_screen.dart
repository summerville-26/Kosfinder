import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/kos.dart';
import '../widgets/kos_card.dart';

/// Layar rincian informasi detail tempat kos dengan desain Modern Green & White.
class KosDetailScreen extends StatelessWidget {
  final Kos kos;

  const KosDetailScreen({super.key, required this.kos});

  IconData _getFacilityIcon(String facility) {
    final lower = facility.toLowerCase();
    if (lower.contains('wi-fi') || lower.contains('wifi') || lower.contains('internet')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('ac') || lower.contains('pendingin')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('kamar mandi') || lower.contains('km dalam')) {
      return Icons.bathtub_outlined;
    }
    if (lower.contains('kasur') || lower.contains('bed') || lower.contains('springbed')) {
      return Icons.bed_rounded;
    }
    if (lower.contains('lemari')) {
      return Icons.door_sliding_outlined;
    }
    if (lower.contains('meja')) {
      return Icons.desk_rounded;
    }
    if (lower.contains('parkir')) {
      return Icons.two_wheeler_rounded;
    }
    if (lower.contains('dapur')) {
      return Icons.soup_kitchen_outlined;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          kos.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Visual Placeholder Modern
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF065F46),
                    Color(0xFF047857),
                    Color(0xFF059669),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Latar belakang dekoratif ilustrasi
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Ilustrasi Kos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.home_work_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'KosFinder Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Kos, Area, dan Badge Status Kamar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kos.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    kos.area,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      KosAvailabilityBadge(
                        availableRooms: kos.availableRooms,
                        isLarge: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tag Harga Sewa
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currencyFormatter.format(kos.price),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          ' / bulan',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card Informasi Alamat Lengkap
                  _buildSectionCard(
                    title: 'Alamat Lengkap',
                    icon: Icons.map_outlined,
                    child: Text(
                      kos.address.isNotEmpty
                          ? kos.address
                          : 'Alamat tidak tersedia',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Card Kapasitas Kamar
                  _buildSectionCard(
                    title: 'Kapasitas Kamar',
                    icon: Icons.meeting_room_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Kamar: ${kos.totalRooms} | Kamar Tersedia: ${kos.availableRooms}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: kos.totalRooms > 0
                                ? (kos.totalRooms - kos.availableRooms) / kos.totalRooms
                                : 0,
                            minHeight: 8,
                            backgroundColor: AppColors.primarySurface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kos.isFull ? AppColors.error : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Card Fasilitas
                  _buildSectionCard(
                    title: 'Fasilitas',
                    icon: Icons.check_circle_outline_rounded,
                    child: kos.facilities.isEmpty
                        ? const Text(
                            'Belum ada fasilitas dicantumkan',
                            style: TextStyle(color: AppColors.textMuted),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kos.facilities.map((facility) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getFacilityIcon(facility),
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      facility,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Card Kontak Pemilik
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.contact_phone_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kontak Pemilik',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                kos.contactNumber.isNotEmpty
                                    ? kos.contactNumber
                                    : 'Nomor kontak tidak tersedia',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
