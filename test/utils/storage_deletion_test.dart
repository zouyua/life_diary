import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frame/utils/storage.dart';

// **Feature: flutter-enterprise-framework, Property 2: Storage Deletion**
// **Validates: Requirements 6.4**
void main() {
  group('Storage Deletion Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('Storage deletion: after remove, key should return null', () async {
      const key = 'test_key';
      const value = 'test_value';
      
      await Storage.setString(key, value);
      expect(Storage.getString(key), equals(value));
      
      await Storage.remove(key);
      
      expect(Storage.getString(key), isNull);
      expect(Storage.containsKey(key), isFalse);
    });

    test('Storage clear: removes all stored values', () async {
      await Storage.setString('key1', 'value1');
      await Storage.setString('key2', 'value2');
      await Storage.setInt('key3', 123);
      
      expect(Storage.getString('key1'), isNotNull);
      expect(Storage.getString('key2'), isNotNull);
      expect(Storage.getInt('key3'), isNotNull);
      
      await Storage.clear();
      
      expect(Storage.getString('key1'), isNull);
      expect(Storage.getString('key2'), isNull);
      expect(Storage.getInt('key3'), isNull);
    });
  });
}
