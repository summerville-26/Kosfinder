import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';

void main() {
  group('Kos Model Tests', () {
    final sampleMap = {
      'id': 'uuid-1234',
      'owner_id': 'owner-5678',
      'name': 'Kos Dago Asri',
      'area': 'Dago',
      'address': 'Jl. Dago Asri No. 10',
      'price': 1500000,
      'total_rooms': 10,
      'available_rooms': 2,
      'facilities': ['Wi-Fi', 'AC', 'KM Dalam'],
      'contact_number': '081234567890',
      'created_at': '2026-11-20T10:00:00.000Z',
      'updated_at': '2026-11-20T10:00:00.000Z',
    };

    test('Kos.fromJson parses all fields correctly', () {
      final kos = Kos.fromJson(sampleMap);

      expect(kos.id, 'uuid-1234');
      expect(kos.ownerId, 'owner-5678');
      expect(kos.name, 'Kos Dago Asri');
      expect(kos.area, 'Dago');
      expect(kos.address, 'Jl. Dago Asri No. 10');
      expect(kos.price, 1500000);
      expect(kos.totalRooms, 10);
      expect(kos.availableRooms, 2);
      expect(kos.facilities, ['Wi-Fi', 'AC', 'KM Dalam']);
      expect(kos.contactNumber, '081234567890');
      expect(kos.createdAt, isNotNull);
      expect(kos.updatedAt, isNotNull);
      expect(kos.isFull, isFalse);
    });

    test('Kos.isFull returns true when available_rooms is 0', () {
      final mapWithZeroRooms = Map<String, dynamic>.from(sampleMap)
        ..['available_rooms'] = 0;
      final kos = Kos.fromJson(mapWithZeroRooms);

      expect(kos.availableRooms, 0);
      expect(kos.isFull, isTrue);
    });

    test('Kos.fromJson safely handles null/missing optional fields', () {
      final emptyMap = <String, dynamic>{};
      final kos = Kos.fromJson(emptyMap);

      expect(kos.id, isEmpty);
      expect(kos.name, isEmpty);
      expect(kos.price, 0);
      expect(kos.totalRooms, 0);
      expect(kos.availableRooms, 0);
      expect(kos.facilities, isEmpty);
      expect(kos.isFull, isTrue);
      expect(kos.createdAt, isNull);
    });

    test('Kos.toJson serializes properties correctly', () {
      final kos = Kos.fromJson(sampleMap);
      final json = kos.toJson();

      expect(json['id'], 'uuid-1234');
      expect(json['name'], 'Kos Dago Asri');
      expect(json['price'], 1500000);
      expect(json['facilities'], ['Wi-Fi', 'AC', 'KM Dalam']);
      expect(json['contact_number'], '081234567890');
    });
  });
}
