import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/models/chat.dart';
import 'package:frame/api/chat_api.dart';
import 'package:frame/router/router.dart';
import 'package:frame/store/app_store.dart';
import 'package:get/get.dart';

/// 消息页（会话列表）
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _pageNo = 1;
  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    // 监听登录状态变化，退出登录时清空数据
    _authWorker = ever(AppStore.to.obs, (_) {
      if (!AppStore.to.isLoggedIn) {
        _clearData();
      }
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }

  void _clearData() {
    if (mounted) {
      setState(() {
        _conversations = [];
        _isLoading = false;
        _hasMore = true;
        _pageNo = 1;
      });
    }
  }

  Future<void> _loadConversations({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;

    try {
      final response = await ChatApi.getConversationList(
        pageNo: loadMore ? _pageNo : 1,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _conversations.addAll(response.conversations);
          } else {
            _conversations = response.conversations;
          }
          _hasMore = response.hasMore;
          if (response.conversations.isNotEmpty) {
            _pageNo = response.pageNo + 1;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refresh() async {
    _pageNo = 1;
    _hasMore = true;
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _conversations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _conversations.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _conversations.length) {
                          return _buildLoadMore();
                        }
                        return _buildConversationItem(_conversations[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('暂无消息', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          onPressed: () => _loadConversations(loadMore: true),
          child: const Text('加载更多'),
        ),
      ),
    );
  }

  Widget _buildConversationItem(ConversationModel conversation) {
    return Dismissible(
      key: Key(conversation.conversationId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(conversation),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          backgroundImage: conversation.targetUserAvatar != null
              ? NetworkImage(conversation.targetUserAvatar!)
              : null,
          child: conversation.targetUserAvatar == null
              ? Text(
                  conversation.targetUserNickname?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.targetUserNickname ?? '用户',
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(conversation.lastMessageTime),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                _getLastMessagePreview(conversation),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(conversation),
      ),
    );
  }

  String _getLastMessagePreview(ConversationModel conversation) {
    if (conversation.lastMessageType == 1) {
      return '[图片]';
    } else if (conversation.lastMessageType == 2) {
      return '[系统消息]';
    }
    return conversation.lastMessageContent ?? '';
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inDays == 0) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return '昨天';
      } else if (diff.inDays < 7) {
        const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return weekdays[time.weekday - 1];
      } else {
        return '${time.month}/${time.day}';
      }
    } catch (_) {
      return timeStr;
    }
  }

  Future<bool> _confirmDelete(ConversationModel conversation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除会话'),
        content: const Text('确定要删除这个会话吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ChatApi.deleteConversation(conversation.conversationId);
        setState(() {
          _conversations.removeWhere((c) => c.conversationId == conversation.conversationId);
        });
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
    return false;
  }

  void _openChat(ConversationModel conversation) async {
    await AppRouter.goChat(
      conversationId: conversation.conversationId,
      targetUserId: conversation.targetUserId,
      targetUserNickname: conversation.targetUserNickname,
      targetUserAvatar: conversation.targetUserAvatar,
    );
    // 返回后刷新列表，更新已读状态
    _refresh();
  }
}
