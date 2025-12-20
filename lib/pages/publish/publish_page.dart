import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/app_button.dart';
import 'package:frame/components/loading.dart';
import 'package:frame/api/note_api.dart';
import 'package:frame/api/oss_api.dart';
import 'package:frame/models/channel.dart';
import 'package:frame/models/note.dart';
import 'package:frame/router/router.dart';
import 'package:frame/store/app_store.dart';

/// 发布/编辑笔记页
class PublishPage extends StatefulWidget {
  final NoteDetailModel? editNote;

  const PublishPage({super.key, this.editNote});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];
  final List<String> _existingImageUrls = []; // 已有的图片URL（编辑模式）

  // 频道和话题
  ChannelModel? _selectedChannel;
  TopicModel? _selectedTopic;
  bool _isPublishing = false;

  bool get _isEditMode => widget.editNote != null;

  @override
  void initState() {
    super.initState();
    _initEditData();
  }

  void _initEditData() {
    if (widget.editNote != null) {
      final note = widget.editNote!;
      _titleController.text = note.title ?? '';
      _contentController.text = note.content ?? '';
      _existingImageUrls.addAll(note.imgUris ?? []);
      if (note.topicId != null && note.topicName != null) {
        _selectedTopic = TopicModel(id: note.topicId!, name: note.topicName!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑笔记' : '发布笔记'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppButton(
              text: _isEditMode ? '保存' : '发布',
              size: AppButtonSize.small,
              width: 60,
              loading: _isPublishing,
              onPressed: _canPublish() ? _publish : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildContentInput(),
            const SizedBox(height: 16),
            _buildTopicSelector(),
          ],
        ),
      ),
    );
  }

  bool _canPublish() {
    return (_selectedImages.isNotEmpty || _existingImageUrls.isNotEmpty) &&
        !_isPublishing;
  }

  Widget _buildImagePicker() {
    final totalImages = _existingImageUrls.length + _selectedImages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加图片 ($totalImages/9)',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 已有的图片（编辑模式）
            ...List.generate(
                _existingImageUrls.length, (i) => _buildExistingImageItem(i)),
            // 新选择的图片
            ...List.generate(_selectedImages.length, (i) => _buildImageItem(i)),
            if (totalImages < 9) _buildAddButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildExistingImageItem(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _existingImageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: AppColors.textHint),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeExistingImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Widget _buildImageItem(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _imageBytes.length > index
                ? Image.memory(_imageBytes[index], fit: BoxFit.cover)
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_imageBytes.length > index) {
        _imageBytes.removeAt(index);
      }
    });
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 32, color: AppColors.textHint),
            SizedBox(height: 4),
            Text('添加图片',
                style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      maxLength: 20,
      decoration: const InputDecoration(
        hintText: '填写标题会有更多赞哦~',
        border: InputBorder.none,
        counterText: '',
      ),
      style: AppTextStyles.h3,
    );
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: 8,
      maxLength: 1000,
      decoration: const InputDecoration(
        hintText: '添加正文',
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildTopicSelector() {
    return GestureDetector(
      onTap: _showChannelTopicSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedTopic != null
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tag,
              size: 16,
              color: _selectedTopic != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _selectedTopic?.name ?? '添加话题',
              style: TextStyle(
                color: _selectedTopic != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            if (_selectedTopic != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedChannel = null;
                  _selectedTopic = null;
                }),
                child: Icon(Icons.close, size: 14, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final totalImages = _existingImageUrls.length + _selectedImages.length;
    final maxCount = 9 - totalImages;

    if (maxCount <= 0) return;

    try {
      final images = await picker.pickMultiImage(
        limit: maxCount,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        for (final image in images) {
          final total = _existingImageUrls.length + _selectedImages.length;
          if (total >= 9) break;
          _selectedImages.add(image);
          final bytes = await image.readAsBytes();
          _imageBytes.add(bytes);
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  void _showChannelTopicSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ChannelTopicSheet(
        selectedChannel: _selectedChannel,
        selectedTopic: _selectedTopic,
        onChannelSelected: (channel) {
          setState(() => _selectedChannel = channel);
        },
        onTopicSelected: (topic) {
          setState(() => _selectedTopic = topic);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _publish() async {
    final totalImages = _existingImageUrls.length + _selectedImages.length;
    if (totalImages == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一张图片')),
      );
      return;
    }

    setState(() => _isPublishing = true);
    Loading.show(message: _isEditMode ? '正在保存...' : '正在上传图片...');

    try {
      // 1. 上传新图片
      final imgUris = <String>[..._existingImageUrls];
      for (int i = 0; i < _selectedImages.length; i++) {
        Loading.show(
            message:
                '正在上传图片 ${_existingImageUrls.length + i + 1}/$totalImages...');
        final url = await OssApi.uploadFileBytes(
          _imageBytes[i],
          _selectedImages[i].name,
        );
        if (url != null) {
          imgUris.add(url);
        }
      }

      if (imgUris.isEmpty) {
        throw Exception('图片上传失败');
      }

      // 2. 发布或更新笔记
      Loading.show(message: _isEditMode ? '正在保存...' : '正在发布...');

      if (_isEditMode) {
        await NoteApi.update(
          id: widget.editNote!.id,
          type: 0,
          imgUris: imgUris,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          topicId: _selectedTopic?.id,
        );
      } else {
        await NoteApi.publish(
          type: 0,
          imgUris: imgUris,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          topicId: _selectedTopic?.id,
        );
      }

      // 成功
      Loading.hide();
      // 触发列表刷新
      AppStore.to.refreshNoteList();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditMode ? '保存成功' : '发布成功'),
              duration: const Duration(seconds: 1)),
        );
        if (_isEditMode) {
          AppRouter.back();
        } else {
          AppRouter.goHome();
        }
      }
    } catch (e) {
      Loading.hide();
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? '保存失败: $e' : '发布失败: $e')),
        );
      }
    }
  }
}

