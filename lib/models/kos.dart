/// Model data untuk entitas Kos sesuai skema tabel `public.kos`.
class Kos {
  final String id;
  final String ownerId;
  final String name;
  final String area;
  final String address;
  final int price;
  final int totalRooms;
  final int availableRooms;
  final List<String> facilities;
  final String contactNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Kos({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.area,
    required this.address,
    required this.price,
    required this.totalRooms,
    required this.availableRooms,
    required this.facilities,
    required this.contactNumber,
    this.createdAt,
    this.updatedAt,
  });

  /// Indikator apakah seluruh kamar kos sudah penuh.
  bool get isFull => availableRooms <= 0;

  /// Membuat instance [Kos] dari data Map/JSON Supabase.
  factory Kos.fromJson(Map<String, dynamic> json) {
    return Kos(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toInt() : 0,
      totalRooms:
          (json['total_rooms'] is num) ? (json['total_rooms'] as num).toInt() : 0,
      availableRooms: (json['available_rooms'] is num)
          ? (json['available_rooms'] as num).toInt()
          : 0,
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'] as Iterable)
          : <String>[],
      contactNumber: json['contact_number'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Mengonversi instance [Kos] ke Map/JSON untuk penyimpanan Supabase.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'owner_id': ownerId,
      'name': name,
      'area': area,
      'address': address,
      'price': price,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'facilities': facilities,
      'contact_number': contactNumber,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Kos copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? area,
    String? address,
    int? price,
    int? totalRooms,
    int? availableRooms,
    List<String>? facilities,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Kos(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      area: area ?? this.area,
      address: address ?? this.address,
      price: price ?? this.price,
      totalRooms: totalRooms ?? this.totalRooms,
      availableRooms: availableRooms ?? this.availableRooms,
      facilities: facilities ?? this.facilities,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
