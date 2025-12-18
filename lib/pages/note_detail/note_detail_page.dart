import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/models/note.dart';

/// 笔记详情页
class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _isLiked = false;
  bool _isCollected = false;
  int _likeCount = 1234;
  int _collectCount = 567;
  int _commentCount = 89;

  // 模拟数据
  final NoteDetailModel _note = NoteDetailModel(
    id: 1,
    type: 0,
    title: '今日分享：超美的风景照片',
    content: '今天去了一个超级美的地方，风景真的太棒了！\n\n'
        '推荐大家有时间也去看看，绝对不会后悔的。\n\n'
        '这里的空气特别清新，远离城市的喧嚣，让人心旷神怡。',
    imgUris: [
      'https://picsum.photos/400/500?random=1',
      'https://picsum.photos/400/500?random=2',
      'https://picsum.photos/400/500?random=3',
    ],
    topicName: '旅行日记',
    creatorId: 1,
    creatorName: '小红薯用户',
    avatar: 'https://picsum.photos/50/50?random=1',
    updateTime: '2024-01-15',
  );

  @override
  Widget build(BuildContext context) {
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
            backgroundImage: _note.avatar != null
                ? NetworkImage(_note.avatar!)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _note.creatorName ?? '',
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
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
      ],
    );
  }

  Widget _buildImages() {
    final images = _note.imgUris ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

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
          if (_note.title != null)
            Text(
              _note.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _note.content ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          if (_note.topicName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#${_note.topicName}',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '编辑于 ${_note.updateTime}',
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
              color: Colors.black.withOpacity(0.05),
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
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textHint),
                    SizedBox(width: 8),
                    Text('说点什么...', style: TextStyle(color: AppColors.textHint)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
              label: '$_likeCount',
              isActive: _isLiked,
              onTap: () => setState(() {
                _isLiked = !_isLiked;
                _likeCount += _isLiked ? 1 : -1;
              }),
            ),
            _buildActionButton(
              icon: _isCollected ? Icons.star : Icons.star_border,
              label: '$_collectCount',
              isActive: _isCollected,
              onTap: () => setState(() {
                _isCollected = !_isCollected;
                _collectCount += _isCollected ? 1 : -1;
              }),
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
}
