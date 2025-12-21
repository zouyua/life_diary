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
  final int? likeTotal;
  final bool? isLiked;
  final int? visible; // 可见范围 (0：公开 1：仅自己可见)
  final bool? isTop; // 是否置顶

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
    this.visible,
    this.isTop,
  });

  factory NoteItemModel.fromJson(Map<String, dynamic> json) => NoteItemModel(
        // 兼容 noteId 和 id 两种字段名
        noteId: (json['noteId'] ?? json['id']) as int,
        type: json['type'] as int,
        cover: json['cover'] as String?,
        videoUri: json['videoUri'] as String?,
        title: json['title'] as String?,
        creatorId: json['creatorId'] as int?,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        // 兼容 String 和 int 类型
        likeTotal: json['likeTotal'] != null
            ? int.tryParse(json['likeTotal'].toString())
            : null,
        isLiked: json['isLiked'] as bool?,
        visible: json['visible'] as int?,
        isTop: json['isTop'] as bool?,
      );

  bool get isVideo => type == 1;
  bool get isPrivate => visible == 1;
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
  final String? creatorId; // 使用 String 避免 JS 精度问题
  final String? creatorName;
  final String? avatar;
  final String? updateTime;
  final int? visible;
  final bool? isTop; // 是否置顶
  final int? likeTotal; // 点赞数
  final int? collectTotal; // 收藏数
  final int? commentTotal; // 评论数
  final bool? isFollowed; // 当前登录用户是否已关注笔记作者

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
    this.isTop,
    this.likeTotal,
    this.collectTotal,
    this.commentTotal,
    this.isFollowed,
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
        creatorId: json['creatorId']?.toString(), // 转为 String
        creatorName: json['creatorName'] as String?,
        avatar: json['avatar'] as String?,
        updateTime: json['updateTime'] as String?,
        visible: json['visible'] as int?,
        isTop: json['isTop'] as bool?,
        likeTotal: json['likeTotal'] as int?,
        collectTotal: json['collectTotal'] as int?,
        commentTotal: json['commentTotal'] as int?,
        isFollowed: json['isFollowed'] as bool?,
      );

  bool get isVideo => type == 1;
  bool get isPrivate => visible == 1;
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


/// 笔记分页列表响应
class NotePageResponse {
  final List<NoteItemModel> data;
  final int pageNo;
  final int totalCount;
  final int pageSize;
  final int totalPage;

  NotePageResponse({
    required this.data,
    required this.pageNo,
    required this.totalCount,
    required this.pageSize,
    required this.totalPage,
  });

  factory NotePageResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    List<NoteItemModel> notes = [];
    if (dataList is List) {
      notes = dataList
          .map((e) => NoteItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return NotePageResponse(
      data: notes,
      pageNo: json['pageNo'] as int? ?? 1,
      totalCount: json['totalCount'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 10,
      totalPage: json['totalPage'] as int? ?? 0,
    );
  }

  bool get hasMore => pageNo < totalPage;
}
