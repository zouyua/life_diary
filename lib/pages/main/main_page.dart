import 'package:flutter/material.dart';
import 'package:frame/pages/home/home_page.dart';
import 'package:frame/pages/search/search_page.dart';
import 'package:frame/pages/publish/publish_page.dart';
import 'package:frame/pages/message/message_page.dart';
import 'package:frame/pages/profile/profile_page.dart';
import 'package:frame/theme/theme.dart';

/// 主页面（底部导航）
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    PublishPage(),
    MessagePage(),
    ProfilePage(),
  ];

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
      // 发布按钮，跳转发布页
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PublishPage()),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }
}
