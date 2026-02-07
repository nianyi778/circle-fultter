// Aura 触觉反馈服务
//
// 提供统一的触觉反馈接口，增强用户交互体验
// 符合 Aura 设计哲学：温柔、克制、有仪式感

import 'package:flutter/services.dart';

/// 触觉反馈服务
///
/// 使用示例:
/// ```dart
/// // 按钮点击
/// onTap: () {
///   HapticService.lightTap();
///   // ... 业务逻辑
/// }
///
/// // 仪式感操作
/// await HapticService.ceremony();
/// ```
class HapticService {
  HapticService._();

  /// 轻触反馈 - 按钮点击、轻触操作
  ///
  /// 适用场景:
  /// - 普通按钮点击
  /// - 列表项点击
  /// - 图标点击
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// 中等反馈 - 切换、选择
  ///
  /// 适用场景:
  /// - 开关切换
  /// - 选项选择
  /// - Tab 切换
  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// 重度反馈 - 重要操作完成
  ///
  /// 适用场景:
  /// - 重要操作完成
  /// - 删除确认
  /// - 错误警告
  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// 选择反馈 - 列表项选择
  ///
  /// 适用场景:
  /// - 选择器滚动选中
  /// - 日期选择
  /// - Picker 选择
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// 成功反馈 - 操作成功
  ///
  /// 使用双重触感传达成功感
  /// 适用场景:
  /// - 保存成功
  /// - 发送成功
  /// - 同步完成
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// 警告反馈 - 需要注意
  ///
  /// 使用重触感引起注意
  /// 适用场景:
  /// - 即将执行危险操作
  /// - 表单验证失败
  /// - 需要用户确认
  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
  }

  /// 错误反馈 - 操作失败
  ///
  /// 使用双重重触感传达错误
  /// 适用场景:
  /// - 网络错误
  /// - 操作失败
  /// - 权限被拒
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// 仪式感反馈 - 封存、发布等重要操作
  ///
  /// 使用渐进式触感传达仪式感
  /// 符合 Aura "慢即仪式" 的设计原则
  ///
  /// 适用场景:
  /// - 信件封存
  /// - 记录发布
  /// - 年度信创建
  static Future<void> ceremony() async {
    // 轻柔开始
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    // 中等过渡
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    // 重度完成
    await HapticFeedback.heavyImpact();
  }

  /// 呼吸触感 - 配合呼吸动效
  ///
  /// 轻柔的单次触感，用于呼吸动效的节奏点
  static Future<void> breathe() async {
    await HapticFeedback.lightImpact();
  }

  /// 滑动触感 - 滑动到边界
  ///
  /// 适用场景:
  /// - 列表滑动到顶/底部
  /// - 左右滑动到边界
  static Future<void> boundary() async {
    await HapticFeedback.mediumImpact();
  }

  /// 删除触感 - 滑动删除
  ///
  /// 适用场景:
  /// - 滑动删除卡片
  /// - 长按删除
  static Future<void> delete() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// 下拉刷新触感 - 触发刷新时
  static Future<void> refresh() async {
    await HapticFeedback.mediumImpact();
  }

  /// 自定义触感模式
  ///
  /// 用于特殊场景的自定义触感
  static Future<void> custom(HapticPattern pattern) async {
    for (final step in pattern.steps) {
      switch (step.type) {
        case HapticType.light:
          await HapticFeedback.lightImpact();
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
        case HapticType.selection:
          await HapticFeedback.selectionClick();
      }
      if (step.delay != Duration.zero) {
        await Future.delayed(step.delay);
      }
    }
  }
}

/// 触感类型
enum HapticType { light, medium, heavy, selection }

/// 触感步骤
class HapticStep {
  final HapticType type;
  final Duration delay;

  const HapticStep(this.type, [this.delay = Duration.zero]);
}

/// 触感模式
///
/// 用于定义自定义触感序列
class HapticPattern {
  final List<HapticStep> steps;

  const HapticPattern(this.steps);

  /// 成功模式
  static const success = HapticPattern([
    HapticStep(HapticType.medium),
    HapticStep(HapticType.light, Duration(milliseconds: 100)),
  ]);

  /// 错误模式
  static const error = HapticPattern([
    HapticStep(HapticType.heavy),
    HapticStep(HapticType.heavy, Duration(milliseconds: 80)),
  ]);

  /// 仪式模式
  static const ceremony = HapticPattern([
    HapticStep(HapticType.light),
    HapticStep(HapticType.medium, Duration(milliseconds: 150)),
    HapticStep(HapticType.heavy, Duration(milliseconds: 200)),
  ]);
}
