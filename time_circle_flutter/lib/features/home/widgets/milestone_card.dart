import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

/// 里程碑数据模型
class Milestone {
  final String title;
  final String subtitle;
  final int daysUntil; // 0 = 今天，负数 = 已过
  final MilestoneType type;

  const Milestone({
    required this.title,
    required this.subtitle,
    required this.daysUntil,
    required this.type,
  });
}

enum MilestoneType {
  hundredDays, // 整百天
  anniversary, // 周年
  thousandDays, // 整千天
  special, // 特殊日子
}

/// 里程碑提醒卡片
///
/// 设计理念：
/// - 温柔的提醒，增加仪式感
/// - 只在接近里程碑时显示
/// - 整百天、周年、整千天等
/// - 适用于任何亲密关系记录场景
class MilestoneCard extends ConsumerWidget {
  const MilestoneCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleInfo = ref.watch(circleInfoProvider);
    final milestone = _calculateMilestone(circleInfo.daysSinceBirth);

    // 没有即将到来的里程碑时不显示
    if (milestone == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.warmOrangeLight,
            AppColors.warmOrange.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warmOrangeDeep.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 左侧图标
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warmOrangeDeep.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _getEmoji(milestone.type),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 文字内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.warmGray800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (milestone.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    milestone.subtitle,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 计算最近的里程碑
  Milestone? _calculateMilestone(int daysSinceBirth) {
    // 检查整百天 (100, 200, 300...)
    final nextHundred = ((daysSinceBirth ~/ 100) + 1) * 100;
    final daysToHundred = nextHundred - daysSinceBirth;

    // 检查整千天 (1000, 2000...)
    final nextThousand = ((daysSinceBirth ~/ 1000) + 1) * 1000;
    final daysToThousand = nextThousand - daysSinceBirth;

    // 检查周年 (365, 730, 1095...)
    final currentYear = daysSinceBirth ~/ 365;
    final nextAnniversary = (currentYear + 1) * 365;
    final daysToAnniversary = nextAnniversary - daysSinceBirth;

    // 今天正好是里程碑
    if (daysSinceBirth == 100 ||
        daysSinceBirth == 200 ||
        daysSinceBirth == 300 ||
        daysSinceBirth == 500 ||
        daysSinceBirth == 1000) {
      return Milestone(
        title: '今天是第 $daysSinceBirth 天！',
        subtitle: '一个值得纪念的日子',
        daysUntil: 0,
        type:
            daysSinceBirth >= 1000
                ? MilestoneType.thousandDays
                : MilestoneType.hundredDays,
      );
    }

    // 今天正好是周年
    if (daysSinceBirth % 365 == 0 && daysSinceBirth > 0) {
      final years = daysSinceBirth ~/ 365;
      return Milestone(
        title: '今天是第 $years 年！',
        subtitle: '周年快乐',
        daysUntil: 0,
        type: MilestoneType.anniversary,
      );
    }

    // 优先级：整千天 > 周年 > 整百天
    // 只显示 7 天内的里程碑

    // 整千天（7天内）
    if (daysToThousand <= 7 && daysToThousand > 0) {
      if (daysToThousand == 1) {
        return Milestone(
          title: '明天就是第 $nextThousand 天！',
          subtitle: '一个重要的里程碑',
          daysUntil: 1,
          type: MilestoneType.thousandDays,
        );
      }
      return Milestone(
        title: '再过 $daysToThousand 天就是第 $nextThousand 天',
        subtitle: '一个重要的里程碑即将到来',
        daysUntil: daysToThousand,
        type: MilestoneType.thousandDays,
      );
    }

    // 周年（7天内）
    if (daysToAnniversary <= 7 && daysToAnniversary > 0) {
      final nextYear = currentYear + 1;
      if (daysToAnniversary == 1) {
        return Milestone(
          title: '明天就是第 $nextYear 年的开始！',
          subtitle: '时间过得真快',
          daysUntil: 1,
          type: MilestoneType.anniversary,
        );
      }
      return Milestone(
        title: '再过 $daysToAnniversary 天就是第 $nextYear 年',
        subtitle: '新的一年即将开始',
        daysUntil: daysToAnniversary,
        type: MilestoneType.anniversary,
      );
    }

    // 整百天（7天内，但只提醒 100, 200, 300, 500）
    final importantHundreds = [100, 200, 300, 500];
    if (daysToHundred <= 7 &&
        daysToHundred > 0 &&
        importantHundreds.contains(nextHundred)) {
      if (daysToHundred == 1) {
        return Milestone(
          title: '明天就是第 $nextHundred 天啦！',
          subtitle: '值得庆祝的一天',
          daysUntil: 1,
          type: MilestoneType.hundredDays,
        );
      }
      return Milestone(
        title: '再过 $daysToHundred 天就是第 $nextHundred 天',
        subtitle: '一个小小的里程碑',
        daysUntil: daysToHundred,
        type: MilestoneType.hundredDays,
      );
    }

    return null;
  }

  String _getEmoji(MilestoneType type) {
    switch (type) {
      case MilestoneType.hundredDays:
        return '🎯';
      case MilestoneType.anniversary:
        return '🎂';
      case MilestoneType.thousandDays:
        return '🎉';
      case MilestoneType.special:
        return '✨';
    }
  }
}
