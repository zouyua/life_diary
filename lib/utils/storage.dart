import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储工具
class Storage {
  static SharedPreferences? _prefs;

  /// 初始化存储
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取 SharedPreferences 实例
  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('Storage not initialized. Call Storage.init() first.');
    }
    return _prefs!;
  }

  /// 存储字符串
  static Future<bool> setString(String key, String value) async {
    return await _instance.setString(key, value);
  }

  /// 获取字符串
  static String? getString(String key) {
    return _instance.getString(key);
  }

  /// 存储整数
  static Future<bool> setInt(String key, int value) async {
    return await _instance.setInt(key, value);
  }

  /// 获取整数
  static int? getInt(String key) {
    return _instance.getInt(key);
  }

  /// 存储布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }

  /// 获取布尔值
  static bool? getBool(String key) {
    return _instance.getBool(key);
  }

  /// 存储双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    return await _instance.setDouble(key, value);
  }

  /// 获取双精度浮点数
  static double? getDouble(String key) {
    return _instance.getDouble(key);
  }

  /// 存储对象（JSON 序列化）
  static Future<bool> setObject<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final jsonStr = jsonEncode(toJson(value));
    return await _instance.setString(key, jsonStr);
  }

  /// 获取对象（JSON 反序列化）
  static T? getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final jsonStr = _instance.getString(key);
    if (jsonStr == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// 删除指定键
  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }

  /// 清除所有数据
  static Future<bool> clear() async {
    return await _instance.clear();
  }

  /// 检查键是否存在
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }

  /// 获取所有键
  static Set<String> getKeys() {
    return _instance.getKeys();
  }
}

/// 存储键常量
class StorageKeys {
  static const String token = 'token';
  static const String user = 'user';
  static const String theme = 'theme';
  static const String locale = 'locale';
  static const String isFirstLaunch = 'is_first_launch';
}
