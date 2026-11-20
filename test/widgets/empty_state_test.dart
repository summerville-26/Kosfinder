import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('Renders title and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Kos tidak ditemukan',
              message: 'Coba gunakan kata kunci atau filter lain',
            ),
          ),
        ),
      );

      expect(find.text('Kos tidak ditemukan'), findsOneWidget);
      expect(
        find.text('Coba gunakan kata kunci atau filter lain'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('Renders action button and triggers callback',
        (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Tidak Ada Data',
              actionLabel: 'Hapus Filter',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Hapus Filter'), findsOneWidget);
      await tester.tap(find.text('Hapus Filter'));
      expect(actionTriggered, isTrue);
    });
  });
}
