import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/note_card.dart';
import 'package:frame/models/note.dart';
import 'package:frame/router/router.dart';

/// 首页 - 瀑布流笔记列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['推荐', '关注', '附近', '视频'];

  // 模拟数据
  final List<NoteItemModel> _notes = List.generate(
    20,
    (i) => NoteItemModel(
      noteId: i,
      type: i % 3 == 0 ? 1 : 0,
      cover: 'https://picsum.photos/200/${250 + (i % 5) * 50}?random=$i',
      title: i % 2 == 0 
          ? '这是第 ${i + 1} 篇笔记的标题，可能会很长很长' 
          : '短标题 ${i + 1}',
      creatorId: i,
      nickname: '用户${i + 1}',
      avatar: 'https://picsum.photos/50/50?random=$i',
      likeTotal: '${(i + 1) * 100}',
      isLiked: i % 2 == 0,
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildWaterfallGrid(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        indicatorSize: TabBarIndicatorSize.label,
        tabAlignment: TabAlignment.start,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildWaterfallGrid() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            return NoteCard(
              note: _notes[index],
              onTap: () => _onNoteTap(_notes[index]),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void _onNoteTap(NoteItemModel note) {
    AppRouter.goNoteDetail(note.noteId);
  }
}
