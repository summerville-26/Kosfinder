import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

/// Layar formulir untuk menambah atau mengubah data kos (US05, US06).
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
          backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
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
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final errorMsg = kosProvider.errorMessage ?? 'Terjadi kesalahan saat menyimpan data';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Ubah Data Kos' : 'Tambah Kos Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field Nama Kos
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kos *',
                  hintText: 'Contoh: Kos Sejahtera Dago',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field Area
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Kampus Terdekat *',
                  hintText: 'Contoh: Dago / ITB',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Area wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field Alamat Lengkap
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap *',
                  hintText: 'Jalan, nomor, kelurahan, kecamatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat lengkap wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field Harga Sewa
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga Sewa per Bulan (Rp) *',
                  hintText: 'Contoh: 1500000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
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
              const SizedBox(height: 16),

              // Baris Kamar (Total & Tersedia)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalRoomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Kamar *',
                        hintText: 'Contoh: 10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room_outlined),
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
                      decoration: const InputDecoration(
                        labelText: 'Kamar Tersedia *',
                        hintText: 'Contoh: 3',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.door_front_door_outlined),
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
              const SizedBox(height: 16),

              // Field Kontak
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kontak Pemilik (WhatsApp/HP) *',
                  hintText: 'Contoh: 081234567890',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor kontak wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Pilihan Fasilitas
              const Text(
                'Fasilitas Tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableFacilities.map((facility) {
                  final isSelected = _selectedFacilities.contains(facility);
                  return FilterChip(
                    label: Text(facility),
                    selected: isSelected,
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
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSubmitting
                        ? 'Menyimpan...'
                        : (isEditMode ? 'Simpan Perubahan' : 'Simpan Kos'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
