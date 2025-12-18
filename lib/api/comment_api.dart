import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/comment.dart';

/// 评论模块 API
class CommentApi {
  /// 发布评论
  static Future<void> publish({
    required int noteId,
    String? content,
    String? imageUrl,
    int? replyCommentId,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/comment/publish',
      data: {
        'noteId': noteId,
        if (content != null) 'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (replyCommentId != null) 'replyCommentId': replyCommentId,
      },
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 查询一级评论列表
  static Future<PageResponse<CommentModel>> getList({
    required int noteId,
    int pageNo = 1,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/comment/list',
      data: {'noteId': noteId, 'pageNo': pageNo},
    );
    return PageResponse.fromJson(
      data ?? {},
      (d) => CommentModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// 查询二级评论列表
  static Future<PageResponse<ChildCommentModel>> getChildList({
    required int parentCommentId,
    int pageNo = 1,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/comment/child/list',
      data: {'parentCommentId': parentCommentId, 'pageNo': pageNo},
    );
    return PageResponse.fromJson(
      data ?? {},
      (d) => ChildCommentModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// 点赞评论
  static Future<void> like(int commentId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/comment/like',
      data: {'commentId': commentId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 取消点赞评论
  static Future<void> unlike(int commentId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/comment/unlike',
      data: {'commentId': commentId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 删除评论
  static Future<void> delete(int commentId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/comment/delete',
      data: {'commentId': commentId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }
}
