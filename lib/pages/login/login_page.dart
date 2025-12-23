import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frame/store/app_store.dart';
import 'package:frame/router/router.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/app_button.dart';
import 'package:frame/components/app_input.dart';
import 'package:frame/components/loading.dart';
import 'package:frame/api/auth_api.dart';
import 'package:frame/api/user_api.dart';

/// 登录页
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingCode = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildForm(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildAgreement(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.auto_stories,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text('欢迎来到生活手贴', style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Text('记录生活，分享美好', style: AppTextStyles.hint),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppInput(
          label: '手机号',
          hint: '请输入手机号',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_android),
          maxLength: 11,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入手机号';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppInput(
                label: '验证码',
                hint: '请输入验证码',
                controller: _codeController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.security),
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入验证码';
                  }
                  if (value.length != 6) {
                    return '验证码为6位数字';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: SizedBox(
                width: 110,
                height: 48,
                child: OutlinedButton(
                  onPressed: _countdown > 0 || _isSendingCode
                      ? null
                      : _sendVerificationCode,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _countdown > 0
                          ? AppColors.border
                          : AppColors.primary,
                    ),
                  ),
                  child: _isSendingCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _countdown > 0 ? '${_countdown}s' : '获取验证码',
                          style: TextStyle(
                            fontSize: 13,
                            color: _countdown > 0
                                ? AppColors.textHint
                                : AppColors.primary,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AppButton(
      text: '登录',
      loading: _isLoading,
      width: double.infinity,
      size: AppButtonSize.large,
      onPressed: _login,
    );
  }

  Widget _buildAgreement() {
    return Text.rich(
      TextSpan(
        text: '登录即表示同意',
        style: AppTextStyles.caption,
        children: [
          TextSpan(
            text: '《用户协议》',
            style: TextStyle(color: AppColors.primary),
          ),
          const TextSpan(text: '和'),
          TextSpan(
            text: '《隐私政策》',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('请输入手机号');
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final response = await AuthApi.sendVerificationCode(phone);
      if (response.success) {
        _showSnackBar('验证码已发送');
        _startCountdown();
      } else {
        _showSnackBar(response.message ?? '发送失败');
      }
    } catch (e) {
      _showSnackBar('发送失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  /// 登录
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Loading.show(message: '登录中...');

    try {
      // 调用登录接口 (type=1 验证码登录)
      final token = await AuthApi.login(
        phone: _phoneController.text.trim(),
        code: _codeController.text.trim(),
        type: 1,
      );

      if (token != null) {
        // 先保存 token
        await AppStore.to.setToken(token);
        
        // 获取用户信息
        final profile = await UserApi.getUserProfile();
        if (profile != null) {
          final user = User(
            id: profile.odUserId,
            name: profile.nickname ?? _phoneController.text.trim(),
            avatar: profile.avatar,
          );
          await AppStore.to.setUser(user);
          debugPrint('📝 登录成功 - userId: ${profile.odUserId}');
        }

        if (!mounted) return;
        Loading.hide();
        AppRouter.goHome();
      } else {
        throw Exception('登录失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      Loading.hide();
      _showSnackBar('登录失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
