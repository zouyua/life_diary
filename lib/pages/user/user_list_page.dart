import 'package:flutter/material.dart';
import 'package:frame/api/relation_api.dart';
import 'package:frame/components/user_list.dart';

/// 用户列表页面（关注/粉丝）
class UserListPage extends StatefulWidget {
  final int userId;
  final UserListType type;

  const UserListPage({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final List<UserListItem> _users = [];
  final Map<int, bool> _followStatus = {}; // 记录关注状态
  bool _isLoading = true;
  bool _hasMore = true;
  int _pageNo = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      _pageNo = 1;
      _users.clear();
      _followStatus.clear();
    }

    setState(() => _isLoading = true);

    try {
      if (widget.type == UserListType.following) {
        final response = await RelationApi.getFollowingList(
          userId: widget.userId,
          pageNo: _pageNo,
        );
        debugPrint('关注列表响应: ${response.list.length} 条数据');
        if (mounted) {
          for (var e in response.list) {
            debugPrint('用户: ${e.nickname}, 头像: ${e.avatar}');
            _users.add(UserListItem(
              userId: e.userId,
              avatar: e.avatar,
              nickname: e.nickname,
              subtitle: e.introduction,
            ));
            // 使用 API 返回的 isFollowed，如果没有则默认已关注（因为是关注列表）
            _followStatus[e.userId] = e.isFollowed ?? true;
          }
          setState(() {
            _hasMore = response.hasMore;
            if (response.list.isNotEmpty) _pageNo++;
            _isLoading = false;
          });
        }
      } else {
        final response = await RelationApi.getFansList(
          userId: widget.userId,
          pageNo: _pageNo,
        );
        debugPrint('粉丝列表响应: ${response.list.length} 条数据');
        if (mounted) {
          for (var e in response.list) {
            debugPrint('用户: ${e.nickname}, 头像: ${e.avatar}');
            _users.add(UserListItem(
              userId: e.userId,
              avatar: e.avatar,
              nickname: e.nickname,
              subtitle: _buildFansSubtitle(e.fansTotal, e.noteTotal),
            ));
            // 使用 API 返回的 isFollowed，如果没有则默认未关注
            _followStatus[e.userId] = e.isFollowed ?? false;
          }
          setState(() {
            _hasMore = response.hasMore;
            if (response.list.isNotEmpty) _pageNo++;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('加载用户列表失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  String _buildFansSubtitle(int? fansTotal, int? noteTotal) {
    final parts = <String>[];
    if (fansTotal != null) parts.add('$fansTotal 粉丝');
    if (noteTotal != null) parts.add('$noteTotal 笔记');
    return parts.join(' · ');
  }

  /// 关注/取消关注
  Future<void> _toggleFollow(int userId) async {
    final isFollowed = _followStatus[userId] ?? false;
    
    try {
      if (isFollowed) {
        await RelationApi.unfollow(userId);
        setState(() => _followStatus[userId] = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消关注')),
          );
        }
      } else {
        await RelationApi.follow(userId);
        setState(() => _followStatus[userId] = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('关注成功')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == UserListType.following ? '关注' : '粉丝';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(refresh: true),
        child: UserList(
          users: _users,
          isLoading: _isLoading,
          hasMore: _hasMore,
          onLoadMore: _loadData,
          emptyText: widget.type == UserListType.following ? '暂无关注' : '暂无粉丝',
          actionBuilder: (user) {
            final isFollowed = _followStatus[user.userId] ?? false;
            return OutlinedButton(
              onPressed: () => _toggleFollow(user.userId),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
                backgroundColor: isFollowed ? const Color(0xFFFF6B6B) : null,
                foregroundColor: isFollowed ? Colors.white : null,
              ),
              child: Text(
                isFollowed ? '已关注' : '关注',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }
}
