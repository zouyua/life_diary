/// 聊天消息模型
class ChatMessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final int messageType; // 0: 文本, 1: 图片, 2: 系统消息
  final int readStatus; // 0: 未读, 1: 已读
  final String? readTime;
  final String? createTime;
  final bool isSelf;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = 0,
    this.readStatus = 0,
    this.readTime,
    this.createTime,
    this.isSelf = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      content: json['content'] as String? ?? '',
      messageType: json['messageType'] as int? ?? 0,
      readStatus: json['readStatus'] as int? ?? 0,
      readTime: json['readTime'] as String?,
      createTime: json['createTime'] as String?,
      isSelf: json['isSelf'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
      'readStatus': readStatus,
      'readTime': readTime,
      'createTime': createTime,
      'isSelf': isSelf,
    };
  }
}

/// 会话模型
class ConversationModel {
  final String conversationId;
  final int targetUserId;
  final String? targetUserNickname;
  final String? targetUserAvatar;
  final String? lastMessageContent;
  final String? lastMessageTime;
  final int lastMessageType;
  final int unreadCount;

  ConversationModel({
    required this.conversationId,
    required this.targetUserId,
    this.targetUserNickname,
    this.targetUserAvatar,
    this.lastMessageContent,
    this.lastMessageTime,
    this.lastMessageType = 0,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversationId'] as String,
      targetUserId: json['targetUserId'] as int,
      targetUserNickname: json['targetUserNickname'] as String?,
      targetUserAvatar: json['targetUserAvatar'] as String?,
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageTime: json['lastMessageTime'] as String?,
      lastMessageType: json['lastMessageType'] as int? ?? 0,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}

/// 发送消息响应
class SendMessageResponse {
  final int messageId;
  final String conversationId;
  final String? createTime;

  SendMessageResponse({
    required this.messageId,
    required this.conversationId,
    this.createTime,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      messageId: json['messageId'] as int,
      conversationId: json['conversationId'] as String,
      createTime: json['createTime'] as String?,
    );
  }
}

/// 消息列表响应（游标分页）
class MessageListResponse {
  final List<ChatMessageModel> messages;
  final int? nextCursor;
  final bool hasMore;

  MessageListResponse({
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final messagesList = json['messages'] as List? ?? [];
    return MessageListResponse(
      messages: messagesList
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// 会话列表响应
class ConversationListResponse {
  final List<ConversationModel> conversations;
  final int total;
  final int pageNo;
  final int pageSize;

  ConversationListResponse({
    required this.conversations,
    this.total = 0,
    this.pageNo = 1,
    this.pageSize = 20,
  });

  bool get hasMore => pageNo * pageSize < total;

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['conversations'] as List? ?? [];
    return ConversationListResponse(
      conversations: list
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      pageNo: json['pageNo'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }
}
