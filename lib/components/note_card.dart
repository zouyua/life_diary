import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frame/models/note.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/video_thumbnail.dart';

/// 笔记卡片组件（瀑布流）
class NoteCard extends StatelessWidget {
  final NoteItemModel note;
  final VoidCallback? onTap;
  final bool showTopBadge; // 是否显示置顶标签

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.showTopBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCover(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: _buildCoverContent(),
        ),
        // 置顶标签
        if (showTopBadge && note.isTop == true)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.push_pin, size: 12, color: Colors.white),
                  SizedBox(width: 2),
                  Text('置顶', style: TextStyle(fontSize: 10, color: Colors.white)),
                ],
              ),
            ),
          ),
        // 视频标签
        if (note.isVideo)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 14, color: Colors.white),
                  Text('视频', style: TextStyle(fontSize: 10, color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.image, size: 40, color: AppColors.textHint),
      ),
    );
  }

  /// 构建封面内容
  Widget _buildCoverContent() {
    // 有 cover 图片，直接显示
    if (note.cover != null) {
      return CachedNetworkImage(
        imageUrl: note.cover!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, _) => _buildPlaceholder(),
        errorWidget: (_, _, _) => _buildPlaceholder(),
      );
    }
    
    // 视频类型且有 videoUri，显示视频第一帧
    if (note.isVideo && note.videoUri != null) {
      return VideoThumbnail(
        videoUrl: note.videoUri!,
        height: 150,
      );
    }
    
    // 默认占位图
    return _buildPlaceholder();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 20,
      height: 20,
      color: Colors.grey[300],
      child: Icon(Icons.person, size: 14, color: Colors.grey[600]),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.title != null && note.title!.isNotEmpty)
            Text(
              note.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipOval(
                child: note.avatar != null
                    ? CachedNetworkImage(
                        imageUrl: note.avatar!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _buildDefaultAvatar(),
                        placeholder: (_, _) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  note.nickname ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Icon(
                note.isLiked == true ? Icons.favorite : Icons.favorite_border,
                size: 14,
                color: note.isLiked == true ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 2),
              Text(
                '${note.likeTotal ?? 0}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
