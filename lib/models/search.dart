/// 搜索用户结果
class SearchUserModel {
  final int userId;
  final String? nickname;
  final String? avatar;
  final String? xiaohashuId;
  final int? noteTotal;
  final String? fansTotal;
  final String? highlightNickname;

  SearchUserModel({
    required this.userId,
    this.nickname,
    this.avatar,
    this.xiaohashuId,
    this.noteTotal,
    this.fansTotal,
    this.highlightNickname,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) => SearchUserModel(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        xiaohashuId: json['xiaohashuId'] as String?,
        noteTotal: json['noteTotal'] as int?,
        fansTotal: json['fansTotal'] as String?,
        highlightNickname: json['highlightNickname'] as String?,
      );
}

/// 搜索笔记结果
class SearchNoteModel {
  final int noteId;
  final String? cover;
  final String? title;
  final String? highlightTitle;
  final String? avatar;
  final String? nickname;
  final String? updateTime;
  final String? likeTotal;
  final String? commentTotal;
  final String? collectTotal;

  SearchNoteModel({
    required this.noteId,
    this.cover,
    this.title,
    this.highlightTitle,
    this.avatar,
    this.nickname,
    this.updateTime,
    this.likeTotal,
    this.commentTotal,
    this.collectTotal,
  });

  factory SearchNoteModel.fromJson(Map<String, dynamic> json) => SearchNoteModel(
        noteId: json['noteId'] as int,
        cover: json['cover'] as String?,
        title: json['title'] as String?,
        highlightTitle: json['highlightTitle'] as String?,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        updateTime: json['updateTime'] as String?,
        likeTotal: json['likeTotal'] as String?,
        commentTotal: json['commentTotal'] as String?,
        collectTotal: json['collectTotal'] as String?,
      );
}

/// 搜索排序类型
enum SearchSortType {
  none, // 不限
  latest, // 最新
  mostLiked, // 最多点赞
  mostCommented, // 最多评论
  mostCollected, // 最多收藏
}

/// 发布时间范围
enum PublishTimeRange {
  none, // 不限
  oneDay, // 一天内
  oneWeek, // 一周内
  halfYear, // 半年内
}
