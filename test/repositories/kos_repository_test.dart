import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

void main() {
  group('KosRepository Unit Tests', () {
    test('Throws StateError if client is accessed without initialization or injected client', () {
      final repository = KosRepository();

      expect(() => repository.client, throwsA(isA<StateError>()));
    });
  });
}
