import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/api/search_api.dart';
import 'package:frame/models/search.dart';
import 'package:frame/router/router.dart';

/// 搜索页
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _keyword = '';
  bool _isSearching = false;

  // 笔记搜索结果
  List<SearchNoteModel> _notes = [];
  bool _isLoadingNotes = false;
  bool _hasMoreNotes = true;
  int _notePageNo = 1;

  // 用户搜索结果
  List<SearchUserModel> _users = [];
  bool _isLoadingUsers = false;
  bool _hasMoreUsers = true;
  int _userPageNo = 1;

  // 筛选条件
  int? _noteType; // null: 综合, 0: 图文, 1: 视频
  int? _sortType; // null: 不限, 0: 最新, 1: 最多点赞, 2: 最多评论, 3: 最多收藏

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // 切换 tab 时，如果有关键词且当前 tab 没有数据，则搜索
    if (_keyword.isNotEmpty) {
      if (_tabController.index == 0 && _notes.isEmpty) {
        _searchNotes();
      } else if (_tabController.index == 1 && _users.isEmpty) {
        _searchUsers();
      }
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _keyword = keyword;
      _isSearching = true;
      // 重置分页
      _notes.clear();
      _notePageNo = 1;
      _hasMoreNotes = true;
      _users.clear();
      _userPageNo = 1;
      _hasMoreUsers = true;
    });

    // 根据当前 tab 搜索
    if (_tabController.index == 0) {
      _searchNotes();
    } else {
      _searchUsers();
    }
  }

  Future<void> _searchNotes({bool loadMore = false}) async {
    if (_isLoadingNotes) return;
    if (loadMore && !_hasMoreNotes) return;

    setState(() => _isLoadingNotes = true);

    try {
      final response = await SearchApi.searchNote(
        keyword: _keyword,
        pageNo: loadMore ? _notePageNo : 1,
        type: _noteType,
        sort: _sortType,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _notes.addAll(response.list);
          } else {
            _notes = response.list;
          }
          _hasMoreNotes = response.hasMore;
          if (response.list.isNotEmpty) {
            _notePageNo = response.page + 1;
          }
          _isLoadingNotes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingNotes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers({bool loadMore = false}) async {
    if (_isLoadingUsers) return;
    if (loadMore && !_hasMoreUsers) return;

    setState(() => _isLoadingUsers = true);

    try {
      final response = await SearchApi.searchUser(
        keyword: _keyword,
        pageNo: loadMore ? _userPageNo : 1,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _users.addAll(response.list);
          } else {
            _users = response.list;
          }
          _hasMoreUsers = response.hasMore;
          if (response.list.isNotEmpty) {
            _userPageNo = response.page + 1;
          }
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchBar(),
        actions: [
          TextButton(
            onPressed: _onSearch,
            child: const Text('搜索'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) _buildTabs(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _onSearch(),
        decoration: const InputDecoration(
          hintText: '搜索笔记、用户',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.text,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: '笔记'),
          Tab(text: '用户'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_isSearching) {
      return _buildSearchHint();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNoteList(),
        _buildUserList(),
      ],
    );
  }

  Widget _buildSearchHint() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('搜索笔记或用户', style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildNoteList() {
    if (_isLoadingNotes && _notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return const Center(
        child: Text('暂无搜索结果', style: TextStyle(color: AppColors.textHint)),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100) {
          _searchNotes(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _notes.length + (_hasMoreNotes ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildNoteItem(_notes[index]);
        },
      ),
    );
  }

  Widget _buildNoteItem(SearchNoteModel note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => AppRouter.goNoteDetail(note.noteId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: note.cover != null
                    ? Image.network(
                        note.cover!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.background,
                          child: const Icon(Icons.image),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: AppColors.background,
                        child: const Icon(Icons.image),
                      ),
              ),
              const SizedBox(width: 12),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: note.avatar != null
                              ? NetworkImage(note.avatar!)
                              : null,
                          child: note.avatar == null
                              ? const Icon(Icons.person, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            note.nickname ?? '',
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Text(note.likeTotal ?? '0', style: AppTextStyles.caption),
                        const SizedBox(width: 12),
                        const Icon(Icons.chat_bubble_outline,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Text(note.commentTotal ?? '0',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (_isLoadingUsers && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('暂无搜索结果', style: TextStyle(color: AppColors.textHint)),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100) {
          _searchUsers(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _users.length + (_hasMoreUsers ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildUserItem(_users[index]);
        },
      ),
    );
  }

  Widget _buildUserItem(SearchUserModel user) {
    return ListTile(
      onTap: () => AppRouter.goUserProfile(user.userId),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary,
        backgroundImage:
            user.avatar != null ? NetworkImage(user.avatar!) : null,
        child: user.avatar == null
            ? Text(
                user.nickname?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(user.nickname ?? ''),
      subtitle: Text(
        '${user.fansTotal ?? 0} 粉丝 · ${user.noteTotal ?? 0} 笔记',
        style: AppTextStyles.caption,
      ),
      trailing: OutlinedButton(
        onPressed: () => AppRouter.goUserProfile(user.userId),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 32),
        ),
        child: const Text('查看', style: TextStyle(fontSize: 12)),
      ),
    );
  }
}
