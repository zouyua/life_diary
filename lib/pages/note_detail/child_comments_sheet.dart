import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/models/comment.dart';
import 'package:frame/api/comment_api.dart';
import 'package:frame/router/router.dart';

/// 子评论列表弹窗
class ChildCommentsSheet extends StatefulWidget {
  final CommentModel parentComment;
  final Function(int commentId, String? nickname) onReply;

  const ChildCommentsSheet({
    super.key,
    required this.parentComment,
    required this.onReply,
  });

  @override
  State<ChildCommentsSheet> createState() => _ChildCommentsSheetState();
}

class _ChildCommentsSheetState extends State<ChildCommentsSheet> {
  List<ChildCommentModel> _childComments = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _pageNo = 1;

  @override
  void initState() {
    super.initState();
    _loadChildComments();
  }

  Future<void> _loadChildComments({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;

    try {
      final response = await CommentApi.getChildList(
        parentCommentId: widget.parentComment.commentId,
        pageNo: loadMore ? _pageNo : 1,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _childComments.addAll(response.list);
          } else {
            _childComments = response.list;
          }
          _hasMore = response.hasMore;
          if (response.list.isNotEmpty) {
            _pageNo = response.page + 1;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleLike(ChildCommentModel comment) async {
    try {
      if (comment.isLiked) {
        await CommentApi.unlike(comment.commentId);
        setState(() => comment.isLiked = false);
      } else {
        await CommentApi.like(comment.commentId);
        setState(() => comment.isLiked = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${widget.parentComment.childCommentTotal ?? 0}条回复',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _childComments.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _childComments.length) {
                        return TextButton(
                          onPressed: () => _loadChildComments(loadMore: true),
                          child: const Text('加载更多'),
                        );
                      }
                      return _buildChildCommentItem(_childComments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCommentItem(ChildCommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (comment.userId != null) {
                Navigator.pop(context);
                AppRouter.goUserProfile(comment.userId!);
              }
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              backgroundImage:
                  comment.avatar != null ? NetworkImage(comment.avatar!) : null,
              child: comment.avatar == null
                  ? Text(
                      comment.nickname?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.nickname ?? '用户',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      if (comment.isReply) ...[
                        const TextSpan(text: '回复 '),
                        TextSpan(
                          text: '@${comment.replyUserName} ',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                      TextSpan(text: comment.content ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(comment.createTime ?? '', style: AppTextStyles.caption),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          widget.onReply(comment.commentId, comment.nickname),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.chat_bubble_outline,
                            size: 14, color: AppColors.textHint),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _toggleLike(comment),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: comment.isLiked
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeTotal ?? 0}',
                            style: TextStyle(
                              fontSize: 11,
                              color: comment.isLiked
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
