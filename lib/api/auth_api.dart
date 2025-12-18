import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';

/// 认证模块 API
class AuthApi {
  /// 发送短信验证码
  static Future<ApiResponse> sendVerificationCode(String phone) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/verification/code/send',
      data: {'phone': phone},
    );
    return ApiResponse.fromJson(data ?? {}, null);
  }

  /// 用户登录/注册
  /// [type] 1: 验证码登录, 2: 密码登录
  static Future<String?> login({
    required String phone,
    String? code,
    String? password,
    required int type,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/login',
      data: {
        'phone': phone,
        if (code != null) 'code': code,
        if (password != null) 'password': password,
        'type': type,
      },
    );
    final response = ApiResponse<String>.fromJson(
      data ?? {},
      (d) => d as String,
    );
    if (!response.success) {
      throw ApiException(message: response.message);
    }
    return response.data;
  }

  /// 登出
  static Future<void> logout() async {
    await Http.post('/logout');
  }

  /// 修改密码
  static Future<void> updatePassword(String newPassword) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/password/update',
      data: {'newPassword': newPassword},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }
}
