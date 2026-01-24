/// 用户模型
///
/// 不再限定固定角色（dad/mom/child），用户就是圈子里的一个成员。
/// 角色标签由用户自定义，如"我"、"他"、"闺蜜"等。
class User {
  final String id;
  final String name;
  final String avatar;
  final String? roleLabel; // 可选的角色标签，用户自定义

  const User({
    required this.id,
    required this.name,
    required this.avatar,
    this.roleLabel,
  });

  /// 显示名称（优先使用 roleLabel，否则用 name）
  String get displayName => roleLabel ?? name;
}

/// 圈子信息
///
/// 代表一个私密回忆圈子，可以是：
/// - 亲子圈（记录孩子成长）
/// - 情侣圈（记录恋爱时光）
/// - 好友圈（记录友情岁月）
/// - 个人独白（自己的时间胶囊）
class CircleInfo {
  final String name; // 圈子名称或主角名称
  final DateTime? startDate; // 可选的起始日期（如孩子生日、相识日等）

  const CircleInfo({required this.name, this.startDate});

  /// 计算时间标签 (如: "第 3 年 5 个月" 或 "3 岁 5 个月")
  String get timeLabel {
    if (startDate == null) return '';

    final now = DateTime.now();
    int years = now.year - startDate!.year;
    int months = now.month - startDate!.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (now.day < startDate!.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }

    if (years == 0) {
      return '$months 个月';
    }
    return '$years 年 $months 个月';
  }

  /// 简短时间标签 (如: "第3年")
  String get shortTimeLabel {
    if (startDate == null) return '';

    final now = DateTime.now();
    int years = now.year - startDate!.year;
    if (now.month < startDate!.month ||
        (now.month == startDate!.month && now.day < startDate!.day)) {
      years--;
    }
    return '第${years + 1}年';
  }

  /// 季节描述 (如: "第 3 个冬天")
  String get seasonLabel {
    if (startDate == null) return '这是你们的故事';

    final now = DateTime.now();
    int years = now.year - startDate!.year;
    if (now.month < startDate!.month) {
      years--;
    }

    String season;
    final month = now.month;
    if (month >= 3 && month <= 5) {
      season = '春天';
    } else if (month >= 6 && month <= 8) {
      season = '夏天';
    } else if (month >= 9 && month <= 11) {
      season = '秋天';
    } else {
      season = '冬天';
    }

    return '第 ${years + 1} 个$season';
  }

  /// 兼容旧代码的别名
  String get ageLabel => timeLabel;

  /// 兼容旧代码的别名
  String get shortAgeLabel => shortTimeLabel;

  /// 天数标签 (如: "第 847 天")
  /// 用于首页显示圈子已创建的天数
  String get durationLabel {
    if (startDate == null) return '第 1 天';

    final now = DateTime.now();
    final days = now.difference(startDate!).inDays + 1; // +1 因为当天也算
    return '第 $days 天';
  }

  /// 距离起始日期的天数（整数）
  /// 用于首页大字体显示
  int get daysSinceBirth {
    if (startDate == null) return 1;

    final now = DateTime.now();
    return now.difference(startDate!).inDays + 1; // +1 因为当天也算
  }
}

/// 保持向后兼容的别名
typedef ChildInfo = CircleInfo;
