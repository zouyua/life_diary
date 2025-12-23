import 'package:dio/dio.dart';
import 'package:frame/config/env.dart';
import 'package:frame/utils/logger.dart';
import 'package:frame/utils/storage.dart';
import 'package:frame/api/api.dart';
import 'package:frame/store/app_store.dart';

/// HTTP 请求封装
class Http {
  static final Dio _dio = Dio();
  static bool _initialized = false;

  /// 初始化 HTTP 客户端
  static void init() {
    if (_initialized) return;

    _dio.options = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加拦截器
    _dio.interceptors.add(_LogInterceptor());
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());

    _initialized = true;
  }

  /// GET 请求
  static Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? params,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  static Future<T?> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: params);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  static Future<T?> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  static Future<T?> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 处理响应
  static T? _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    final data = response.data;
    if (data == null) return null;
    if (fromJson != null) {
      return fromJson(data);
    }
    return data as T?;
  }

  /// 处理错误
  static ApiException _handleError(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '网络连接超时';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败';
        break;
      case DioExceptionType.badResponse:
        message = _getErrorMessage(statusCode);
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      default:
        message = '网络错误';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: e.response?.data,
    );
  }

  /// 根据状态码获取错误信息
  static String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      default:
        return '请求失败';
    }
  }
}

/// 日志拦截器
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.network(
      options.method,
      '${options.baseUrl}${options.path}',
      data: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.network(
      response.requestOptions.method,
      '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      response: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'HTTP Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      err,
    );
    handler.next(err);
  }
}

/// 认证拦截器
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 优先从 AppStore 读取 token（内存中同步更新）
    // 如果 AppStore 还没初始化，则从 Storage 读取
    String? token;
    try {
      token = AppStore.to.token;
    } catch (_) {
      token = Storage.getString(StorageKeys.token);
    }
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// 错误拦截器
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 未授权处理
    if (err.response?.statusCode == 401) {
      // 清除 token，跳转登录页
      Storage.remove(StorageKeys.token);
      // 可以在这里触发全局登录过期事件
    }
    handler.next(err);
  }
}
