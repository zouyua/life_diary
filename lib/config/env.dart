/// 环境枚举
enum Env {
  dev,
  prod,
}

/// 环境配置
class EnvConfig {
  static Env _current = Env.dev;

  /// 当前环境
  static Env get current => _current;

  /// 设置当前环境
  static void setEnv(Env env) {
    _current = env;
  }

  /// API 基础地址
  static String get apiBaseUrl {
    switch (_current) {
      case Env.dev:
        return 'http://localhost:8000';
      case Env.prod:
        return 'https://api.example.com';
    }
  }

  /// 应用名称
  static String get appName {
    switch (_current) {
      case Env.dev:
        return 'Frame Dev';
      case Env.prod:
        return 'Frame';
    }
  }

  /// 是否启用日志
  static bool get enableLogging {
    switch (_current) {
      case Env.dev:
        return true;
      case Env.prod:
        return false;
    }
  }

  /// 是否为开发环境
  static bool get isDev => _current == Env.dev;

  /// 是否为生产环境
  static bool get isProd => _current == Env.prod;
}
