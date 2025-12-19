import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/note.dart';
import 'package:frame/models/channel.dart';

/// 笔记模块 API
/// Gateway 路由: /note/** -> xiaohashu-note
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
      '/note/note/publish',
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
      throw ApiException(message: response.message ?? '发布失败');
    }
  }

  /// 获取笔记详情
  static Future<NoteDetailModel?> getDetail(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/detail',
      data: {'id': id},
    );
    final response = ApiResponse<NoteDetailModel>.fromJson(
      data ?? {},
      (d) => NoteDetailModel.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success) {
      throw ApiException(message: response.message ?? '获取详情失败');
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
      '/note/note/update',
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
      throw ApiException(message: response.message ?? '修改失败');
    }
  }

  /// 删除笔记
  static Future<void> delete(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/delete',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '删除失败');
    }
  }

  /// 设置笔记仅自己可见
  static Future<void> setOnlyMe(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/visible/onlyme',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '操作失败');
    }
  }

  /// 置顶/取消置顶笔记
  static Future<void> setTop(int id, bool isTop) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/top',
      data: {'id': id, 'isTop': isTop},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '操作失败');
    }
  }

  /// 点赞笔记
  static Future<void> like(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/like',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '点赞失败');
    }
  }

  /// 取消点赞笔记
  static Future<void> unlike(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/unlike',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '取消点赞失败');
    }
  }

  /// 收藏笔记
  static Future<void> collect(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/collect',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '收藏失败');
    }
  }

  /// 取消收藏笔记
  static Future<void> uncollect(int id) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/uncollect',
      data: {'id': id},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '取消收藏失败');
    }
  }

  /// 获取点赞收藏状态
  static Future<NoteLikeCollectStatus?> getLikeCollectStatus(int noteId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/isLikedAndCollectedData',
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
      '/note/note/published/list',
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

  /// 获取首页推荐笔记列表
  static Future<List<NoteItemModel>> getHomeList({int? cursor}) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/note/list',
      data: {
        if (cursor != null) 'cursor': cursor,
      },
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (response.success && response.data != null) {
      final list = response.data as List?;
      return list?.map((e) => NoteItemModel.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  /// 获取频道列表
  static Future<List<ChannelModel>> getChannelList() async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/channel/list',
      data: {},
    );
    if (data != null && data['success'] == true && data['data'] != null) {
      final list = data['data'] as List;
      return list
          .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// 获取频道下的话题列表
  static Future<List<TopicModel>> getTopicList(int channelId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/note/channel/topic/list',
      data: {'channelId': channelId},
    );
    if (data != null && data['success'] == true && data['data'] != null) {
      final list = data['data'] as List;
      return list
          .map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
