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
    // 兼容 data 和 list 两种字段名
    final dataList = json['data'] ?? json['list'];
    final list = (dataList as List?)?.map((e) => fromJson(e)).toList() ?? [];
    final total = json['total'] as int? ?? json['totalCount'] as int? ?? 0;
    final page = json['pageNo'] as int? ?? json['page'] as int? ?? 1;
    final pageSize = json['pageSize'] as int? ?? 10;
    
    return PageResponse<T>(
      list: list,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }
}
