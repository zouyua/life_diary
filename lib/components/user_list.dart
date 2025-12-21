import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/router/router.dart';

/// 用户列表项数据模型（通用）
class UserListItem {
  final int userId;
  final String? avatar;
  final String? nickname;
  final String? subtitle; // 简介或粉丝数等

  UserListItem({
    required this.userId,
    this.avatar,
    this.nickname,
    this.subtitle,
  });
}

/// 用户列表类型
enum UserListType {
  following, // 关注列表
  fans, // 粉丝列表
}

/// 通用用户列表组件
class UserList extends StatelessWidget {
  final List<UserListItem> users;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final String emptyText;
  final Widget Function(UserListItem user)? actionBuilder;

  const UserList({
    super.key,
    required this.users,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.emptyText = '暂无数据',
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(emptyText, style: AppTextStyles.hint),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            hasMore &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: users.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildUserItem(context, users[index]);
        },
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, UserListItem user) {
    return ListTile(
      onTap: () => AppRouter.goUserProfile(user.userId),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary,
        backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
        child: user.avatar == null
            ? Text(
                user.nickname?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null,
      ),
      title: Text(
        user.nickname ?? '用户${user.userId}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: user.subtitle != null
          ? Text(
              user.subtitle!,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: actionBuilder?.call(user),
    );
  }
}
