import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/search.dart';

/// 搜索模块 API
class SearchApi {
  /// 搜索用户
  static Future<PageResponse<SearchUserModel>> searchUser({
    required String keyword,
    int pageNo = 1,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/search/user',
      data: {'keyword': keyword, 'pageNo': pageNo},
    );
    return PageResponse.fromJson(
      data ?? {},
      (d) => SearchUserModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// 搜索笔记
  /// [type] null: 综合, 0: 图文, 1: 视频
  /// [sort] null: 不限, 0: 最新, 1: 最多点赞, 2: 最多评论, 3: 最多收藏
  /// [publishTimeRange] null: 不限, 0: 一天内, 1: 一周内, 2: 半年内
  static Future<PageResponse<SearchNoteModel>> searchNote({
    required String keyword,
    int pageNo = 1,
    int? type,
    int? sort,
    int? publishTimeRange,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/search/note',
      data: {
        'keyword': keyword,
        'pageNo': pageNo,
        if (type != null) 'type': type,
        if (sort != null) 'sort': sort,
        if (publishTimeRange != null) 'publishTimeRange': publishTimeRange,
      },
    );
    return PageResponse.fromJson(
      data ?? {},
      (d) => SearchNoteModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
