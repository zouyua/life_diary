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
  final int userId;
  final String? avatar;
  final String? nickname;
  final String? xiaohashuId;
  final int? sex;
  final int? age;
  final String? introduction;
  final String? backgroundImg;
  final String? followingTotal;
  final String? fansTotal;
  final String? likeAndCollectTotal;
  final String? noteTotal;
  final String? likeTotal;
  final String? collectTotal;

  UserProfileModel({
    required this.userId,
    this.avatar,
    this.nickname,
    this.xiaohashuId,
    this.sex,
    this.age,
    this.introduction,
    this.backgroundImg,
    this.followingTotal,
    this.fansTotal,
    this.likeAndCollectTotal,
    this.noteTotal,
    this.likeTotal,
    this.collectTotal,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        userId: json['userId'] as int,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        xiaohashuId: json['xiaohashuId'] as String?,
        sex: json['sex'] as int?,
        age: json['age'] as int?,
        introduction: json['introduction'] as String?,
        backgroundImg: json['backgroundImg'] as String?,
        followingTotal: json['followingTotal'] as String?,
        fansTotal: json['fansTotal'] as String?,
        likeAndCollectTotal: json['likeAndCollectTotal'] as String?,
        noteTotal: json['noteTotal'] as String?,
        likeTotal: json['likeTotal'] as String?,
        collectTotal: json['collectTotal'] as String?,
      );
}

/// 关注列表用户
class FollowingUserModel {
  final int userId;
  final String? avatar;
  final String? nickname;
  final String? introduction;

  FollowingUserModel({
    required this.userId,
    this.avatar,
    this.nickname,
    this.introduction,
  });

  factory FollowingUserModel.fromJson(Map<String, dynamic> json) =>
      FollowingUserModel(
        userId: json['userId'] as int,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        introduction: json['introduction'] as String?,
      );
}

/// 粉丝列表用户
class FansUserModel {
  final int userId;
  final String? avatar;
  final String? nickname;
  final int? fansTotal;
  final int? noteTotal;

  FansUserModel({
    required this.userId,
    this.avatar,
    this.nickname,
    this.fansTotal,
    this.noteTotal,
  });

  factory FansUserModel.fromJson(Map<String, dynamic> json) => FansUserModel(
        userId: json['userId'] as int,
        avatar: json['avatar'] as String?,
        nickname: json['nickname'] as String?,
        fansTotal: json['fansTotal'] as int?,
        noteTotal: json['noteTotal'] as int?,
      );
}
