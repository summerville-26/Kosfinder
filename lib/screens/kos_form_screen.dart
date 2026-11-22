import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/kos.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

/// Layar formulir untuk menambah atau mengubah data kos (US05, US06) dengan desain Modern Green & White.
class KosFormScreen extends StatefulWidget {
  final Kos? initialKos;

  const KosFormScreen({super.key, this.initialKos});

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _totalRoomsController;
  late final TextEditingController _availableRoomsController;
  late final TextEditingController _contactController;

  final List<String> _availableFacilities = [
    'Wi-Fi',
    'AC',
    'Kamar Mandi Dalam',
    'Kasur',
    'Lemari',
    'Meja Belajar',
    'Parkir Motor',
    'Dapur Bersama',
  ];

  final Set<String> _selectedFacilities = {};
  bool _isSubmitting = false;

  bool get isEditMode => widget.initialKos != null;

  @override
  void initState() {
    super.initState();
    final kos = widget.initialKos;
    _nameController = TextEditingController(text: kos?.name ?? '');
    _areaController = TextEditingController(text: kos?.area ?? '');
    _addressController = TextEditingController(text: kos?.address ?? '');
    _priceController =
        TextEditingController(text: kos != null ? kos.price.toString() : '');
    _totalRoomsController = TextEditingController(
        text: kos != null ? kos.totalRooms.toString() : '');
    _availableRoomsController = TextEditingController(
        text: kos != null ? kos.availableRooms.toString() : '');
    _contactController =
        TextEditingController(text: kos?.contactNumber ?? '');

    if (kos != null) {
      _selectedFacilities.addAll(kos.facilities);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _totalRoomsController.dispose();
    _availableRoomsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi telah berakhir. Silakan masuk kembali.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final totalRooms = int.parse(_totalRoomsController.text.trim());
    final availableRooms = int.parse(_availableRoomsController.text.trim());

    if (availableRooms > totalRooms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamar tersedia tidak boleh melebihi total kamar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final kosData = {
      'owner_id': userId,
      'name': _nameController.text.trim(),
      'area': _areaController.text.trim(),
      'address': _addressController.text.trim(),
      'price': int.parse(_priceController.text.trim()),
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'facilities': _selectedFacilities.toList(),
      'contact_number': _contactController.text.trim(),
    };

    final kosProvider = context.read<KosProvider>();
    bool success;

    if (isEditMode) {
      success = await kosProvider.updateKos(widget.initialKos!.id, kosData);
    } else {
      success = await kosProvider.createKos(kosData);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode
              ? 'Data kos berhasil diperbarui'
              : 'Data kos berhasil ditambahkan'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final errorMsg =
          kosProvider.errorMessage ?? 'Terjadi kesalahan saat menyimpan data';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Ubah Data Kos' : 'Tambah Kos Baru',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Informasi Dasar Kos
              _buildFormSection(
                title: 'Informasi Properti',
                icon: Icons.home_work_outlined,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kos *',
                      hintText: 'Contoh: Kos Sejahtera Dago',
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.home_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama kos wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Lokasi Kos
              _buildFormSection(
                title: 'Lokasi & Alamat',
                icon: Icons.location_on_outlined,
                children: [
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      labelText: 'Area / Kampus Terdekat *',
                      hintText: 'Contoh: Dago / ITB',
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.near_me_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Area wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap *',
                      hintText: 'Jalan, nomor, kelurahan, kecamatan',
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alamat lengkap wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. Biaya & Kapasitas Kamar
              _buildFormSection(
                title: 'Tarif & Kamar',
                icon: Icons.payments_outlined,
                children: [
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Harga Sewa per Bulan (Rp) *',
                      hintText: 'Contoh: 1500000',
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.sell_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Harga sewa wajib diisi';
                      }
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Harga sewa harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _totalRoomsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Total Kamar *',
                            hintText: 'Contoh: 10',
                            filled: true,
                            fillColor: AppColors.background,
                            prefixIcon: const Icon(Icons.meeting_room_outlined, color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Wajib diisi';
                            }
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Harus > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _availableRoomsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Kamar Tersedia *',
                            hintText: 'Contoh: 3',
                            filled: true,
                            fillColor: AppColors.background,
                            prefixIcon: const Icon(Icons.door_front_door_outlined, color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Wajib diisi';
                            }
                            final available = int.tryParse(value.trim());
                            if (available == null || available < 0) {
                              return 'Harus >= 0';
                            }
                            final total = int.tryParse(_totalRoomsController.text.trim());
                            if (total != null && available > total) {
                              return 'Tidak boleh > total';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Fasilitas Tersedia
              _buildFormSection(
                title: 'Fasilitas Tersedia',
                icon: Icons.check_circle_outline_rounded,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableFacilities.map((facility) {
                      final isSelected = _selectedFacilities.contains(facility);
                      return FilterChip(
                        label: Text(facility),
                        selected: isSelected,
                        selectedColor: AppColors.primarySurface,
                        checkmarkColor: AppColors.primary,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFacilities.add(facility);
                            } else {
                              _selectedFacilities.remove(facility);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 5. Kontak Pemilik
              _buildFormSection(
                title: 'Kontak Pemilik',
                icon: Icons.phone_outlined,
                children: [
                  TextFormField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Kontak Pemilik (WhatsApp/HP) *',
                      hintText: 'Contoh: 081234567890',
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor kontak wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    _isSubmitting
                        ? 'Menyimpan...'
                        : (isEditMode ? 'Simpan Perubahan' : 'Simpan Kos'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
