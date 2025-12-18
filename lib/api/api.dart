/// API 响应模型
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 是否成功
  bool get success => code == 0;

  /// 从 JSON 创建
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'] as T?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson([Object? Function(T?)? toJsonT]) {
    return {
      'code': code,
      'message': message,
      'data': toJsonT != null ? toJsonT(data) : data,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(code: $code, message: $message, data: $data)';
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
