import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/core/config.dart';

void main() {
  group('AppConfig Tests', () {
    test('Default values when dart-define is not provided', () {
      // By default in test environment without --dart-define, these should be empty
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.isConfigured, isFalse);
    });
  });
}
