import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frame/utils/storage.dart';

// **Feature: flutter-enterprise-framework, Property 1: Storage Round-Trip**
// **Validates: Requirements 6.1, 6.2, 6.3**
void main() {
  group('Storage Round-Trip Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('String storage round-trip', () async {
      const key = 'test_string';
      const value = 'hello world';
      await Storage.setString(key, value);
      final result = Storage.getString(key);
      expect(result, equals(value));
    });

    test('Int storage round-trip', () async {
      const key = 'test_int';
      const value = 12345;
      await Storage.setInt(key, value);
      final result = Storage.getInt(key);
      expect(result, equals(value));
    });

    test('Bool storage round-trip', () async {
      const key = 'test_bool';
      const value = true;
      await Storage.setBool(key, value);
      final result = Storage.getBool(key);
      expect(result, equals(value));
    });

    test('Double storage round-trip', () async {
      const key = 'test_double';
      const value = 3.14159;
      await Storage.setDouble(key, value);
      final result = Storage.getDouble(key);
      expect(result, equals(value));
    });

    test('Multiple values round-trip', () async {
      final testCases = ['', 'a', 'hello', '中文', 'emoji 🎉'];
      for (final value in testCases) {
        await Storage.setString('key', value);
        expect(Storage.getString('key'), equals(value));
      }
    });
  });
}
