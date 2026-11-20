import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockKosRepo extends KosRepository {
  @override
  Future<List<Kos>> getAllKos({
    String? query,
    int? minPrice,
    int? maxPrice,
  }) async =>
      [];
}

class MockAuthRepo extends AuthRepository {}

void main() {
  testWidgets(
      'KosFinderApp smoke test - renders HomeScreen with title and search bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      KosFinderApp(
        kosRepository: MockKosRepo(),
        authRepository: MockAuthRepo(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('KosFinder'), findsOneWidget);
    expect(find.text('Cari nama kos atau area...'), findsOneWidget);
  });
}
