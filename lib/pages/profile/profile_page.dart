import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/api/auth_api.dart';
import 'package:frame/api/user_api.dart';
import 'package:frame/api/note_api.dart';
import 'package:frame/models/user.dart';
import 'package:frame/models/note.dart';
import 'package:frame/components/loading.dart';
import 'package:frame/components/note_card.dart';
import 'package:frame/router/router.dart';

/// 个人主页
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfileModel? _profile;
  List<NoteItemModel> _notes = [];
  bool _isLoading = true;
  bool _isLoadingNotes = false;
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();

    // 监听笔记列表刷新信号
    _refreshWorker = ever(AppStore.to.noteListRefresh, (_) {
      _loadNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshWorker?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // 先加载用户信息
    await _loadUserProfile();
    // 再加载笔记列表
    if (_profile?.userId != null) {
      await _loadNotes();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserApi.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadNotes() async {
    if (_profile?.userId == null) return;

    setState(() => _isLoadingNotes = true);
    try {
      final response = await NoteApi.getPublishedList(userId: _profile!.userId);
      if (mounted && response != null) {
        setState(() {
          _notes = response.notes ?? [];
          _isLoadingNotes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingNotes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildStats(),
                  _buildTabs(),
                ],
              ),
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
        child: Column(
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
              backgroundImage: _profile?.avatar != null
                  ? NetworkImage(_profile!.avatar!)
                  : null,
              child: _profile?.avatar == null
                  ? Text(
                      _profile?.nickname?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(_profile?.nickname ?? '用户', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              '小哈书号: ${_profile?.xiaohashuId ?? '未设置'}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
            Text(
              _profile?.introduction ?? '点击添加简介',
              style: AppTextStyles.hint,
            ),
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
        ),
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
            _buildStatItem(_profile?.followingTotal ?? '0', '关注'),
            _buildStatItem(_profile?.fansTotal ?? '0', '粉丝'),
            _buildStatItem(_profile?.likeAndCollectTotal ?? '0', '获赞与收藏'),
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
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.text,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '笔记'),
              Tab(text: '收藏'),
              Tab(text: '赞过'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotesGrid(),
                _buildEmptyState('还没有收藏'),
                _buildEmptyState('还没有赞过'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    if (_isLoadingNotes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return _buildEmptyState('还没有笔记');
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: _notes[index],
            onTap: () => AppRouter.goNoteDetail(_notes[index].noteId),
          );
        },
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
    Loading.show(message: '退出中...');
    try {
      await AuthApi.logout();
    } catch (_) {
      // 忽略接口错误，继续清除本地状态
    }
    await AppStore.to.logout();
    Loading.hide();
  }
}
