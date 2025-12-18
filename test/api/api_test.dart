import 'package:flutter_test/flutter_test.dart';
import 'package:frame/api/api.dart';

// **Feature: flutter-enterprise-framework, Property 3: HTTP Error Handling**
// **Validates: Requirements 3.2**
void main() {
  group('ApiResponse Tests', () {
    test('ApiResponse fromJson/toJson round-trip', () {
      final original = ApiResponse<String>(
        code: 0,
        message: 'success',
        data: 'test data',
      );

      final json = original.toJson();
      final restored = ApiResponse<String>.fromJson(json, (j) => j as String);

      expect(restored.code, equals(original.code));
      expect(restored.message, equals(original.message));
      expect(restored.data, equals(original.data));
    });

    test('ApiResponse success flag is correct', () {
      final successResponse = ApiResponse<String>(code: 0, message: 'ok');
      final errorResponse = ApiResponse<String>(code: 1, message: 'error');

      expect(successResponse.success, isTrue);
      expect(errorResponse.success, isFalse);
    });

    test('ApiResponse handles null data correctly', () {
      final json = {'code': 0, 'message': 'success', 'data': null};
      final response = ApiResponse<String>.fromJson(json, (j) => j as String);

      expect(response.code, equals(0));
      expect(response.message, equals('success'));
      expect(response.data, isNull);
    });
  });

  group('ApiException Tests', () {
    test('ApiException contains message and statusCode', () {
      final exception = ApiException(
        message: 'Network error',
        statusCode: 500,
        data: {'error': 'Internal server error'},
      );

      expect(exception.message, equals('Network error'));
      expect(exception.statusCode, equals(500));
      expect(exception.data, isNotNull);
    });

    test('ApiException toString contains key info', () {
      final exception = ApiException(
        message: 'Not found',
        statusCode: 404,
      );

      final str = exception.toString();
      expect(str, contains('Not found'));
      expect(str, contains('404'));
    });

    test('Various status codes produce valid ApiException', () {
      for (final statusCode in [200, 400, 401, 403, 404, 500, 502, 503]) {
        final exception = ApiException(
          message: 'Error',
          statusCode: statusCode,
        );

        expect(exception.message, isNotEmpty);
        expect(exception.statusCode, equals(statusCode));
      }
    });
  });

  group('PageResponse Tests', () {
    test('PageResponse hasMore is correct', () {
      final hasMoreResponse = PageResponse<String>(
        list: ['a', 'b'],
        total: 10,
        page: 1,
        pageSize: 2,
      );

      final noMoreResponse = PageResponse<String>(
        list: ['a', 'b'],
        total: 2,
        page: 1,
        pageSize: 2,
      );

      expect(hasMoreResponse.hasMore, isTrue);
      expect(noMoreResponse.hasMore, isFalse);
    });

    test('PageResponse fromJson works correctly', () {
      final json = {
        'list': ['item1', 'item2'],
        'total': 100,
        'page': 1,
        'pageSize': 10,
      };

      final response = PageResponse<String>.fromJson(json, (j) => j as String);

      expect(response.list.length, equals(2));
      expect(response.total, equals(100));
      expect(response.page, equals(1));
      expect(response.pageSize, equals(10));
    });
  });
}
