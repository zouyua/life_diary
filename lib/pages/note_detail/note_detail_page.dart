import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/models/note.dart';
import 'package:frame/models/comment.dart';
import 'package:frame/api/note_api.dart';
import 'package:frame/api/comment_api.dart';
import 'package:frame/api/relation_api.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/router/router.dart';
import 'package:frame/pages/note_detail/comment_input_sheet.dart';
import 'package:frame/pages/note_detail/child_comments_sheet.dart';
import 'package:frame/components/video_player_widget.dart';

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
  bool _isFollowed = false;
  int _likeCount = 0;
  int _collectCount = 0;
  int _commentCount = 0;

  // 评论相关
  List<CommentModel> _comments = [];
  bool _isLoadingComments = false;
  bool _hasMoreComments = true;
  int _commentPageNo = 1;
  final TextEditingController _commentController = TextEditingController();
  int? _replyToCommentId; // 回复的评论ID
  String? _replyToNickname; // 回复的用户昵称

  @override
  void initState() {
    super.initState();
    _loadNoteDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
          _isFollowed = note.isFollowed ?? false;
          if (status != null) {
            _isLiked = status.isLiked;
            _isCollected = status.isCollected;
          }
        });
        // 加载评论
        _loadComments();
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

  Future<void> _loadComments({bool loadMore = false}) async {
    if (_isLoadingComments) return;
    if (loadMore && !_hasMoreComments) return;

    setState(() => _isLoadingComments = true);

    try {
      final response = await CommentApi.getList(
        noteId: widget.noteId,
        pageNo: loadMore ? _commentPageNo : 1,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _comments.addAll(response.list);
          } else {
            _comments = response.list;
          }
          _hasMoreComments = response.hasMore;
          if (response.list.isNotEmpty) {
            _commentPageNo = response.page + 1;
          }
          // 更新评论总数
          _commentCount = response.total;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingComments = false);
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
      title: GestureDetector(
        onTap: _goUserProfile,
        child: Row(
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
              onPressed: _isMyNote ? null : _toggleFollow,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 28),
                backgroundColor: _isFollowed ? AppColors.primary : null,
                foregroundColor: _isFollowed ? Colors.white : null,
              ),
              child: Text(
                _isFollowed ? '已关注' : '关注',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: _shareNote),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: _showMoreActions),
      ],
    );
  }

  void _goUserProfile() {
    final creatorId = _note?.creatorId;
    if (creatorId != null) {
      final userId = int.tryParse(creatorId);
      if (userId != null) {
        AppRouter.goUserProfile(userId);
      }
    }
  }

  Future<void> _toggleFollow() async {
    final creatorId = _note?.creatorId;
    if (creatorId == null) return;
    
    final userId = int.tryParse(creatorId);
    if (userId == null) return;

    try {
      if (_isFollowed) {
        await RelationApi.unfollow(userId);
        setState(() => _isFollowed = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消关注')),
          );
        }
      } else {
        await RelationApi.follow(userId);
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

  Widget _buildImages() {
    final images = _note?.imgUris ?? [];
    
    // 视频类型
    if (_note?.isVideo == true && _note?.videoUri != null) {
      return VideoPlayerWidget(
        videoUrl: _note!.videoUri!,
        autoPlay: false,
      );
    }
    
    // 图文类型
    if (images.isEmpty) {
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
          if (_isLoadingComments && _comments.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('暂无评论，快来抢沙发吧~', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length + (_hasMoreComments ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _comments.length) {
                  return TextButton(
                    onPressed: () => _loadComments(loadMore: true),
                    child: _isLoadingComments
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('加载更多评论'),
                  );
                }
                return _buildCommentItem(_comments[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (comment.userId != null) {
                AppRouter.goUserProfile(comment.userId!);
              }
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              backgroundImage: comment.avatar != null
                  ? NetworkImage(comment.avatar!)
                  : null,
              child: comment.avatar == null
                  ? Text(
                      comment.nickname?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (comment.content != null && comment.content!.isNotEmpty)
                  Text(
                    comment.content!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                if (comment.imageUrl != null && 
                    comment.imageUrl!.isNotEmpty &&
                    comment.imageUrl!.startsWith('http'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        comment.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      comment.createTime ?? '',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _setReplyTo(comment.commentId, comment.nickname),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.chat_bubble_outline,
                            size: 16, color: AppColors.textHint),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _toggleCommentLike(comment),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? AppColors.primary : AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeTotal ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: comment.isLiked ? AppColors.primary : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 显示子评论预览
                if (comment.hasChildComments) ...[
                  const SizedBox(height: 8),
                  _buildChildCommentPreview(comment),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCommentPreview(CommentModel comment) {
    final firstReply = comment.firstReplyComment;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (firstReply != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: '${firstReply.nickname}: ',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: firstReply.content ?? ''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _setReplyTo(firstReply.commentId, firstReply.nickname),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.chat_bubble_outline,
                        size: 14, color: AppColors.textHint),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleFirstReplyLike(comment, firstReply),
                  child: Row(
                    children: [
                      Icon(
                        firstReply.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: firstReply.isLiked ? AppColors.primary : AppColors.textHint,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${firstReply.likeTotal ?? 0}',
                        style: TextStyle(
                          fontSize: 11,
                          color: firstReply.isLiked ? AppColors.primary : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            onTap: () => _showChildComments(comment),
            child: Text(
              '共${comment.childCommentTotal}条回复 >',
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFirstReplyLike(CommentModel parent, ChildCommentModel firstReply) async {
    try {
      if (firstReply.isLiked) {
        await CommentApi.unlike(firstReply.commentId);
        setState(() {
          firstReply.isLiked = false;
          firstReply.likeTotal = (firstReply.likeTotal ?? 1) - 1;
        });
      } else {
        await CommentApi.like(firstReply.commentId);
        setState(() {
          firstReply.isLiked = true;
          firstReply.likeTotal = (firstReply.likeTotal ?? 0) + 1;
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


  void _showChildComments(CommentModel parentComment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChildCommentsSheet(
        parentComment: parentComment,
        onReply: (commentId, nickname) {
          Navigator.pop(context);
          _setReplyTo(commentId, nickname);
        },
      ),
    );
  }

  void _setReplyTo(int commentId, String? nickname) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToNickname = nickname;
    });
    // 聚焦输入框
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _clearReplyTo() {
    setState(() {
      _replyToCommentId = null;
      _replyToNickname = null;
    });
  }

  Future<void> _toggleCommentLike(CommentModel comment) async {
    try {
      if (comment.isLiked) {
        await CommentApi.unlike(comment.commentId);
        setState(() {
          comment.isLiked = false;
          comment.likeTotal = (comment.likeTotal ?? 1) - 1;
        });
      } else {
        await CommentApi.like(comment.commentId);
        setState(() {
          comment.isLiked = true;
          comment.likeTotal = (comment.likeTotal ?? 0) + 1;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyToNickname != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      '回复 $_replyToNickname',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clearReplyTo,
                      child: const Icon(Icons.close, size: 16, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showCommentInput,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.textHint),
                          const SizedBox(width: 8),
                          Text(
                            _replyToNickname != null ? '回复 $_replyToNickname' : '说点什么...',
                            style: const TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
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
                  onTap: _showCommentInput,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentInput() {
    final replyNickname = _replyToNickname;
    final replyCommentId = _replyToCommentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CommentInputSheet(
        replyNickname: replyNickname,
        replyCommentId: replyCommentId,
        onSubmit: (content, imageUrl) async {
          await _submitComment(content, imageUrl, replyCommentId);
        },
        onClearReply: _clearReplyTo,
      ),
    );
  }

  Future<void> _submitComment(String content, String? imageUrl, int? replyCommentId) async {
    if (content.isEmpty && imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入评论内容或选择图片')),
      );
      return;
    }

    try {
      await CommentApi.publish(
        noteId: widget.noteId,
        content: content.isNotEmpty ? content : null,
        imageUrl: imageUrl,
        replyCommentId: replyCommentId,
      );

      _commentController.clear();
      _clearReplyTo();

      // 刷新评论列表
      _commentPageNo = 1;
      _hasMoreComments = true;
      await _loadComments();

      setState(() {
        _commentCount++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('评论成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('评论失败: $e')),
        );
      }
    }
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

  bool get _isMyNote {
    final currentUserId = AppStore.to.user?.id;
    final creatorId = _note?.creatorId;
    return currentUserId != null && 
           currentUserId.isNotEmpty && 
           creatorId != null && 
           creatorId == currentUserId;
  }

  void _shareNote() {
    final link = 'https://xiaohashu.com/note/${widget.noteId}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('链接已复制到剪贴板')),
    );
  }

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
      actions.add(_ActionItem(
        icon: isPrivate ? Icons.visibility : Icons.visibility_off_outlined,
        label: isPrivate ? '取消仅我可见' : '设为私密',
        onTap: _setOnlyMe,
      ));
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

  void _editNote() {
    if (_note != null) {
      AppRouter.goEditNote(_note!);
    }
  }

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
                AppStore.to.refreshNoteList();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                }
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

  Future<void> _setOnlyMe() async {
    try {
      await NoteApi.setOnlyMe(widget.noteId);
      AppStore.to.refreshNoteList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已设置为仅自己可见')),
        );
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

  Future<void> _toggleTop() async {
    final isTop = _note?.isTop ?? false;
    try {
      await NoteApi.setTop(widget.noteId, !isTop);
      AppStore.to.refreshNoteList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isTop ? '已取消置顶' : '已置顶')),
        );
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

  void _copyLink() {
    final link = 'https://xiaohashu.com/note/${widget.noteId}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('链接已复制到剪贴板')),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ActionItem({required this.icon, required this.label, required this.onTap});
}
