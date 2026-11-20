import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

void main() {
  group('AuthRepository Unit Tests', () {
    test('Throws StateError if client is accessed without initialization or injected client', () {
      final repository = AuthRepository();

      expect(() => repository.client, throwsA(isA<StateError>()));
      expect(repository.currentUser, isNull);
      expect(repository.currentSession, isNull);
      expect(repository.isAuthenticated, isFalse);
    });
  });
}
