/// 基础ID-Name模型
class BaseIdNameModel {
  final int id;
  final String name;

  BaseIdNameModel({
    required this.id,
    required this.name,
  });

  factory BaseIdNameModel.fromJson(Map<String, dynamic> json) {
    return BaseIdNameModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// 频道模型
class ChannelModel extends BaseIdNameModel {
  ChannelModel({required super.id, required super.name});

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

/// 话题模型
class TopicModel extends BaseIdNameModel {
  TopicModel({required super.id, required super.name});

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
