import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/note.dart';

/// 笔记模块 API
class NoteApi {
  /// 发布笔记
  static Future<void> publish({
    required int type, // 0: 图文, 1: 视频
    List<String>? imgUris,
    String? videoUri,
    String? title,
    String? content,
    int? topicId,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/publish',
      data: {
        'type': type,
        if (imgUris != null) 'imgUris': imgUris,
        if (videoUri != null) 'videoUri': videoUri,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (topicId != null) 'topicId': topicId,
      },
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 获取笔记详情
  static Future<NoteDetailModel?> getDetail(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/detail',
      data: {'id': id},
    );
    final response = ApiResponse<NoteDetailModel>.fromJson(
      data ?? {},
      (d) => NoteDetailModel.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success) {
      throw ApiException(message: response.message);
    }
    return response.data;
  }

  /// 修改笔记
  static Future<void> update({
    required int id,
    required int type,
    List<String>? imgUris,
    String? videoUri,
    String? title,
    String? content,
    int? topicId,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/update',
      data: {
        'id': id,
        'type': type,
        if (imgUris != null) 'imgUris': imgUris,
        if (videoUri != null) 'videoUri': videoUri,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (topicId != null) 'topicId': topicId,
      },
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 删除笔记
  static Future<void> delete(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/delete',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 设置笔记仅自己可见
  static Future<void> setOnlyMe(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/visible/onlyme',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 置顶/取消置顶笔记
  static Future<void> setTop(int id, bool isTop) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/top',
      data: {'id': id, 'isTop': isTop},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 点赞笔记
  static Future<void> like(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/like',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 取消点赞笔记
  static Future<void> unlike(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/unlike',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 收藏笔记
  static Future<void> collect(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/collect',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 取消收藏笔记
  static Future<void> uncollect(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/uncollect',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 获取点赞收藏状态
  static Future<NoteLikeCollectStatus?> getLikeCollectStatus(int noteId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/isLikedAndCollectedData',
      data: {'noteId': noteId},
    );
    final response = ApiResponse<NoteLikeCollectStatus>.fromJson(
      data ?? {},
      (d) => NoteLikeCollectStatus.fromJson(d as Map<String, dynamic>),
    );
    return response.data;
  }

  /// 获取用户已发布笔记列表（游标分页）
  static Future<NoteListResponse?> getPublishedList({
    required int userId,
    int? cursor,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/published/list',
      data: {
        'userId': userId,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final response = ApiResponse<NoteListResponse>.fromJson(
      data ?? {},
      (d) => NoteListResponse.fromJson(d as Map<String, dynamic>),
    );
    return response.data;
  }
}
