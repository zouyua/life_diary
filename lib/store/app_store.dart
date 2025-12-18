import 'package:get/get.dart';
import 'package:frame/utils/storage.dart';

/// 用户模型
class User {
  final String id;
  final String name;
  final String? avatar;
  final String? email;

  User({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
    };
  }
}

/// 全局状态管理
class AppStore extends GetxController {
  /// 获取实例
  static AppStore get to => Get.find<AppStore>();

  /// Token
  final _token = ''.obs;
  String get token => _token.value;

  /// 用户信息
  final _user = Rxn<User>();
  User? get user => _user.value;

  /// 是否已登录
  bool get isLoggedIn => _token.value.isNotEmpty;

  /// 初始化
  Future<void> init() async {
    // 从本地存储恢复 token
    final savedToken = Storage.getString(StorageKeys.token);
    if (savedToken != null) {
      _token.value = savedToken;
    }

    // 从本地存储恢复用户信息
    final savedUser = Storage.getObject<User>(
      StorageKeys.user,
      User.fromJson,
    );
    if (savedUser != null) {
      _user.value = savedUser;
    }
  }

  /// 设置 Token
  Future<void> setToken(String token) async {
    _token.value = token;
    await Storage.setString(StorageKeys.token, token);
  }

  /// 设置用户信息
  Future<void> setUser(User user) async {
    _user.value = user;
    await Storage.setObject<User>(
      StorageKeys.user,
      user,
      (u) => u.toJson(),
    );
  }

  /// 登录
  Future<void> login(String token, User user) async {
    await setToken(token);
    await setUser(user);
  }

  /// 登出
  Future<void> logout() async {
    _token.value = '';
    _user.value = null;
    await Storage.remove(StorageKeys.token);
    await Storage.remove(StorageKeys.user);
  }

  /// 更新用户信息
  Future<void> updateUser(User user) async {
    await setUser(user);
  }
}
