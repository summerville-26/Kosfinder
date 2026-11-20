import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/screens/about_screen.dart';

void main() {
  group('AboutScreen Widget Tests', () {
    testWidgets('Renders required developer identity and app info (AGENTS.md)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('KosFinder'), findsOneWidget);
      expect(find.text('Versi 0.1.0'), findsOneWidget);
      expect(find.text('Identitas Pengembang'), findsOneWidget);
      expect(find.text('2415051085'), findsOneWidget);
      expect(find.text('I Komang Candra Aryadinata'), findsOneWidget);
    });
  });
}
