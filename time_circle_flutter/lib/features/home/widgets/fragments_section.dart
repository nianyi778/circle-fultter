import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';

/// 时光碎片统计区域
///
/// 显示声音和视频的数量统计，匹配 Web 版本设计
class FragmentsSection extends ConsumerWidget {
  const FragmentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);

    // 计算统计数据
    final audioCount =
        moments.where((m) => m.mediaType == MediaType.audio).length;
    final videoCount =
        moments.where((m) => m.mediaType == MediaType.video).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 标题
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.warmGray400,
              ),
              const SizedBox(width: 8),
              Text(
                '时光碎片',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.warmGray800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 统计卡片网格
          Row(
            children: [
              // 声音统计卡片 - 橙色主题
              Expanded(
                child: _StatsCard(
                  icon: Icons.mic_rounded,
                  iconColor: const Color(0xFFEA580C), // orange-600
                  bgColor: const Color(0xFFFFFBF6), // warm orange bg
                  borderColor: const Color(
                    0xFFFED7AA,
                  ).withValues(alpha: 0.5), // orange-200
                  label: '声音',
                  count: audioCount,
                  description: '段语音记录',
                ),
              ),
              const SizedBox(width: 16),

              // 视频统计卡片 - 灰色主题
              Expanded(
                child: _StatsCard(
                  icon: Icons.videocam_rounded,
                  iconColor: AppColors.warmGray700,
                  bgColor: AppColors.warmGray100,
                  borderColor: AppColors.warmGray200.withValues(alpha: 0.5),
                  label: '视频',
                  count: videoCount,
                  description: '个生动瞬间',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 统计卡片组件
class _StatsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String label;
  final int count;
  final String description;

  const _StatsCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
    required this.count,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Stack(
        children: [
          // 背景装饰图标
          Positioned(
            right: -16,
            bottom: -16,
            child: Transform.rotate(
              angle: 0.2, // ~12 degrees
              child: Icon(
                icon,
                size: 100,
                color: iconColor.withValues(alpha: 0.12),
              ),
            ),
          ),

          // 内容
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标签
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: iconColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),

              // 大数字
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 36,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),

              // 描述文字
              Text(
                description,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: iconColor.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
