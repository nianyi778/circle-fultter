import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';

/// 记录统计卡片 - 最近30天数据概览
///
/// 设计理念：
/// - 用数据展示"时间正在被填满"的感觉
/// - 简洁、有信息量、不依赖图片
/// - 点击跳转到时间线
class RecordStatsCard extends ConsumerWidget {
  const RecordStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);

    // 计算最近30天的统计数据
    final stats = _calculateStats(moments);

    // 没有任何记录时不显示
    if (moments.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.go('/timeline'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warmGray150, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child:
            stats.totalCount == 0
                ? _buildEmptyState(context)
                : _buildStatsContent(context, stats, moments),
      ),
    );
  }

  /// 计算最近30天的统计数据
  _RecordStats _calculateStats(List<Moment> moments) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentMoments =
        moments.where((m) {
          return m.timestamp.isAfter(thirtyDaysAgo);
        }).toList();

    int imageCount = 0;
    int videoCount = 0;
    int audioCount = 0;
    int textCount = 0;

    for (final m in recentMoments) {
      switch (m.mediaType) {
        case MediaType.image:
          imageCount++;
          break;
        case MediaType.video:
          videoCount++;
          break;
        case MediaType.audio:
          audioCount++;
          break;
        case MediaType.text:
          textCount++;
          break;
      }
    }

    return _RecordStats(
      totalCount: recentMoments.length,
      imageCount: imageCount,
      videoCount: videoCount,
      audioCount: audioCount,
      textCount: textCount,
    );
  }

  /// 空状态（最近30天无记录）
  Widget _buildEmptyState(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '最近 30 天',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
              const SizedBox(height: 8),
              Text(
                '还没有记录',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray500),
              ),
              const SizedBox(height: 4),
              Text(
                '留下这一刻吧',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray300),
              ),
            ],
          ),
        ),
        Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.warmGray300),
      ],
    );
  }

  /// 有数据时的统计内容
  Widget _buildStatsContent(
    BuildContext context,
    _RecordStats stats,
    List<Moment> allMoments,
  ) {
    // 构建统计项列表
    final statItems = <String>[];
    statItems.add('${stats.totalCount} 条记录');
    if (stats.imageCount > 0) {
      statItems.add('${stats.imageCount} 张照片');
    }
    if (stats.videoCount > 0) {
      statItems.add('${stats.videoCount} 段视频');
    }
    if (stats.audioCount > 0) {
      statItems.add('${stats.audioCount} 段语音');
    }

    // 获取最近一条记录的时间
    final latestMoment = allMoments.isNotEmpty ? allMoments.first : null;
    final latestTimeText =
        latestMoment != null ? _formatLatestTime(latestMoment.timestamp) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近 30 天',
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400),
            ),
            Icon(Iconsax.arrow_right_3, size: 14, color: AppColors.warmGray300),
          ],
        ),

        const SizedBox(height: 12),

        // 统计数据
        Text.rich(TextSpan(children: _buildStatSpans(context, statItems))),

        // 最近一条时间
        if (latestTimeText != null) ...[
          const SizedBox(height: 12),
          Text(
            '最近一条：$latestTimeText',
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray400),
          ),
        ],
      ],
    );
  }

  /// 构建统计文本的 TextSpan 列表
  List<InlineSpan> _buildStatSpans(BuildContext context, List<String> items) {
    final spans = <InlineSpan>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // 分离数字和文字
      final match = RegExp(r'^(\d+)(.+)$').firstMatch(item);
      if (match != null) {
        // 数字部分 - 加粗
        spans.add(
          TextSpan(
            text: match.group(1),
            style: AppTypography.subtitle(context).copyWith(
              color: AppColors.warmGray800,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        // 文字部分
        spans.add(
          TextSpan(
            text: match.group(2),
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.warmGray600),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: item,
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.warmGray600),
          ),
        );
      }

      // 添加分隔符
      if (i < items.length - 1) {
        spans.add(
          TextSpan(
            text: '  ·  ',
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.warmGray300),
          ),
        );
      }
    }

    return spans;
  }

  /// 格式化最近一条时间
  String _formatLatestTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inHours < 24 && now.day == time.day) {
      // 今天
      return '今天 ${_formatTime(time)}';
    } else if (diff.inHours < 48 && now.day - time.day == 1) {
      // 昨天
      return '昨天 ${_formatTime(time)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} 天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 统计数据模型
class _RecordStats {
  final int totalCount;
  final int imageCount;
  final int videoCount;
  final int audioCount;
  final int textCount;

  const _RecordStats({
    required this.totalCount,
    required this.imageCount,
    required this.videoCount,
    required this.audioCount,
    required this.textCount,
  });
}

/// 向后兼容的别名
@Deprecated('Use RecordStatsCard instead')
typedef RecentMomentsPreview = RecordStatsCard;
