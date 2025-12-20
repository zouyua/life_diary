import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/pages/main/main_page.dart';
import 'package:frame/pages/login/login_page.dart';
import 'package:frame/pages/note_detail/note_detail_page.dart';
import 'package:frame/pages/publish/publish_page.dart';
import 'package:frame/models/note.dart';

/// 路由名称
class Routes {
  static const String main = '/';
  static const String login = '/login';
  static const String noteDetail = '/note/detail';
  static const String publish = '/publish';
  static const String userProfile = '/user/:userId';
}

/// 应用路由配置
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.main,
    redirect: _authGuard,
    refreshListenable: AppStore.authNotifier,
    routes: [
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面不存在: ${state.uri}'),
      ),
    ),
  );

  /// 路由守卫
  static String? _authGuard(BuildContext context, GoRouterState state) {
    final isLoggedIn = AppStore.to.isLoggedIn;
    final isLoginPage = state.matchedLocation == Routes.login;

    // 未登录且不在登录页，跳转到登录页
    if (!isLoggedIn && !isLoginPage) {
      return Routes.login;
    }

    // 已登录且在登录页，跳转到主页
    if (isLoggedIn && isLoginPage) {
      return Routes.main;
    }

    return null;
  }

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
}
