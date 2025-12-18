import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';

/// 文件上传模块 API
class OssApi {
  /// 上传文件
  static Future<String?> uploadFile(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final data = await Http.post<Map<String, dynamic>>(
      '/file/upload',
      data: formData,
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

  /// 批量上传文件
  static Future<List<String>> uploadFiles(List<File> files) async {
    final results = <String>[];
    for (final file in files) {
      final url = await uploadFile(file);
      if (url != null) {
        results.add(url);
      }
    }
    return results;
  }
}