/// 频道话题选择弹窗
class _ChannelTopicSheet extends StatefulWidget {
  final ChannelModel? selectedChannel;
  final TopicModel? selectedTopic;
  final Function(ChannelModel) onChannelSelected;
  final Function(TopicModel) onTopicSelected;

  const _ChannelTopicSheet({
    this.selectedChannel,
    this.selectedTopic,
    required this.onChannelSelected,
    required this.onTopicSelected,
  });

  @override
  State<_ChannelTopicSheet> createState() => _ChannelTopicSheetState();
}

class _ChannelTopicSheetState extends State<_ChannelTopicSheet> {
  List<ChannelModel> _channels = [];
  List<TopicModel> _topics = [];
  ChannelModel? _currentChannel;
  bool _isLoadingChannels = true;
  bool _isLoadingTopics = false;
  String? _channelError;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.selectedChannel;
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingChannels = true;
      _channelError = null;
    });
    
    try {
      final channels = await NoteApi.getChannelList();
      if (mounted) {
        setState(() {
          _channels = channels;
          _isLoadingChannels = false;
        });
        if (_currentChannel != null) {
          _loadTopics(_currentChannel!.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingChannels = false;
          _channelError = e.toString();
        });
      }
    }
  }

  Future<void> _loadTopics(int channelId) async {
    setState(() => _isLoadingTopics = true);
    try {
      final topics = await NoteApi.getTopicList(channelId);
      if (mounted) {
        setState(() {
          _topics = topics;
          _isLoadingTopics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTopics = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('选择话题',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 频道列表
          const Text('频道', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (_isLoadingChannels)
            const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_channelError != null)
            SizedBox(
              height: 40,
              child: Center(
                child: TextButton(
                  onPressed: _loadChannels,
                  child: const Text('加载失败，点击重试'),
                ),
              ),
            )
          else if (_channels.isEmpty)
            const SizedBox(
              height: 40,
              child: Center(child: Text('暂无频道')),
            )
          else
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _channels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final channel = _channels[index];
                  final isSelected = _currentChannel?.id == channel.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentChannel = channel);
                      widget.onChannelSelected(channel);
                      _loadTopics(channel.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        channel.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          // 话题列表
          const Text('话题', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Expanded(
            child: _currentChannel == null
                ? const Center(
                    child: Text('请先选择频道',
                        style: TextStyle(color: AppColors.textHint)))
                : _isLoadingTopics
                    ? const Center(child: CircularProgressIndicator())
                    : _topics.isEmpty
                        ? const Center(
                            child: Text('暂无话题',
                                style: TextStyle(color: AppColors.textHint)))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _topics.map((topic) {
                              final isSelected =
                                  widget.selectedTopic?.id == topic.id;
                              return GestureDetector(
                                onTap: () => widget.onTopicSelected(topic),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.1)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    '#${topic.name}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
          ),
        ],
      ),
    );
  }
}
