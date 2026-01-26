import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/app_providers.dart';

/// 时间感知区头部 - 重新设计
///
/// 设计理念：
/// - 日期 + 统计数据为核心
/// - 适用于任何亲密关系记录场景
/// - 温暖的问候语 + 今日日期
/// - 下方显示回忆统计（XX 条回忆 / XX 封信）
class TimeHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasHistory) {
      // 新用户欢迎语
      return _buildNewUserHeader(context);
    }

    // 老用户：日期 + 统计
    return _buildExistingUserHeader(context, ref);
  }

  /// 新用户头部
  Widget _buildNewUserHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '你好，',
          style: AppTypography.title(
            context,
          ).copyWith(color: AppColors.warmGray600),
        ),
        const SizedBox(height: 4),
        Text(
          '欢迎来到念念',
          style: AppTypography.title(
            context,
          ).copyWith(color: AppColors.warmGray800, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Text(
          '这是一本空白的时间之书。',
          style: AppTypography.body(
            context,
          ).copyWith(color: AppColors.warmGray500),
        ),
        const SizedBox(height: 4),
        Text(
          '所有的温情和感动，都将从此刻开始。',
          style: AppTypography.body(
            context,
          ).copyWith(color: AppColors.warmGray500),
        ),
      ],
    );
  }

  /// 老用户头部 - 日期 + 统计数据
  Widget _buildExistingUserHeader(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdayNames[now.weekday - 1];
    final letterCount = ref.watch(lettersCountProvider);

    // 根据时间段生成问候语
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 问候语
        Text(
          greeting,
          style: AppTypography.title(context).copyWith(
            color: AppColors.warmGray800,
            fontWeight: FontWeight.w500,
            fontSize: 28,
          ),
        ),

        const SizedBox(height: 12),

        // 今日日期
        Row(
          children: [
            Text(
              '${now.year}年${now.month}月${now.day}日',
              style: AppTypography.body(
                context,
              ).copyWith(color: AppColors.warmGray600),
            ),
            _buildDot(),
            Text(
              weekday,
              style: AppTypography.body(
                context,
              ).copyWith(color: AppColors.warmGray600),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 统计数据条
        _buildStatsRow(context, letterCount),
      ],
    );
  }

  /// 统计数据条
  Widget _buildStatsRow(BuildContext context, int letterCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warmGray200, width: 1),
      ),
      child: Row(
        children: [
          // 回忆数量
          _buildStatItem(
            context,
            count: momentCount,
            label: '条回忆',
            color: AppColors.warmPeachDeep,
          ),

          // 分隔线
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.warmGray200,
          ),

          // 信件数量
          _buildStatItem(
            context,
            count: letterCount,
            label: '封信',
            color: AppColors.warmOrangeDeep,
          ),

          const Spacer(),

          // 圈子信息
          if (circleInfo.name.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    circleInfo.name,
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.warmGray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (circleInfo.timeLabel.isNotEmpty) ...[
                    _buildDot(),
                    Text(
                      circleInfo.timeLabel,
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.warmGray500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 单个统计项
  Widget _buildStatItem(
    BuildContext context, {
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$count',
          style: AppTypography.subtitle(
            context,
          ).copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption(
            context,
          ).copyWith(color: AppColors.warmGray500),
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: AppColors.warmGray300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// 根据时间段返回问候语
  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 9) {
      return '早安';
    } else if (hour >= 9 && hour < 12) {
      return '上午好';
    } else if (hour >= 12 && hour < 14) {
      return '午安';
    } else if (hour >= 14 && hour < 18) {
      return '下午好';
    } else if (hour >= 18 && hour < 22) {
      return '晚上好';
    } else {
      return '夜深了';
    }
  }
}
