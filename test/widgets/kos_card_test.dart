import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('KosCard Widget Tests', () {
    testWidgets('Renders kos name, area, price, and rooms available (US03-AC2)',
        (WidgetTester tester) async {
      final kos = Kos(
        id: '1',
        ownerId: 'owner1',
        name: 'Kos Dahlia Indah',
        area: 'Dago Atas',
        address: 'Jl. Dago Atas No. 5',
        price: 1350000,
        totalRooms: 10,
        availableRooms: 3,
        facilities: const ['Wi-Fi', 'AC'],
        contactNumber: '08123456789',
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KosCard(
              kos: kos,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Kos Dahlia Indah'), findsOneWidget);
      expect(find.text('Dago Atas'), findsOneWidget);
      expect(find.text('Sisa 3 kamar'), findsOneWidget);
      expect(find.textContaining('1.350.000'), findsOneWidget);
      expect(find.byType(KosAvailabilityBadge), findsOneWidget);

      await tester.tap(find.byType(KosCard));
      expect(tapped, isTrue);
    });

    testWidgets(
        'Renders "Penuh" badge when availableRooms is 0 without hiding kos (US03-AC1)',
        (WidgetTester tester) async {
      final kos = Kos(
        id: '2',
        ownerId: 'owner1',
        name: 'Kos Mawar Penuh',
        area: 'Coblong',
        address: 'Jl. Coblong No. 2',
        price: 900000,
        totalRooms: 8,
        availableRooms: 0,
        facilities: const ['Wi-Fi'],
        contactNumber: '08123456789',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KosCard(kos: kos),
          ),
        ),
      );

      expect(find.text('Kos Mawar Penuh'), findsOneWidget);
      expect(find.text('Penuh'), findsOneWidget);
      expect(find.textContaining('900.000'), findsOneWidget);
      expect(find.byType(KosAvailabilityBadge), findsOneWidget);
    });

    testWidgets('KosAvailabilityBadge standalone test for positive and zero rooms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                KosAvailabilityBadge(availableRooms: 5),
                KosAvailabilityBadge(availableRooms: 0),
                KosAvailabilityBadge(availableRooms: -1),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sisa 5 kamar'), findsOneWidget);
      expect(find.text('Penuh'), findsNWidgets(2));
    });
  });
}
