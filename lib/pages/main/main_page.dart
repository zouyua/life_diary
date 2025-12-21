import 'package:flutter/material.dart';
import 'package:frame/pages/home/home_page.dart';
import 'package:frame/pages/search/search_page.dart';
import 'package:frame/pages/message/message_page.dart';
import 'package:frame/pages/profile/profile_page.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/router/router.dart';

/// 主页面（底部导航）
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // 使用 GlobalKey 来访问子页面的状态
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const SearchPage(),
      const SizedBox(), // 占位，发布按钮跳转独立页面
      const MessagePage(),
      ProfilePage(key: _profileKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '首页',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: '搜索',
        ),
        BottomNavigationBarItem(
          icon: Container(
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: '消息',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我',
        ),
      ],
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // 发布按钮，使用 go_router 跳转
      AppRouter.goPublish();
      return;
    }
    
    // 切换到"我的"页面时，刷新数据
    if (index == 4 && _currentIndex != 4) {
      _profileKey.currentState?.refreshData();
    }
    
    setState(() => _currentIndex = index);
  }
}
