import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/models/note.dart';
import 'package:frame/api/note_api.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/router/router.dart';

/// 笔记详情页
class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  NoteDetailModel? _note;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isCollected = false;
  int _likeCount = 0;
  int _collectCount = 0;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNoteDetail();
  }

  Future<void> _loadNoteDetail() async {
    try {
      final note = await NoteApi.getDetail(widget.noteId);
      if (mounted && note != null) {
        // 获取点赞收藏状态
        final status = await NoteApi.getLikeCollectStatus(widget.noteId);
        setState(() {
          _note = note;
          _isLoading = false;
          _likeCount = note.likeTotal ?? 0;
          _collectCount = note.collectTotal ?? 0;
          _commentCount = note.commentTotal ?? 0;
          if (status != null) {
            _isLiked = status.isLiked;
            _isCollected = status.isCollected;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('笔记不存在')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildImages()),
          SliverToBoxAdapter(child: _buildContent()),
          SliverToBoxAdapter(child: _buildCommentSection()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            backgroundImage:
                _note?.avatar != null ? NetworkImage(_note!.avatar!) : null,
            child: _note?.avatar == null
                ? Text(
                    _note?.creatorName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _note?.creatorName ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 28),
            ),
            child: const Text('关注', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: _shareNote),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: _showMoreActions),
      ],
    );
  }

  Widget _buildImages() {
    final images = _note?.imgUris ?? [];
    if (images.isEmpty) {
      // 视频笔记显示视频封面
      if (_note?.videoUri != null) {
        return Container(
          height: 300,
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 400,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.background,
              child: const Center(child: Icon(Icons.image, size: 48)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_note?.title != null && _note!.title!.isNotEmpty)
            Text(
              _note!.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 12),
          if (_note?.content != null && _note!.content!.isNotEmpty)
            Text(
              _note!.content!,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          const SizedBox(height: 12),
          if (_note?.topicName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#${_note!.topicName}',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          const SizedBox(height: 8),
          if (_note?.updateTime != null)
            Text(
              '编辑于 ${_note!.updateTime}',
              style: AppTextStyles.caption,
            ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '评论 $_commentCount',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('暂无评论', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.textHint),
                    SizedBox(width: 8),
                    Text('说点什么...',
                        style: TextStyle(color: AppColors.textHint)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
              label: '$_likeCount',
              isActive: _isLiked,
              onTap: _toggleLike,
            ),
            _buildActionButton(
              icon: _isCollected ? Icons.star : Icons.star_border,
              label: '$_collectCount',
              isActive: _isCollected,
              onTap: _toggleCollect,
            ),
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: '$_commentCount',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    try {
      if (_isLiked) {
        await NoteApi.unlike(widget.noteId);
        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        await NoteApi.like(widget.noteId);
        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  Future<void> _toggleCollect() async {
    try {
      if (_isCollected) {
        await NoteApi.uncollect(widget.noteId);
        setState(() {
          _isCollected = false;
          _collectCount--;
        });
      } else {
        await NoteApi.collect(widget.noteId);
        setState(() {
          _isCollected = true;
          _collectCount++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 判断是否是自己的笔记
  bool get _isMyNote {
    final currentUserId = AppStore.to.user?.id;
    final creatorId = _note?.creatorId;
    return currentUserId != null && 
           currentUserId.isNotEmpty && 
           creatorId != null && 
           creatorId == currentUserId;
  }

  /// 分享笔记
  void _shareNote() {
    // 复制链接到剪贴板
    final link = 'https://xiaohashu.com/note/${widget.noteId}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('链接已复制到剪贴板')),
    );
  }

  /// 显示更多操作
  void _showMoreActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionSheet(),
    );
  }

  Widget _buildActionSheet() {
    final isPrivate = _note?.isPrivate ?? false;
    final isTop = _note?.isTop ?? false;

    final actions = <_ActionItem>[];
    if (_isMyNote) {
      actions.add(_ActionItem(icon: Icons.edit_outlined, label: '编辑', onTap: _editNote));
      actions.add(_ActionItem(icon: Icons.delete_outline, label: '删除', onTap: _deleteNote));
      // 仅我可见/取消仅我可见
      actions.add(_ActionItem(
        icon: isPrivate ? Icons.visibility : Icons.visibility_off_outlined,
        label: isPrivate ? '取消仅我可见' : '设为私密',
        onTap: _setOnlyMe,
      ));
      // 置顶/取消置顶
      actions.add(_ActionItem(
        icon: isTop ? Icons.push_pin : Icons.push_pin_outlined,
        label: isTop ? '取消置顶' : '置顶',
        onTap: _toggleTop,
      ));
      actions.add(_ActionItem(icon: Icons.link, label: '复制链接', onTap: _copyLink));
    } else {
      actions.add(_ActionItem(icon: Icons.link, label: '复制链接', onTap: _copyLink));
    }

    return Container(
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
            const SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: actions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      action.onTap();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(action.icon, color: AppColors.text),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('取消', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑笔记
  void _editNote() {
    if (_note != null) {
      AppRouter.goEditNote(_note!);
    }
  }

  /// 删除笔记
  void _deleteNote() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这篇笔记吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await NoteApi.delete(widget.noteId);
                // 触发列表刷新
                AppStore.to.refreshNoteList();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                }
                // 返回首页
                AppRouter.goHome();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 设置仅我可见
  Future<void> _setOnlyMe() async {
    try {
      await NoteApi.setOnlyMe(widget.noteId);
      // 触发列表刷新
      AppStore.to.refreshNoteList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已设置为仅自己可见')),
        );
        // 重新加载详情
        _loadNoteDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 置顶/取消置顶
  Future<void> _toggleTop() async {
    final isTop = _note?.isTop ?? false;
    try {
      await NoteApi.setTop(widget.noteId, !isTop);
      // 触发列表刷新
      AppStore.to.refreshNoteList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isTop ? '已取消置顶' : '已置顶')),
        );
        // 重新加载详情
        _loadNoteDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 复制链接
  void _copyLink() {
    final link = 'https://xiaohashu.com/note/${widget.noteId}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('链接已复制到剪贴板')),
    );
  }
}

/// 操作项
class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ActionItem({required this.icon, required this.label, required this.onTap});
}
