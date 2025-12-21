import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/api/user_api.dart';
import 'package:frame/api/note_api.dart';
import 'package:frame/api/relation_api.dart';
import 'package:frame/models/user.dart';
import 'package:frame/models/note.dart';
import 'package:frame/components/note_card.dart';
import 'package:frame/router/router.dart';

/// 用户主页（查看他人）
class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfileModel? _profile;
  List<NoteItemModel> _notes = [];
  bool _isLoading = true;
  bool _isLoadingNotes = false;
  bool _isFollowed = false; // 是否已关注

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadUserProfile();
    if (_profile != null) {
      await _loadNotes();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserApi.getUserProfile(userId: widget.userId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isFollowed = profile?.isFollowed ?? false; // 使用 API 返回的关注状态
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
    setState(() => _isLoadingNotes = true);
    try {
      final response = await NoteApi.getPublishedList(userId: widget.userId);
      if (mounted) {
        setState(() {
          _notes = response?.notes ?? [];
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
                  _buildAppBar(),
                  _buildHeader(),
                  _buildStats(),
                  _buildTabs(),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFFFE4E1),
      foregroundColor: Colors.black,
      title: Text(_profile?.nickname ?? '用户主页'),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左边：头像
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
                const SizedBox(width: 16),
                // 中间：用户信息
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_profile?.nickname ?? '用户', style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(
                        '小哈书号: ${_profile?.xiaohashuId ?? '未设置'}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                // 右边：关注按钮
                OutlinedButton(
                  onPressed: _toggleFollow,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: _isFollowed ? AppColors.primary : null,
                    foregroundColor: _isFollowed ? Colors.white : null,
                  ),
                  child: Text(_isFollowed ? '已关注' : '关注'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 性别和年龄单独一行
            Row(
              children: [
                Icon(
                  _profile?.sex == 1 ? Icons.male : Icons.female,
                  size: 16,
                  color: _profile?.sex == 1 ? Colors.blue : Colors.pink,
                ),
                const SizedBox(width: 4),
                Text(
                  _profile?.age != null ? '${_profile!.age}岁' : '未设置',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 简介单独一行
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _profile?.introduction ?? '这个人很懒，什么都没写',
                style: AppTextStyles.hint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
            _buildStatItem(
              _profile?.followingTotal ?? '0',
              '关注',
              onTap: () => AppRouter.goFollowingList(widget.userId),
            ),
            _buildStatItem(
              _profile?.fansTotal ?? '0',
              '粉丝',
              onTap: () => AppRouter.goFansList(widget.userId),
            ),
            _buildStatItem(_profile?.likeAndCollectTotal ?? '0', '获赞与收藏'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(count, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
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
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotesGrid(),
                _buildEmptyState('暂无收藏'),
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
      return _buildEmptyState('暂无笔记');
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

  /// 关注/取消关注
  Future<void> _toggleFollow() async {
    try {
      if (_isFollowed) {
        await RelationApi.unfollow(widget.userId);
        setState(() => _isFollowed = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消关注')),
          );
        }
      } else {
        await RelationApi.follow(widget.userId);
        setState(() => _isFollowed = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('关注成功')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}
