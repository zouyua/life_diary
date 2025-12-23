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
        // 本地开发：Android 模拟器用 10.0.2.2，Web/iOS 模拟器用 localhost
        return 'http://121.43.242.58:8000';
        // return 'http://10.0.2.2';
      case Env.prod:
        // 生产环境：通过 Nginx 反向代理，/api 转发到 Gateway
        return 'http://121.43.242.58/api';
    }
  }

  /// 应用名称
  static String get appName {
    switch (_current) {
      case Env.dev:
        return '生活手贴 Dev';
      case Env.prod:
        return '生活手贴';
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
