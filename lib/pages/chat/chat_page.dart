import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/models/chat.dart';
import 'package:frame/api/chat_api.dart';
import 'package:frame/api/oss_api.dart';
import 'package:frame/router/router.dart';
import 'package:frame/store/app_store.dart';

/// 聊天详情页
class ChatPage extends StatefulWidget {
  final String? conversationId;
  final int targetUserId;
  final String? targetUserNickname;
  final String? targetUserAvatar;

  const ChatPage({
    super.key,
    this.conversationId,
    required this.targetUserId,
    this.targetUserNickname,
    this.targetUserAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int? _nextCursor;
  String? _conversationId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _initChat();
    _scrollController.addListener(_onScroll);
  }

  /// 初始化聊天，如果没有 conversationId 则根据用户ID构造
  Future<void> _initChat() async {
    if (_conversationId == null) {
      // 根据两个用户ID构造 conversationId（格式：小ID_大ID）
      _conversationId = _buildConversationId();
    }
    await _loadMessages();
  }

  /// 根据当前用户ID和目标用户ID构造会话ID
  String? _buildConversationId() {
    final currentUserId = int.tryParse(AppStore.to.user?.id ?? '');
    if (currentUserId == null) return null;
    
    final targetUserId = widget.targetUserId;
    // conversationId 格式：小的ID_大的ID
    if (currentUserId < targetUserId) {
      return '${currentUserId}_$targetUserId';
    } else {
      return '${targetUserId}_$currentUserId';
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 滚动到顶部时加载更多历史消息
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await ChatApi.getMessageList(
        conversationId: _conversationId!,
      );

      if (mounted) {
        setState(() {
          _messages = response.messages;
          _hasMore = response.hasMore;
          _nextCursor = response.nextCursor;
          _isLoading = false;
        });

        // 标记已读
        ChatApi.markAsRead(_conversationId!);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _conversationId == null || _isLoading) return;

    try {
      final response = await ChatApi.getMessageList(
        conversationId: _conversationId!,
        cursor: _nextCursor,
      );

      if (mounted) {
        setState(() {
          _messages.addAll(response.messages);
          _hasMore = response.hasMore;
          _nextCursor = response.nextCursor;
        });
      }
    } catch (_) {}
  }

  Future<void> _sendMessage({String? content, String? imageUrl, int messageType = 0}) async {
    final text = content ?? _inputController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    setState(() => _isSending = true);

    try {
      final response = await ChatApi.sendMessage(
        receiverId: widget.targetUserId,
        content: imageUrl ?? text,
        messageType: messageType,
      );

      // 更新会话ID
      _conversationId ??= response.conversationId;

      // 添加消息到列表
      final newMessage = ChatMessageModel(
        id: response.messageId,
        senderId: 0, // 自己发送的
        receiverId: widget.targetUserId,
        content: imageUrl ?? text,
        messageType: messageType,
        createTime: response.createTime,
        isSelf: true,
      );

      setState(() {
        _messages.insert(0, newMessage);
        _isSending = false;
      });

      _inputController.clear();

      // 滚动到底部
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final imageUrl = await OssApi.uploadFileBytes(bytes, image.name);
        await _sendMessage(imageUrl: imageUrl, messageType: 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送图片失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => AppRouter.goUserProfile(widget.targetUserId),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                backgroundImage: widget.targetUserAvatar != null
                    ? NetworkImage(widget.targetUserAvatar!)
                    : null,
                child: widget.targetUserAvatar == null
                    ? Text(
                        widget.targetUserNickname?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(widget.targetUserNickname ?? '用户'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('暂无消息，发送第一条消息吧~', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // 最新消息在底部
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageItem(_messages[index]);
      },
    );
  }

  Widget _buildMessageItem(ChatMessageModel message) {
    final isSelf = message.isSelf;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSelf) ...[
            GestureDetector(
              onTap: () => AppRouter.goUserProfile(widget.targetUserId),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                backgroundImage: widget.targetUserAvatar != null
                    ? NetworkImage(widget.targetUserAvatar!)
                    : null,
                child: widget.targetUserAvatar == null
                    ? Text(
                        widget.targetUserNickname?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: _buildMessageBubble(message, isSelf)),
          if (isSelf) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isSelf) {
    // 图片消息
    if (message.messageType == 1) {
      return GestureDetector(
        onLongPressStart: (details) =>
            _showPopupMenu(details.globalPosition, message),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 180,
            maxHeight: 240,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message.content,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 150,
                height: 150,
                color: AppColors.background,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        ),
      );
    }

    // 系统消息
    if (message.messageType == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          message.content,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    // 文本消息
    return GestureDetector(
      onLongPressStart: (details) => _showPopupMenu(details.globalPosition, message),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelf ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSelf ? 16 : 4),
            bottomRight: Radius.circular(isSelf ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isSelf ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(Offset position, ChatMessageModel message) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        if (message.messageType == 0) // 只有文本消息才能复制
          const PopupMenuItem(
            value: 'copy',
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, size: 18),
                SizedBox(width: 8),
                Text('复制'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('删除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (result == 'copy') {
      await Clipboard.setData(ClipboardData(text: message.content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已复制到剪贴板')),
        );
      }
    } else if (result == 'delete') {
      _deleteMessage(message);
    }
  }

  Future<void> _deleteMessage(ChatMessageModel message) async {
    try {
      await ChatApi.deleteMessage(message.id);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: _pickAndSendImage,
              color: AppColors.textSecondary,
            ),
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: '发送消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isSending ? null : () => _sendMessage(),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
