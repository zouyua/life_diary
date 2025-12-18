import 'package:flutter/material.dart';
import 'package:frame/store/app_store.dart';
import 'package:frame/router/router.dart';
import 'package:frame/theme/theme.dart';
import 'package:frame/components/app_button.dart';
import 'package:frame/components/app_input.dart';
import 'package:frame/components/loading.dart';
import 'package:frame/utils/validators.dart';

/// 登录页
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                _buildRegisterLink(),
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
            Icons.flutter_dash,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '欢迎回来',
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: 8),
        Text(
          '请登录您的账号',
          style: AppTextStyles.hint,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppInput(
          label: '邮箱',
          hint: '请输入邮箱',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        AppInput(
          label: '密码',
          hint: '请输入密码',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outlined),
          validator: Validators.password,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: 忘记密码
            },
            child: const Text('忘记密码？'),
          ),
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

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: 跳转注册页
          },
          child: const Text('立即注册'),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Loading.show(message: '登录中...');

    try {
      // 模拟登录请求
      await Future.delayed(const Duration(seconds: 1));

      // 模拟登录成功
      final user = User(
        id: '1',
        name: '测试用户',
        email: _emailController.text,
      );

      await AppStore.to.login('mock_token_123', user);

      Loading.hide();
      AppRouter.goHome();
    } catch (e) {
      Loading.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
