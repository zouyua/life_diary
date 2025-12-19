import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';

/// 文件上传模块 API
class OssApi {
  /// 上传文件 (移动端)
  static Future<String?> uploadFile(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final data = await Http.post<Map<String, dynamic>>(
      '/oss/file/upload',
      data: formData,
    );
    final response = ApiResponse<String>.fromJson(
      data ?? {},
      (d) => d as String,
    );
    if (!response.success) {
      throw ApiException(message: response.message ?? '上传失败');
    }
    return response.data;
  }

  /// 上传文件字节 (Web端)
  static Future<String?> uploadFileBytes(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final data = await Http.post<Map<String, dynamic>>(
      '/oss/file/upload',
      data: formData,
    );
    final response = ApiResponse<String>.fromJson(
      data ?? {},
      (d) => d as String,
    );
    if (!response.success) {
      throw ApiException(message: response.message ?? '上传失败');
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
