import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/user.dart';

/// 用户模块 API
class UserApi {
  /// 修改用户信息
  static Future<void> updateUserInfo({
    required int userId,
    File? avatar,
    String? nickname,
    String? xiaohashuId,
    int? sex,
    String? birthday,
    String? introduction,
    File? backgroundImg,
  }) async {
    final formData = FormData.fromMap({
      'userId': userId,
      if (avatar != null)
        'avatar': await MultipartFile.fromFile(avatar.path),
      if (nickname != null) 'nickname': nickname,
      if (xiaohashuId != null) 'xiaohashuId': xiaohashuId,
      if (sex != null) 'sex': sex,
      if (birthday != null) 'birthday': birthday,
      if (introduction != null) 'introduction': introduction,
      if (backgroundImg != null)
        'backgroundImg': await MultipartFile.fromFile(backgroundImg.path),
    });

    final data = await Http.post<Map<String, dynamic>>(
      '/user/update',
      data: formData,
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 获取用户主页信息
  static Future<UserProfileModel?> getUserProfile({int? userId}) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/user/profile',
      data: userId != null ? {'userId': userId} : null,
    );
    final response = ApiResponse<UserProfileModel>.fromJson(
      data ?? {},
      (d) => UserProfileModel.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success) {
      throw ApiException(message: response.message);
    }
    return response.data;
  }
}
