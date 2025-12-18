import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';

/// 搜索页
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('搜索页 - 待实现'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: '搜索笔记、用户',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
