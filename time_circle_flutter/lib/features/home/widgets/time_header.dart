import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/app_providers.dart';

/// 时间感知区头部 - 全新设计
///
/// 设计理念：
/// - 大号时间数字作为视觉焦点
/// - 柔和的装饰性背景元素
/// - 统计数据以优雅的方式呈现
/// - 温柔、诗意、有呼吸感
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

    // 老用户：精美的时间展示
    return _buildExistingUserHeader(context, ref);
  }

  /// 新用户头部 - 诗意的欢迎
  Widget _buildNewUserHeader(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warmPeachLight.withValues(alpha: 0.6),
                AppColors.timeBeigeWarm,
                AppColors.timeBeige,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.warmPeach.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 装饰性图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warmPeachDeep.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Iconsax.book_1,
                  size: 24,
                  color: AppColors.warmPeachDeep.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '你好，',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray500, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '欢迎来到拾光',
                style: AppTypography.title(context).copyWith(
                  color: AppColors.warmGray800,
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 16),

              // 分隔线
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.warmPeachDeep.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '这是一本空白的时间之书',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray600, height: 1.8),
              ),
              const SizedBox(height: 4),
              Text(
                '所有的温情和感动，都将从此刻开始',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray500, height: 1.8),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: AppDurations.entrance, curve: AppCurves.smooth)
        .slideY(begin: 0.02, end: 0);
  }

  /// 老用户头部 - 精美的时间展示
  Widget _buildExistingUserHeader(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdayNames[now.weekday - 1];
    final letterCount = ref.watch(lettersCountProvider);

    // 根据时间段生成问候语和氛围色
    final (greeting, moodColor) = _getGreetingAndMood(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主卡片：问候语 + 日期 + 天数
        Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    moodColor.withValues(alpha: 0.15),
                    moodColor.withValues(alpha: 0.06),
                    AppColors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: moodColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部：日期行
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: moodColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${now.month}月${now.day}日 $weekday',
                          style: AppTypography.caption(context).copyWith(
                            color: moodColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 圈子标签
                      if (circleInfo.name.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warmGray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.people,
                                size: 12,
                                color: AppColors.warmGray500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                circleInfo.name,
                                style: AppTypography.caption(context).copyWith(
                                  color: AppColors.warmGray600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 问候语
                  Text(
                    greeting,
                    style: AppTypography.title(context).copyWith(
                      color: AppColors.warmGray800,
                      fontWeight: FontWeight.w500,
                      fontSize: 28,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 副文案
                  Text(
                    _getSubtitle(now),
                    style: AppTypography.body(
                      context,
                    ).copyWith(color: AppColors.warmGray500),
                  ),

                  const SizedBox(height: 24),

                  // 分隔线
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warmGray200,
                          AppColors.warmGray200.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 底部：统计数据
                  Row(
                    children: [
                      // 天数统计
                      _buildStatChip(
                        context,
                        icon: Iconsax.calendar_1,
                        value: '第 ${circleInfo.daysSinceBirth} 天',
                        color: AppColors.warmOrangeDeep,
                      ),
                      const SizedBox(width: 12),

                      // 回忆数量
                      _buildStatChip(
                        context,
                        icon: Iconsax.gallery,
                        value: '$momentCount 条回忆',
                        color: AppColors.warmPeachDeep,
                      ),
                      const SizedBox(width: 12),

                      // 信件数量
                      _buildStatChip(
                        context,
                        icon: Iconsax.sms,
                        value: '$letterCount 封信',
                        color: AppColors.calmBlueDeep,
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: AppDurations.entrance, curve: AppCurves.smooth)
            .slideY(begin: 0.02, end: 0),
      ],
    );
  }

  /// 统计标签
  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTypography.caption(
              context,
            ).copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// 根据时间段返回问候语和氛围色
  (String, Color) _getGreetingAndMood(int hour) {
    if (hour >= 5 && hour < 9) {
      return ('早安，新的一天', AppColors.warmOrangeDeep);
    } else if (hour >= 9 && hour < 12) {
      return ('上午好', AppColors.warmPeachDeep);
    } else if (hour >= 12 && hour < 14) {
      return ('午安，休息一下', AppColors.softGreenDeep);
    } else if (hour >= 14 && hour < 18) {
      return ('下午好', AppColors.calmBlueDeep);
    } else if (hour >= 18 && hour < 22) {
      return ('晚上好', AppColors.mutedVioletDeep);
    } else {
      return ('夜深了，早点休息', AppColors.mutedVioletDeep);
    }
  }

  /// 副标题文案
  String _getSubtitle(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 9) {
      return '记录今天的美好瞬间';
    } else if (hour >= 9 && hour < 12) {
      return '翻阅时光，重温温暖';
    } else if (hour >= 12 && hour < 14) {
      return '午后时光，适合回忆';
    } else if (hour >= 14 && hour < 18) {
      return '时间在流淌，记忆在沉淀';
    } else if (hour >= 18 && hour < 22) {
      return '今天有什么值得记住的事吗？';
    } else {
      return '静静地，翻阅属于你的时光';
    }
  }
}
