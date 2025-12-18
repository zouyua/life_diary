import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/router/router.dart';

/// 个人主页
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildStats(),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE4E1), Colors.white],
          ),
        ),
        child: Obx(() {
          final user = AppStore.to.user;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? '用户', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text('小哈书号: xiaoha123', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              Text('点击添加简介', style: AppTextStyles.hint),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('编辑资料'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _logout,
                    child: const Text('退出登录'),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('0', '关注'),
            _buildStatItem('0', '粉丝'),
            _buildStatItem('0', '获赞与收藏'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildTabs() {
    return SliverToBoxAdapter(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: AppColors.text,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: '笔记'),
                Tab(text: '收藏'),
                Tab(text: '赞过'),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  _buildEmptyState('还没有笔记'),
                  _buildEmptyState('还没有收藏'),
                  _buildEmptyState('还没有赞过'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.note_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.hint),
        ],
      ),
    );
  }

  void _logout() async {
    await AppStore.to.logout();
    AppRouter.goLogin();
  }
}
