/// 一级评论
class CommentModel {
  final int commentId;
  final int? userId;
  final String? avatar;
  final String? nickname;
  final String? content;
  final String? imageUrl;
  final String? createTime;
  int? likeTotal; // 改为可变，支持点赞计数更新
  final double? heat;
  final int? childCommentTotal;
  final ChildCommentModel? firstReplyComment;
  bool isLiked;

  CommentModel({
    required this.commentId,
    this.userId,
    this.avatar,
    this.nickname,
    this.content,
    this.imageUrl,
    this.createTime,
    this.likeTotal,
    this.heat,
    this.childCommentTotal,
    this.firstReplyComment,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        commentId: json['commentId'] as int,
        userId: json['userId'] as int?,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        content: json['content'] as String?,
        imageUrl: json['imageUrl'] as String?,
        createTime: json['createTime'] as String?,
        likeTotal: json['likeTotal'] as int?,
        heat: (json['heat'] as num?)?.toDouble(),
        childCommentTotal: json['childCommentTotal'] as int?,
        firstReplyComment: json['firstReplyComment'] != null
            ? ChildCommentModel.fromJson(json['firstReplyComment'])
            : null,
        isLiked: json['isLiked'] as bool? ?? false,
      );

  bool get hasChildComments => (childCommentTotal ?? 0) > 0;
}

/// 二级评论（子评论）
class ChildCommentModel {
  final int commentId;
  final int? userId;
  final String? avatar;
  final String? nickname;
  final String? content;
  final String? imageUrl;
  final String? createTime;
  int? likeTotal; // 改为可变，支持点赞计数更新
  final String? replyUserName;
  final int? replyUserId;
  bool isLiked;

  ChildCommentModel({
    required this.commentId,
    this.userId,
    this.avatar,
    this.nickname,
    this.content,
    this.imageUrl,
    this.createTime,
    this.likeTotal,
    this.replyUserName,
    this.replyUserId,
    this.isLiked = false,
  });

  factory ChildCommentModel.fromJson(Map<String, dynamic> json) =>
      ChildCommentModel(
        commentId: json['commentId'] as int,
        userId: json['userId'] as int?,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        content: json['content'] as String?,
        imageUrl: json['imageUrl'] as String?,
        createTime: json['createTime'] as String?,
        likeTotal: json['likeTotal'] as int?,
        replyUserName: json['replyUserName'] as String?,
        replyUserId: json['replyUserId'] as int?,
        isLiked: json['isLiked'] as bool? ?? false,
      );

  bool get isReply => replyUserId != null;
}
