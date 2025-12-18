import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:frame/app.dart';
import 'package:frame/config/env.dart';
import 'package:frame/api/http.dart';
import 'package:frame/utils/storage.dart';
import 'package:frame/utils/logger.dart';
import 'package:frame/store/app_store.dart';

void main() async {
  await _init();
  runApp(const App());
}

/// 应用初始化
Future<void> _init() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置环境（可通过编译参数切换）
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  EnvConfig.setEnv(env == 'prod' ? Env.prod : Env.dev);

  // 初始化本地存储
  await Storage.init();

  // 初始化 HTTP 客户端
  Http.init();

  // 注册全局状态
  Get.put(AppStore());
  await AppStore.to.init();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppLogger.info('App initialized in ${EnvConfig.current.name} mode');
}
