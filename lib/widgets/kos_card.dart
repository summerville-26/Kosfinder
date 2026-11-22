import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final bgColor = isFull ? Colors.red.shade50 : Colors.green.shade50;
    final borderColor = isFull ? Colors.red.shade200 : Colors.green.shade200;
    final textColor = isFull ? Colors.red.shade800 : Colors.green.shade800;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 10 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        isFull ? 'Penuh' : 'Sisa $availableRooms kamar',
        style: TextStyle(
          color: textColor,
          fontSize: isLarge ? 13 : 12,
          fontWeight: isLarge ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }
}

/// Kartu tampilan ringkas kos untuk daftar beranda.
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

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Placeholder Lokal Bawaan Aplikasi
            Container(
              height: 140,
              width: double.infinity,
              color: Colors.green.shade50,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_rounded,
                      size: 48,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'KosFinder',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          kos.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge Ketersediaan Kamar (US03)
                      KosAvailabilityBadge(
                        availableRooms: kos.availableRooms,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          kos.area,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        currencyFormatter.format(kos.price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        ' / bulan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
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
    );
  }
}
