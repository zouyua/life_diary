/// API 响应模型
class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? errorCode;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.errorCode,
    this.data,
  });

  /// 从 JSON 创建
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'] as T?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson([Object? Function(T?)? toJsonT]) {
    return {
      'success': success,
      'message': message,
      'errorCode': errorCode,
      'data': toJsonT != null ? toJsonT(data) : data,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}

/// API 异常
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode)';
  }
}

/// 分页响应模型
class PageResponse<T> {
  final List<T> list;
  final int total;
  final int page;
  final int pageSize;

  PageResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// 是否有更多数据
  bool get hasMore => page * pageSize < total;

  /// 从 JSON 创建
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return PageResponse<T>(
      list: (json['list'] as List?)?.map((e) => fromJson(e)).toList() ?? [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}
