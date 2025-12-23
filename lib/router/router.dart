import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frame/pages/splash/splash_page.dart';
import 'package:frame/pages/main/main_page.dart';
import 'package:frame/pages/login/login_page.dart';
import 'package:frame/pages/note_detail/note_detail_page.dart';
import 'package:frame/pages/publish/publish_page.dart';
import 'package:frame/pages/profile/edit_profile_page.dart';
import 'package:frame/pages/user/user_profile_page.dart';
import 'package:frame/pages/user/user_list_page.dart';
import 'package:frame/pages/chat/chat_page.dart';
import 'package:frame/models/note.dart';
import 'package:frame/models/user.dart';
import 'package:frame/components/user_list.dart';

/// 路由名称
class Routes {
  static const String splash = '/splash';
  static const String main = '/';
  static const String login = '/login';
  static const String noteDetail = '/note/detail';
  static const String publish = '/publish';
  static const String userProfile = '/user/:userId';
  static const String editProfile = '/profile/edit';
  static const String followingList = '/following/:userId';
  static const String fansList = '/fans/:userId';
  static const String chat = '/chat';
}

/// 应用路由配置
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.main,
        name: 'main',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.noteDetail,
        name: 'noteDetail',
        builder: (context, state) {
          final noteId = state.extra as int? ?? 0;
          return NoteDetailPage(noteId: noteId);
        },
      ),
      GoRoute(
        path: Routes.publish,
        name: 'publish',
        builder: (context, state) {
          final note = state.extra as NoteDetailModel?;
          return PublishPage(editNote: note);
        },
      ),
      GoRoute(
        path: Routes.editProfile,
        name: 'editProfile',
        builder: (context, state) {
          final profile = state.extra as UserProfileModel;
          return EditProfilePage(profile: profile);
        },
      ),
      // 关注列表和粉丝列表要放在 userProfile 前面，否则会被 :userId 匹配
      GoRoute(
        path: Routes.followingList,
        name: 'followingList',
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
          return UserListPage(userId: userId, type: UserListType.following);
        },
      ),
      GoRoute(
        path: Routes.fansList,
        name: 'fansList',
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
          return UserListPage(userId: userId, type: UserListType.fans);
        },
      ),
      GoRoute(
        path: Routes.userProfile,
        name: 'userProfile',
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
          return UserProfilePage(userId: userId);
        },
      ),
      GoRoute(
        path: Routes.chat,
        name: 'chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatPage(
            conversationId: extra['conversationId'] as String?,
            targetUserId: extra['targetUserId'] as int? ?? 0,
            targetUserNickname: extra['targetUserNickname'] as String?,
            targetUserAvatar: extra['targetUserAvatar'] as String?,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面不存在: ${state.uri}'),
      ),
    ),
  );

  /// 跳转到指定路由
  static void go(String path) {
    router.go(path);
  }

  /// 压入新路由
  static void push(String path) {
    router.push(path);
  }

  /// 返回上一页
  static void back() {
    router.pop();
  }

  /// 替换当前路由
  static void replace(String path) {
    router.replace(path);
  }

  /// 跳转到主页
  static void goHome() {
    go(Routes.main);
  }

  /// 跳转到笔记详情
  static void goNoteDetail(int noteId) {
    router.push(Routes.noteDetail, extra: noteId);
  }

  /// 跳转到发布页
  static void goPublish() {
    push(Routes.publish);
  }

  /// 跳转到编辑笔记页
  static void goEditNote(NoteDetailModel note) {
    router.push(Routes.publish, extra: note);
  }

  /// 跳转到登录页
  static void goLogin() {
    go(Routes.login);
  }

  /// 跳转到编辑资料页
  static Future<bool?> goEditProfile(UserProfileModel profile) {
    return router.push<bool>(Routes.editProfile, extra: profile);
  }

  /// 跳转到用户主页
  static void goUserProfile(int userId) {
    router.push('/user/$userId');
  }

  /// 跳转到关注列表
  static void goFollowingList(int userId) {
    router.push('/following/$userId');
  }

  /// 跳转到粉丝列表
  static void goFansList(int userId) {
    router.push('/fans/$userId');
  }

  /// 跳转到聊天页面
  static Future<void> goChat({
    String? conversationId,
    required int targetUserId,
    String? targetUserNickname,
    String? targetUserAvatar,
  }) {
    return router.push(Routes.chat, extra: {
      'conversationId': conversationId,
      'targetUserId': targetUserId,
      'targetUserNickname': targetUserNickname,
      'targetUserAvatar': targetUserAvatar,
    });
  }
}
