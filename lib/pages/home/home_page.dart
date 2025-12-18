import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/router/router.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/app_button.dart';

/// 首页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserCard(),
            const SizedBox(height: 24),
            _buildFeatureSection(),
            const SizedBox(height: 24),
            _buildButtonDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Obx(() {
      final user = AppStore.to.user;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '用户',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('框架功能', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildFeatureCard(Icons.http, '网络请求', 'Dio 封装'),
            _buildFeatureCard(Icons.storage, '本地存储', 'SharedPreferences'),
            _buildFeatureCard(Icons.route, '路由管理', 'go_router'),
            _buildFeatureCard(Icons.palette, '主题系统', '亮/暗主题'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.body1),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('按钮组件', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const AppButton(text: '主要按钮'),
            const AppButton(text: '次要按钮', type: AppButtonType.secondary),
            const AppButton(text: '边框按钮', type: AppButtonType.outline),
            const AppButton(text: '文字按钮', type: AppButtonType.text),
            const AppButton(text: '加载中', loading: true),
            AppButton(text: '带图标', icon: Icons.add, onPressed: () {}),
          ],
        ),
      ],
    );
  }

  void _logout() async {
    await AppStore.to.logout();
    AppRouter.goLogin();
  }
}
