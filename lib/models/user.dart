/// 用户模型
class UserModel {
  final int userId;
  final String? avatar;
  final String? nickname;
  final String? xiaohashuId;
  final int? sex; // 0: 女, 1: 男
  final int? age;
  final String? birthday;
  final String? introduction;
  final String? backgroundImg;

  UserModel({
    required this.userId,
    this.avatar,
    this.nickname,
    this.xiaohashuId,
    this.sex,
    this.age,
    this.birthday,
    this.introduction,
    this.backgroundImg,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['userId'] as int,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        xiaohashuId: json['xiaohashuId'] as String?,
        sex: json['sex'] as int?,
        age: json['age'] as int?,
        birthday: json['birthday'] as String?,
        introduction: json['introduction'] as String?,
        backgroundImg: json['backgroundImg'] as String?,
      );

  String get displayName => nickname ?? '用户$userId';
  String get genderText => sex == 1 ? '男' : (sex == 0 ? '女' : '未知');
}

/// 用户主页信息
class UserProfileModel {
  final String odUserId; // 使用 String 避免 JS 精度问题
  final String? avatar;
  final String? nickname;
  final String? xiaohashuId;
  final int? sex;
  final int? age;
  final String? birthday;
  final String? introduction;
  final String? backgroundImg;
  final String? followingTotal;
  final String? fansTotal;
  final String? likeAndCollectTotal;
  final String? noteTotal;
  final String? likeTotal;
  final String? collectTotal;
  final bool? isFollowed; // 当前登录用户是否已关注该用户

  // 兼容旧代码
  int get userId => int.tryParse(odUserId) ?? 0;

  UserProfileModel({
    required this.odUserId,
    this.avatar,
    this.nickname,
    this.xiaohashuId,
    this.sex,
    this.age,
    this.birthday,
    this.introduction,
    this.backgroundImg,
    this.followingTotal,
    this.fansTotal,
    this.likeAndCollectTotal,
    this.noteTotal,
    this.likeTotal,
    this.collectTotal,
    this.isFollowed,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        odUserId: json['userId']?.toString() ?? '0', // 转为 String 保存
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        xiaohashuId: json['xiaohashuId'] as String?,
        sex: json['sex'] as int?,
        age: json['age'] as int?,
        birthday: json['birthday'] as String?,
        introduction: json['introduction'] as String?,
        backgroundImg: json['backgroundImg'] as String?,
        followingTotal: json['followingTotal'] as String?,
        fansTotal: json['fansTotal'] as String?,
        likeAndCollectTotal: json['likeAndCollectTotal'] as String?,
        noteTotal: json['noteTotal'] as String?,
        likeTotal: json['likeTotal'] as String?,
        collectTotal: json['collectTotal'] as String?,
        isFollowed: json['isFollowed'] as bool?,
      );
}

/// 关注列表用户
class FollowingUserModel {
  final int userId;
  final String? avatar;
  final String? nickname;
  final String? introduction;
  final bool? isFollowed; // 当前登录用户是否已关注该用户

  FollowingUserModel({
    required this.userId,
    this.avatar,
    this.nickname,
    this.introduction,
    this.isFollowed,
  });

  factory FollowingUserModel.fromJson(Map<String, dynamic> json) =>
      FollowingUserModel(
        userId: json['userId'] as int,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        introduction: json['introduction'] as String?,
        isFollowed: json['isFollowed'] as bool?,
      );
}

/// 粉丝列表用户
class FansUserModel {
  final int userId;
  final String? avatar;
  final String? nickname;
  final int? fansTotal;
  final int? noteTotal;
  final bool? isFollowed; // 当前登录用户是否已关注该用户

  FansUserModel({
    required this.userId,
    this.avatar,
    this.nickname,
    this.fansTotal,
    this.noteTotal,
    this.isFollowed,
  });

  factory FansUserModel.fromJson(Map<String, dynamic> json) => FansUserModel(
        userId: json['userId'] as int,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        fansTotal: json['fansTotal'] as int?,
        noteTotal: json['noteTotal'] as int?,
        isFollowed: json['isFollowed'] as bool?,
      );
}
