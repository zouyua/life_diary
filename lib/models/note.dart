/// 笔记列表项
class NoteItemModel {
  final int noteId;
  final int type; // 0: 图文, 1: 视频
  final String? cover;
  final String? videoUri;
  final String? title;
  final int? creatorId;
  final String? nickname;
  final String? avatar;
  final String? likeTotal;
  final bool? isLiked;

  NoteItemModel({
    required this.noteId,
    required this.type,
    this.cover,
    this.videoUri,
    this.title,
    this.creatorId,
    this.nickname,
    this.avatar,
    this.likeTotal,
    this.isLiked,
  });

  factory NoteItemModel.fromJson(Map<String, dynamic> json) => NoteItemModel(
        noteId: json['noteId'] as int,
        type: json['type'] as int,
        cover: json['cover'] as String?,
        videoUri: json['videoUri'] as String?,
        title: json['title'] as String?,
        creatorId: json['creatorId'] as int?,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        likeTotal: json['likeTotal'] as String?,
        isLiked: json['isLiked'] as bool?,
      );

  bool get isVideo => type == 1;
}

/// 笔记详情
class NoteDetailModel {
  final int id;
  final int type;
  final String? title;
  final String? content;
  final List<String>? imgUris;
  final String? videoUri;
  final int? topicId;
  final String? topicName;
  final int? creatorId;
  final String? creatorName;
  final String? avatar;
  final String? updateTime;
  final int? visible;

  NoteDetailModel({
    required this.id,
    required this.type,
    this.title,
    this.content,
    this.imgUris,
    this.videoUri,
    this.topicId,
    this.topicName,
    this.creatorId,
    this.creatorName,
    this.avatar,
    this.updateTime,
    this.visible,
  });

  factory NoteDetailModel.fromJson(Map<String, dynamic> json) => NoteDetailModel(
        id: json['id'] as int,
        type: json['type'] as int,
        title: json['title'] as String?,
        content: json['content'] as String?,
        imgUris: (json['imgUris'] as List?)?.cast<String>(),
        videoUri: json['videoUri'] as String?,
        topicId: json['topicId'] as int?,
        topicName: json['topicName'] as String?,
        creatorId: json['creatorId'] as int?,
        creatorName: json['creatorName'] as String?,
        avatar: json['avatar'] as String?,
        updateTime: json['updateTime'] as String?,
        visible: json['visible'] as int?,
      );

  bool get isVideo => type == 1;
}

/// 笔记点赞收藏状态
class NoteLikeCollectStatus {
  final int noteId;
  final bool isLiked;
  final bool isCollected;

  NoteLikeCollectStatus({
    required this.noteId,
    required this.isLiked,
    required this.isCollected,
  });

  factory NoteLikeCollectStatus.fromJson(Map<String, dynamic> json) =>
      NoteLikeCollectStatus(
        noteId: json['noteId'] as int,
        isLiked: json['isLiked'] as bool,
        isCollected: json['isCollected'] as bool,
      );
}

/// 笔记列表响应（游标分页）
class NoteListResponse {
  final List<NoteItemModel>? notes;
  final int? nextCursor;

  NoteListResponse({this.notes, this.nextCursor});

  factory NoteListResponse.fromJson(Map<String, dynamic> json) => NoteListResponse(
        notes: (json['notes'] as List?)
            ?.map((e) => NoteItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: json['nextCursor'] as int?,
      );

  bool get hasMore => nextCursor != null;
}
