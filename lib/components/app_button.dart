import 'package:flutter/material.dart';
import 'package:frame/theme/theme.dart';

/// 按钮类型
enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
}

/// 按钮大小
enum AppButtonSize {
  small,
  medium,
  large,
}

/// 通用按钮组件
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool loading;
  final bool disabled;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;

    return SizedBox(
      width: width,
      height: _getHeight(),
      child: _buildButton(isDisabled),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  Widget _buildButton(bool isDisabled) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: _buildChild(),
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          child: _buildChild(),
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: _buildChild(),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: _buildChild(),
        );
    }
  }

  Widget _buildChild() {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.primary || type == AppButtonType.secondary
                ? Colors.white
                : AppColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getFontSize() + 4),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: _getFontSize())),
        ],
      );
    }

    return Text(text, style: TextStyle(fontSize: _getFontSize()));
  }
}
