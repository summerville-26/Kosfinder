import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/widgets/search_filter_bar.dart';

void main() {
  group('SearchFilterBar Widget Tests', () {
    testWidgets('Typing text triggers onSearchChanged',
        (WidgetTester tester) async {
      String searched = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchFilterBar(
              onSearchChanged: (val) => searched = val,
              onFilterTap: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Dago');
      await tester.pump();
      expect(searched, 'Dago');

      // Clear button appears
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pump();
      expect(searched, '');
    });

    testWidgets('Tapping filter button triggers onFilterTap',
        (WidgetTester tester) async {
      bool filterTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchFilterBar(
              onSearchChanged: (_) {},
              onFilterTap: () => filterTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.tune_rounded));
      expect(filterTapped, isTrue);
    });
  });
}
