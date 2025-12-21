import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/api/user_api.dart';
import 'package:frame/models/user.dart';
import 'package:frame/components/loading.dart';

/// 编辑资料页面
class EditProfilePage extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _xiaohashuIdController = TextEditingController();
  final _introductionController = TextEditingController();

  int? _sex;
  String? _birthday;
  XFile? _avatarFile;
  Uint8List? _avatarBytes;
  String? _currentAvatar;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _nicknameController.text = widget.profile.nickname ?? '';
    _xiaohashuIdController.text = widget.profile.xiaohashuId ?? '';
    _introductionController.text = widget.profile.introduction ?? '';
    _sex = widget.profile.sex;
    _birthday = widget.profile.birthday;
    _currentAvatar = widget.profile.avatar;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _xiaohashuIdController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildTextField(
              label: '昵称',
              controller: _nicknameController,
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: '小哈书号',
              controller: _xiaohashuIdController,
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            _buildGenderSelector(),
            const SizedBox(height: 16),
            _buildBirthdaySelector(),
            const SizedBox(height: 16),
            _buildTextField(
              label: '简介',
              controller: _introductionController,
              maxLength: 100,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              backgroundImage: _avatarBytes != null
                  ? MemoryImage(_avatarBytes!)
                  : (_currentAvatar != null
                      ? NetworkImage(_currentAvatar!) as ImageProvider
                      : null),
              child: _avatarBytes == null && _currentAvatar == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderOption(1, '男'),
            const SizedBox(width: 16),
            _buildGenderOption(0, '女'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(int value, String label) {
    final isSelected = _sex == value;
    return GestureDetector(
      onTap: () => setState(() => _sex = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : AppColors.text),
        ),
      ),
    );
  }

  Widget _buildBirthdaySelector() {
    return GestureDetector(
      onTap: _pickBirthday,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '生日',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _birthday ?? '请选择',
          style: TextStyle(
            color: _birthday != null ? AppColors.text : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _avatarFile = image;
        _avatarBytes = bytes;
      });
    }
  }

  Future<void> _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _birthday = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    Loading.show(message: '保存中...');
    try {
      await UserApi.updateUserInfo(
        userId: widget.profile.userId,
        avatarBytes: _avatarBytes,
        avatarName: _avatarFile?.name,
        nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
        xiaohashuId: _xiaohashuIdController.text.isNotEmpty ? _xiaohashuIdController.text : null,
        sex: _sex,
        birthday: _birthday,
        introduction: _introductionController.text.isNotEmpty ? _introductionController.text : null,
      );
      Loading.hide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        context.pop(true);
      }
    } catch (e) {
      Loading.hide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
