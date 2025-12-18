import 'package:logger/logger.dart' as log;
import 'package:frame/config/env.dart';

/// 应用日志工具
class AppLogger {
  static final log.Logger _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Debug 日志
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Info 日志
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Warning 日志
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Error 日志
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// 网络请求日志
  static void network(String method, String url, {dynamic data, dynamic response}) {
    if (EnvConfig.enableLogging) {
      _logger.i('[$method] $url\nRequest: $data\nResponse: $response');
    }
  }
}
