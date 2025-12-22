import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frame/components/note_card.dart';
import 'package:frame/models/note.dart';
import 'package:frame/models/channel.dart';
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
  TabController? _tabController;
  List<ChannelModel> _channels = [];

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  /// 加载频道列表
  Future<void> _loadChannels() async {
    try {
      final channels = await NoteApi.getChannelList();
      if (mounted) {
        // 在频道列表前添加"全部"选项
        final allChannels = [
          ChannelModel(id: 0, name: '全部'),
          ...channels,
        ];
        setState(() {
          _channels = allChannels;
          _tabController =
              TabController(length: allChannels.length, vsync: this);
        });
      }
    } catch (e) {
      if (mounted) {
        // 即使频道加载失败，也显示"全部"选项
        setState(() {
          _channels = [ChannelModel(id: 0, name: '全部')];
          _tabController = TabController(length: 1, vsync: this);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: _tabController == null
          ? const SizedBox.shrink()
          : TabBar(
              controller: _tabController,
              isScrollable: true,
              labelStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 16),
              indicatorSize: TabBarIndicatorSize.label,
              tabAlignment: TabAlignment.start,
              tabs: _channels.map((c) => Tab(text: c.name)).toList(),
            ),
    );
  }

  Widget _buildBody() {
    if (_tabController == null || _channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return TabBarView(
      controller: _tabController,
      children: _channels.map((channel) {
        return _ChannelNoteList(channelId: channel.id);
      }).toList(),
    );
  }
}

/// 单个频道的笔记列表
class _ChannelNoteList extends StatefulWidget {
  final int channelId;

  const _ChannelNoteList({required this.channelId});

  @override
  State<_ChannelNoteList> createState() => _ChannelNoteListState();
}

class _ChannelNoteListState extends State<_ChannelNoteList>
    with AutomaticKeepAliveClientMixin {
  List<NoteItemModel> _notes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final response = await NoteApi.getDiscoverList(
        channelId: widget.channelId,
        pageNo: 1,
      );
      if (mounted) {
        setState(() {
          _notes = response.data;
          _hasMore = response.hasMore;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final response = await NoteApi.getDiscoverList(
        channelId: widget.channelId,
        pageNo: _currentPage + 1,
      );
      if (mounted && response.data.isNotEmpty) {
        setState(() {
          _currentPage++;
          _notes.addAll(response.data);
          _hasMore = response.hasMore;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return const Center(child: Text('暂无笔记'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: _notes.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _notes.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return NoteCard(
                note: _notes[index],
                onTap: () => AppRouter.goNoteDetail(_notes[index].noteId),
              );
            },
          ),
        ),
      ),
    );
  }
}
