import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frame/models/note.dart';
import 'package:frame/theme/theme.dart';

/// 笔记卡片组件（瀑布流）
class NoteCard extends StatelessWidget {
  final NoteItemModel note;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
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
              color: Colors.black.withOpacity(0.05),
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
          child: note.cover != null
              ? CachedNetworkImage(
                  imageUrl: note.cover!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => _buildPlaceholder(),
                  errorWidget: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
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
                        errorWidget: (_, __, ___) => _buildDefaultAvatar(),
                        placeholder: (_, __) => _buildDefaultAvatar(),
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
                note.likeTotal ?? '0',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
