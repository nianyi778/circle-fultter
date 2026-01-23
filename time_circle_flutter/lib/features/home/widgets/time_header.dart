import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// 时间感知区头部
///
/// 根据用户状态显示不同内容：
/// - 新用户（无记录）：欢迎语
/// - 老用户：圈子名标签 + 记录数 + 时长
class TimeHeader extends StatelessWidget {
  final CircleInfo circleInfo;
  final bool hasHistory;
  final int momentCount;

  const TimeHeader({
    super.key,
    required this.circleInfo,
    required this.hasHistory,
    this.momentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasHistory) {
      // 新用户欢迎语
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '你好，',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(height: 1.3),
          ),
          Text(
            '欢迎来到 Circle。',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 16),
          Text(
            '这是一本空白的时间之书。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.warmGray500,
              height: 1.6,
            ),
          ),
          Text(
            '所有的温情、琐碎和感动，都将从此刻开始。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.warmGray500,
              height: 1.6,
            ),
          ),
        ],
      );
    }

    // 老用户：圈子名标签 + 记录数 + 时长
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 圈子名标签 + 记录数
        Row(
          children: [
            // 圈子名标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                circleInfo.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warmGray500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 分隔点
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.warmGray300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // 记录数
            Text(
              '已记录 $momentCount 个瞬间',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 时长标题（如 "第 847 天"）
        Text(
          circleInfo.durationLabel,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(height: 1.3),
        ),
      ],
    );
  }
}
