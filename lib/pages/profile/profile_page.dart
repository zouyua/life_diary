import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/api/auth_api.dart';
import 'package:frame/api/user_api.dart';
import 'package:frame/api/note_api.dart';
import 'package:frame/models/user.dart';
import 'package:frame/components/loading.dart';
import 'package:frame/components/note_grid.dart';
import 'package:frame/router/router.dart';

/// 个人主页
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfileModel? _profile;
  bool _isLoading = true;

  // 三个 Tab 的 Key，用于刷新
  final _publishedKey = GlobalKey<NoteGridState>();
  final _collectedKey = GlobalKey<NoteGridState>();
  final _likedKey = GlobalKey<NoteGridState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 外部调用刷新数据
  void refreshData() {
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserProfile();
    // 刷新当前 Tab 的笔记列表
    _refreshCurrentTab();
  }
  
  /// 刷新当前选中的 Tab
  void _refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _publishedKey.currentState?.refresh();
        break;
      case 1:
        _collectedKey.currentState?.refresh();
        break;
      case 2:
        _likedKey.currentState?.refresh();
        break;
    }
  }
  
  /// 刷新所有 Tab
  void refreshAllTabs() {
    _publishedKey.currentState?.refresh();
    _collectedKey.currentState?.refresh();
    _likedKey.currentState?.refresh();
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
                  onPressed: _showSettingsMenu,
                ),
              ],
            ),
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
                // 右边：用户信息
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
              ],
            ),
            const SizedBox(height: 12),
            // 性别和年龄单独一行（点击进入编辑资料）
            GestureDetector(
              onTap: _editProfile,
              child: Row(
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
            ),
            const SizedBox(height: 8),
            // 简介单独一行（点击编辑简介）
            GestureDetector(
              onTap: _showEditIntroductionDialog,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _profile?.introduction ?? '点击添加简介',
                  style: AppTextStyles.hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
              onTap: () {
                if (_profile != null) {
                  AppRouter.goFollowingList(_profile!.userId);
                }
              },
            ),
            _buildStatItem(
              _profile?.fansTotal ?? '0',
              '粉丝',
              onTap: () {
                if (_profile != null) {
                  AppRouter.goFansList(_profile!.userId);
                }
              },
            ),
            _buildStatItem(
              _profile?.likeAndCollectTotal ?? '0',
              '获赞与收藏',
              onTap: _showLikeCollectDialog,
            ),
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
    if (_profile == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    final userId = _profile!.userId;
    
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
                NoteGrid(
                  key: _publishedKey,
                  loader: ({cursor}) => NoteApi.getPublishedList(userId: userId, cursor: cursor),
                  emptyText: '还没有笔记',
                ),
                NoteGrid(
                  key: _collectedKey,
                  loader: ({cursor}) => NoteApi.getCollectedList(userId: userId, cursor: cursor),
                  emptyText: '还没有收藏',
                ),
                NoteGrid(
                  key: _likedKey,
                  loader: ({cursor}) => NoteApi.getLikedList(userId: userId, cursor: cursor),
                  emptyText: '还没有赞过',
                ),
              ],
            ),
          ),
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

  void _editProfile() async {
    if (_profile == null) return;
    final result = await AppRouter.goEditProfile(_profile!);
    // 如果有更新，重新加载用户信息
    if (result == true) {
      _loadUserProfile();
    }
  }

  /// 显示编辑简介弹窗
  void _showEditIntroductionDialog() {
    final controller = TextEditingController(text: _profile?.introduction ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑简介'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: '介绍一下自己吧...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateIntroduction(controller.text);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  /// 更新简介
  Future<void> _updateIntroduction(String introduction) async {
    if (_profile == null) return;
    
    Loading.show(message: '保存中...');
    try {
      await UserApi.updateUserInfo(
        userId: _profile!.userId,
        introduction: introduction,
      );
      Loading.hide();
      // 更新本地状态
      await _loadUserProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('简介已更新')),
        );
      }
    } catch (e) {
      Loading.hide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }

  /// 显示获赞与收藏详情弹窗
  void _showLikeCollectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据统计'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogStatRow(Icons.note_outlined, '发布笔记', _profile?.noteTotal ?? '0'),
            const Divider(),
            _buildDialogStatRow(Icons.favorite_outline, '获得点赞', _profile?.likeTotal ?? '0'),
            const Divider(),
            _buildDialogStatRow(Icons.star_outline, '获得收藏', _profile?.collectTotal ?? '0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppTextStyles.body1)),
          Text(value, style: AppTextStyles.h3),
        ],
      ),
    );
  }

  /// 显示设置菜单
  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('编辑资料'),
                onTap: () {
                  Navigator.pop(context);
                  _editProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('退出登录', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
