import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/pages/home/home_page.dart';
import 'package:frame/pages/login/login_page.dart';

/// 路由名称
class Routes {
  static const String home = '/';
  static const String login = '/login';
}

/// 应用路由配置
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.home,
    redirect: _authGuard,
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
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

    // 已登录且在登录页，跳转到首页
    if (isLoggedIn && isLoginPage) {
      return Routes.home;
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

  /// 跳转到首页
  static void goHome() {
    go(Routes.home);
  }

  /// 跳转到登录页
  static void goLogin() {
    go(Routes.login);
  }
}
