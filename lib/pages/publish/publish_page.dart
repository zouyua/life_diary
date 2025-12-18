import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/app_button.dart';

/// 发布笔记页
class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _selectedImages = [];

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
        title: const Text('发布笔记'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppButton(
              text: '发布',
              size: AppButtonSize.small,
              onPressed: _publish,
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

  Widget _buildImagePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._selectedImages.map((img) => _buildImageItem(img)),
        if (_selectedImages.length < 9) _buildAddButton(),
      ],
    );
  }

  Widget _buildImageItem(String url) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImages.remove(url)),
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
            Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textHint),
            SizedBox(height: 4),
            Text('添加图片', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
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
      onTap: _selectTopic,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text('添加话题', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _pickImages() {
    // TODO: 实现图片选择
  }

  void _selectTopic() {
    // TODO: 实现话题选择
  }

  void _publish() {
    // TODO: 实现发布逻辑
  }
}
