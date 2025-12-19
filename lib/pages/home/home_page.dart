import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frame/components/note_card.dart';
import 'package:frame/models/note.dart';
import 'package:frame/router/router.dart';
import 'package:frame/api/note_api.dart';

/// 首页 - 瀑布流笔记列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['推荐', '关注', '附近', '视频'];

  List<NoteItemModel> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await NoteApi.getHomeList();
      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return const Center(child: Text('暂无笔记'));
    }

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
    await _loadNotes();
  }

  void _onNoteTap(NoteItemModel note) {
    AppRouter.goNoteDetail(note.noteId);
  }
}
