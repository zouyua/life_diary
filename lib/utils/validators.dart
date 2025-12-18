/// 表单验证工具
class Validators {
  /// 邮箱验证正则
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// 手机号验证正则（中国大陆）
  static final RegExp _phoneRegex = RegExp(r'^1[3-9]\d{9}$');

  /// 密码验证正则（至少8位，包含字母和数字）
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  /// 用户名验证正则（4-20位字母数字下划线）
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{4,20}$');

  /// 验证邮箱
  static bool isEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    return _emailRegex.hasMatch(value);
  }

  /// 验证手机号
  static bool isPhone(String? value) {
    if (value == null || value.isEmpty) return false;
    return _phoneRegex.hasMatch(value);
  }

  /// 验证密码强度
  static bool isStrongPassword(String? value) {
    if (value == null || value.isEmpty) return false;
    return _passwordRegex.hasMatch(value);
  }

  /// 验证用户名
  static bool isUsername(String? value) {
    if (value == null || value.isEmpty) return false;
    return _usernameRegex.hasMatch(value);
  }

  /// 验证非空
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// 验证长度范围
  static bool isLengthBetween(String? value, int min, int max) {
    if (value == null) return false;
    return value.length >= min && value.length <= max;
  }

  /// 验证是否为数字
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// 验证 URL
  static bool isUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    return Uri.tryParse(value)?.hasAbsolutePath ?? false;
  }

  /// 表单验证器 - 必填
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '此项'}不能为空';
    }
    return null;
  }

  /// 表单验证器 - 邮箱
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!isEmail(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  /// 表单验证器 - 手机号
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!isPhone(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }

  /// 表单验证器 - 密码
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 8) {
      return '密码长度至少8位';
    }
    if (!isStrongPassword(value)) {
      return '密码需包含字母和数字';
    }
    return null;
  }

  /// 表单验证器 - 确认密码
  static String? Function(String?) confirmPassword(String? password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '请确认密码';
      }
      if (value != password) {
        return '两次输入的密码不一致';
      }
      return null;
    };
  }
}
