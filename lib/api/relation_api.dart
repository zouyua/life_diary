import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/user.dart';

/// 用户关系模块 API
/// Gateway 路由: /relation/** -> xiaohashu-user-relation
class RelationApi {
  /// 关注用户
  static Future<void> follow(int followUserId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/relation/relation/follow',
      data: {'followUserId': followUserId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 取消关注
  static Future<void> unfollow(int unfollowUserId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/relation/relation/unfollow',
      data: {'unfollowUserId': unfollowUserId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message);
    }
  }

  /// 查询关注列表
  static Future<PageResponse<FollowingUserModel>> getFollowingList({
    required int userId,
    int pageNo = 1,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/relation/relation/following/list',
      data: {'userId': userId, 'pageNo': pageNo},
    );
    return PageResponse.fromJson(
      data ?? {},
      (d) => FollowingUserModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// 查询粉丝列表
  static Future<PageResponse<FansUserModel>> getFansList({
    required int userId,
    int pageNo = 1,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/relation/relation/fans/list',
      data: {'userId': userId, 'pageNo': pageNo},
    );
    return PageResponse.fromJson(
      data ?? {},
      (d) => FansUserModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
