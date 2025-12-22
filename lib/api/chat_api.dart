import 'package:frame/api/http.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/chat.dart';

/// 聊天模块 API
/// Gateway 路由: /chat/** -> xiaohashu-chat
class ChatApi {
  /// 发送消息
  static Future<SendMessageResponse> sendMessage({
    required int receiverId,
    required String content,
    int messageType = 0,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/message/send',
      data: {
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType,
      },
    );
    final response = ApiResponse.fromJson(
      data ?? {},
      (d) => SendMessageResponse.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success) {
      throw ApiException(message: response.message ?? '发送消息失败');
    }
    return response.data!;
  }

  /// 获取消息列表（游标分页）
  static Future<MessageListResponse> getMessageList({
    required String conversationId,
    int? cursor,
    int limit = 20,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/message/list',
      data: {
        'conversationId': conversationId,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    final response = ApiResponse.fromJson(
      data ?? {},
      (d) => MessageListResponse.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success) {
      throw ApiException(message: response.message ?? '获取消息列表失败');
    }
    return response.data!;
  }

  /// 标记消息已读
  static Future<void> markAsRead(String conversationId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/message/read',
      data: {'conversationId': conversationId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '标记已读失败');
    }
  }

  /// 删除消息
  static Future<void> deleteMessage(int messageId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/message/delete',
      data: {'messageId': messageId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '删除消息失败');
    }
  }

  /// 获取会话列表
  static Future<ConversationListResponse> getConversationList({
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/conversation/list',
      data: {'pageNo': pageNo, 'pageSize': pageSize},
    );
    final response = ApiResponse.fromJson(
      data ?? {},
      (d) => ConversationListResponse.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success) {
      throw ApiException(message: response.message ?? '获取会话列表失败');
    }
    return response.data!;
  }

  /// 删除会话
  static Future<void> deleteConversation(String conversationId) async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/conversation/delete',
      data: {'conversationId': conversationId},
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '删除会话失败');
    }
  }

  /// 获取未读消息数量
  static Future<int> getUnreadCount() async {
    final data = await Http.post<Map<String, dynamic>>(
      '/chat/chat/message/unread/count',
    );
    final response = ApiResponse.fromJson(data ?? {}, null);
    if (!response.success) {
      throw ApiException(message: response.message ?? '获取未读数量失败');
    }
    final responseData = response.data as Map<String, dynamic>?;
    return responseData?['totalUnreadCount'] as int? ?? 0;
  }
}
