import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';

void main() {
  group('KosDetailScreen Widget Tests', () {
    final sampleKos = Kos(
      id: 'k1',
      ownerId: 'o1',
      name: 'Kos Melati Cantik',
      area: 'Dipatiukur',
      address: 'Jl. Dipatiukur No. 15 Bandung',
      price: 1750000,
      totalRooms: 8,
      availableRooms: 3,
      facilities: const ['Wi-Fi', 'AC', 'KM Dalam', 'Kasur'],
      contactNumber: '081987654321',
    );

    testWidgets('Renders all kos details correctly (US01-AC3)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KosDetailScreen(kos: sampleKos),
        ),
      );

      expect(find.text('Kos Melati Cantik'), findsWidgets);
      expect(find.text('Dipatiukur'), findsOneWidget);
      expect(find.text('Jl. Dipatiukur No. 15 Bandung'), findsOneWidget);
      expect(find.textContaining('1.750.000'), findsOneWidget);
      expect(find.text('Sisa 3 kamar'), findsOneWidget);
      expect(
        find.text('Total Kamar: 8 | Kamar Tersedia: 3'),
        findsOneWidget,
      );
      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('KM Dalam'), findsOneWidget);
      expect(find.text('081987654321'), findsOneWidget);
    });

    testWidgets('Renders "Penuh" badge when availableRooms is 0',
        (WidgetTester tester) async {
      final fullKos = sampleKos.copyWith(availableRooms: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: KosDetailScreen(kos: fullKos),
        ),
      );

      expect(find.text('Penuh'), findsOneWidget);
      expect(
        find.text('Total Kamar: 8 | Kamar Tersedia: 0'),
        findsOneWidget,
      );
    });
  });
}
