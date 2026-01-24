import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_utils.dart';

/// 侧边筛选抽屉 - 时间线筛选
///
/// 设计理念：
/// - 从右侧滑入的半透明抽屉
/// - 分组清晰的筛选选项
/// - 温柔的视觉风格
class FilterDrawer extends ConsumerWidget {
  final VoidCallback onClose;

  const FilterDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timelineFilterProvider);
    final years = ref.watch(availableYearsProvider);
    final authors = ref.watch(availableAuthorsProvider);
    final filteredMoments = ref.watch(filteredMomentsProvider);

    return Stack(
      children: [
        // 背景遮罩
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: AppColors.warmGray900.withValues(alpha: 0.3),
            ),
          ),
        ),

        // 抽屉主体
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmGray900.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(-8, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 头部
                  _buildHeader(context, ref, filteredMoments.length),

                  // 筛选选项
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // 排序
                        _buildSection(
                          context,
                          icon: Iconsax.sort,
                          title: '排序',
                          children: [
                            _FilterChip(
                              label: '最新优先',
                              isSelected: filter.sortOrder == SortOrder.desc,
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setSortOrder(SortOrder.desc),
                            ),
                            _FilterChip(
                              label: '最早优先',
                              isSelected: filter.sortOrder == SortOrder.asc,
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setSortOrder(SortOrder.asc),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 年份
                        _buildSection(
                          context,
                          icon: Iconsax.calendar_1,
                          title: '年份',
                          children: [
                            _FilterChip(
                              label: '全部',
                              isSelected: filter.filterYear == 'ALL',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setYear('ALL'),
                            ),
                            ...years.map(
                              (year) => _FilterChip(
                                label: '$year年',
                                isSelected: filter.filterYear == year,
                                onTap:
                                    () => ref
                                        .read(timelineFilterProvider.notifier)
                                        .setYear(year),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 发帖人
                        _buildSection(
                          context,
                          icon: Iconsax.user,
                          title: '发帖人',
                          children: [
                            _FilterChip(
                              label: '所有人',
                              isSelected: filter.filterAuthor == 'ALL',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setAuthor('ALL'),
                            ),
                            ...authors.map(
                              (author) => _FilterChip(
                                label: author.displayName,
                                avatar: author.avatar,
                                isSelected: filter.filterAuthor == author.id,
                                onTap:
                                    () => ref
                                        .read(timelineFilterProvider.notifier)
                                        .setAuthor(author.id),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 类型
                        _buildSection(
                          context,
                          icon: Iconsax.document,
                          title: '类型',
                          children: [
                            _FilterChip(
                              label: '全部',
                              isSelected: filter.filterType == 'ALL',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setType('ALL'),
                            ),
                            _FilterChip(
                              label: '图片',
                              icon: Iconsax.gallery,
                              isSelected: filter.filterType == 'IMAGE',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setType('IMAGE'),
                            ),
                            _FilterChip(
                              label: '视频',
                              icon: Iconsax.video,
                              isSelected: filter.filterType == 'VIDEO',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setType('VIDEO'),
                            ),
                            _FilterChip(
                              label: '语音',
                              icon: Iconsax.microphone,
                              isSelected: filter.filterType == 'AUDIO',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setType('AUDIO'),
                            ),
                            _FilterChip(
                              label: '文字',
                              icon: Iconsax.text,
                              isSelected: filter.filterType == 'TEXT',
                              onTap:
                                  () => ref
                                      .read(timelineFilterProvider.notifier)
                                      .setType('TEXT'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 底部操作栏
                  _buildFooter(context, ref, filter.isFiltering),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 头部
  Widget _buildHeader(BuildContext context, WidgetRef ref, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.warmGray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('筛选', style: AppTypography.title(context)),
                const SizedBox(height: 4),
                Text(
                  '$count 条记录',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(color: AppColors.warmGray400),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Iconsax.close_circle),
            color: AppColors.warmGray400,
          ),
        ],
      ),
    );
  }

  /// 筛选分组
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.warmGray400),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.caption(context).copyWith(
                  color: AppColors.warmGray500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 选项
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }

  /// 底部操作栏
  Widget _buildFooter(BuildContext context, WidgetRef ref, bool isFiltering) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.warmGray100)),
      ),
      child: Row(
        children: [
          // 重置按钮
          if (isFiltering)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(timelineFilterProvider.notifier).reset();
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warmGray100,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Center(
                    child: Text(
                      '重置',
                      style: AppTypography.body(context).copyWith(
                        color: AppColors.warmGray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (isFiltering) const SizedBox(width: 12),

          // 确定按钮
          Expanded(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.warmGray800,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Center(
                  child: Text(
                    '完成',
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 筛选标签
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.warmOrange.withValues(alpha: 0.2)
                  : AppColors.warmGray50,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.warmOrangeDark.withValues(alpha: 0.3)
                    : AppColors.warmGray150,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[
              ClipOval(child: ImageUtils.buildAvatar(url: avatar!, size: 16)),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color:
                    isSelected
                        ? AppColors.warmOrangeDark
                        : AppColors.warmGray400,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.caption(context).copyWith(
                color:
                    isSelected
                        ? AppColors.warmOrangeDark
                        : AppColors.warmGray600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Iconsax.tick_circle5,
                size: 12,
                color: AppColors.warmOrangeDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
