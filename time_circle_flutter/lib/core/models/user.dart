/// 用户角色
enum UserRole { mom, dad, child }

/// 用户模型
class User {
  final String id;
  final String name;
  final String avatar;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.mom:
        return '妈妈';
      case UserRole.dad:
        return '爸爸';
      case UserRole.child:
        return '孩子';
    }
  }
}

/// 孩子信息
class ChildInfo {
  final String name;
  final DateTime birthDate;

  const ChildInfo({
    required this.name,
    required this.birthDate,
  });

  /// 计算年龄标签 (如: "3 岁 5 个月")
  String get ageLabel {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    
    if (months < 0) {
      years--;
      months += 12;
    }
    
    if (now.day < birthDate.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }
    
    if (years == 0) {
      return '$months 个月';
    }
    return '$years 岁 $months 个月';
  }

  /// 简短年龄 (如: "3岁")
  String get shortAgeLabel {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return '$years岁';
  }

  /// 季节描述 (如: "第 3 个冬天")
  String get seasonLabel {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month) {
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
}
