import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/kos.dart';

/// Komponen badge visual ketersediaan kamar kos ("Sisa X kamar" vs "Penuh") (US03).
class KosAvailabilityBadge extends StatelessWidget {
  final int availableRooms;
  final bool isLarge;

  const KosAvailabilityBadge({
    super.key,
    required this.availableRooms,
    this.isLarge = false,
  });

  bool get isFull => availableRooms <= 0;

  @override
  Widget build(BuildContext context) {
    final bgColor = isFull ? AppTheme.redLight : AppTheme.primaryLight;
    final borderColor = isFull ? AppTheme.redBorder : const Color(0xFFA7F3D0);
    final textColor = isFull ? AppTheme.redText : AppTheme.primaryDark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 9,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isLarge ? 8 : 6,
            height: isLarge ? 8 : 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFull ? 'Penuh' : 'Sisa $availableRooms kamar',
            style: TextStyle(
              color: textColor,
              fontSize: isLarge ? 13 : 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu tampilan ringkas kos bergaya modern property card.
class KosCard extends StatelessWidget {
  final Kos kos;
  final VoidCallback? onTap;

  const KosCard({
    super.key,
    required this.kos,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Visual Kos (Placeholder Berdesain Hunian Modern)
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF047857), // Emerald 700
                      Color(0xFF059669), // Emerald 600
                      Color(0xFF10B981), // Emerald 500
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Watermark pola hunian di latar belakang
                    Positioned(
                      right: -15,
                      bottom: -20,
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.home_work_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'KosFinder',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                kos.facilities.isNotEmpty
                                    ? '${kos.facilities.length} Fasilitas Tersedia'
                                    : 'Hunian Nyaman & Bersih',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Rincian Informasi Kos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Nama Kos dan Badge Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            kos.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        KosAvailabilityBadge(
                          availableRooms: kos.availableRooms,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lokasi Area
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            kos.area,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Cuplikan Fasilitas Utama (Pills)
                    if (kos.facilities.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: kos.facilities.take(3).map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.border,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getFacilityIcon(f),
                                  size: 12,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  f,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 12),

                    // Harga Sewa Bulanan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              currencyFormatter.format(kos.price),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                            const Text(
                              ' / bulan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFacilityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wi-fi') || lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('ac')) return Icons.ac_unit_rounded;
    if (lower.contains('kasur') || lower.contains('bed')) return Icons.bed_rounded;
    if (lower.contains('kamar mandi') || lower.contains('km')) {
      return Icons.shower_rounded;
    }
    if (lower.contains('parkir') || lower.contains('motor')) {
      return Icons.two_wheeler_rounded;
    }
    if (lower.contains('lemari')) return Icons.door_sliding_rounded;
    if (lower.contains('meja')) return Icons.table_restaurant_rounded;
    if (lower.contains('dapur')) return Icons.soup_kitchen_rounded;
    return Icons.check_circle_outline_rounded;
  }
}
