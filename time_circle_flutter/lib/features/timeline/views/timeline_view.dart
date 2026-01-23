import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/user.dart';
import '../../../core/models/moment.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/widgets/comment_drawer.dart';
import '../widgets/feed_card.dart';

class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({super.key});

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {
  bool _isFilterOpen = false;
  Moment? _replyingMoment; // 当前回复的时刻

  void _openCommentDrawer(Moment moment) {
    setState(() {
      _replyingMoment = moment;
    });
  }

  void _closeCommentDrawer() {
    setState(() {
      _replyingMoment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moments = ref.watch(filteredMomentsProvider);
    final childInfo = ref.watch(childInfoProvider);
    final filter = ref.watch(timelineFilterProvider);
    final years = ref.watch(availableYearsProvider);
    final authors = ref.watch(availableAuthorsProvider);
    final hasMoments = moments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部圈子信息条
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 0,
                toolbarHeight: 72,
                backgroundColor: AppColors.white.withValues(alpha: 0.95),
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.warmGray100,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // 圈子头像和年份
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                  boxShadow: AppShadows.subtle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.warmGray100,
                                      AppColors.warmGray200,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    childInfo.name.length > 2
                                        ? childInfo.name.substring(0, 2)
                                        : childInfo.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warmGray600,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmGray800,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    childInfo.shortAgeLabel,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // 圈子名称和成员
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${childInfo.name}的回忆圈',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                // 成员头像叠放
                                Row(
                                  children: [
                                    _buildMiniAvatar(
                                      'https://picsum.photos/seed/dad/100/100',
                                    ),
                                    Transform.translate(
                                      offset: const Offset(-6, 0),
                                      child: _buildMiniAvatar(
                                        'https://picsum.photos/seed/mom/100/100',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 筛选按钮
                          GestureDetector(
                            onTap: () {
                              setState(() => _isFilterOpen = !_isFilterOpen);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    filter.isFiltering || _isFilterOpen
                                        ? AppColors.warmGray800
                                        : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.filter,
                                size: 20,
                                color:
                                    filter.isFiltering || _isFilterOpen
                                        ? AppColors.white
                                        : AppColors.warmGray500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => context.push('/settings'),
                            icon: const Icon(Iconsax.more),
                            color: AppColors.warmGray500,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 筛选状态提示条
              if (filter.isFiltering)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.md,
                      AppSpacing.pagePadding,
                      0,
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(timelineFilterProvider.notifier).reset();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: AppColors.warmGray200,
                              width: 1,
                            ),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '筛选中: ',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.warmGray400),
                              ),
                              _buildFilterChips(filter, years, authors),
                              const SizedBox(width: 8),
                              Icon(
                                Iconsax.close_circle,
                                size: 14,
                                color: AppColors.warmGray400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms),
                  ),
                ),

              // 时间线内容
              if (hasMoments) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.lg,
                    AppSpacing.pagePadding,
                    0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final moment = moments[index];
                      return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.cardGap,
                            ),
                            child: FeedCard(
                              moment: moment,
                              onTap: () => context.push('/moment/${moment.id}'),
                              onDelete:
                                  (id) => _showDeleteConfirm(context, ref, id),
                              onShareToWorld:
                                  (id) => _showShareToWorld(context, ref, id),
                              onReply: () => _openCommentDrawer(moment),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: Duration(
                              milliseconds: 50 * (index.clamp(0, 5)),
                            ),
                            curve: Curves.easeOut,
                          )
                          .slideY(begin: 0.05, end: 0);
                    }, childCount: moments.length),
                  ),
                ),

                // 底部提示
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Text(
                          '到底了',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: AppColors.warmGray400,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '暂时就这么多。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.warmGray300),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                // 空状态
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyTimeline(isFiltering: filter.isFiltering),
                ),

              // 底部安全区域
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // 筛选遮罩层
          if (_isFilterOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isFilterOpen = false),
                child: Container(
                  color: AppColors.warmGray900.withValues(alpha: 0.1),
                ),
              ),
            ),

          // 筛选下拉菜单
          if (_isFilterOpen)
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              right: AppSpacing.pagePadding,
              child: _FilterDropdown(
                filter: filter,
                years: years,
                authors: authors,
                momentsCount: moments.length,
                onClose: () => setState(() => _isFilterOpen = false),
              ).animate().fadeIn(duration: 150.ms).slideY(begin: -0.05, end: 0),
            ),

          // 评论抽屉
          if (_replyingMoment != null)
            Positioned.fill(
              child: CommentDrawer(
                moment: _replyingMoment!,
                onClose: _closeCommentDrawer,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    TimelineFilterState filter,
    List<String> years,
    List<User> authors,
  ) {
    final chips = <String>[];

    if (filter.filterYear != 'ALL') {
      chips.add('${filter.filterYear}年');
    }
    if (filter.filterAuthor != 'ALL') {
      final author = authors.firstWhere(
        (a) => a.id == filter.filterAuthor,
        orElse: () => const User(id: '', name: '未知', avatar: ''),
      );
      chips.add(author.name);
    }
    if (filter.filterType != 'ALL') {
      chips.add(_getTypeLabel(filter.filterType));
    }
    if (filter.sortOrder == SortOrder.asc) {
      chips.add('最早优先');
    }

    if (chips.isEmpty) {
      chips.add('排序');
    }

    return Text(
      chips.join(' · '),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.warmGray700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'VIDEO':
        return '视频';
      case 'AUDIO':
        return '音频';
      case 'IMAGE':
        return '图片';
      case 'TEXT':
        return '纯文字';
      default:
        return '全部';
    }
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('删除这条记录？'),
            content: const Text('删除后无法恢复，确定要继续吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  '取消',
                  style: TextStyle(color: AppColors.warmGray500),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(momentsProvider.notifier).deleteMoment(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('已删除'),
                        ],
                      ),
                      backgroundColor: AppColors.warmGray800,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  );
                },
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showShareToWorld(BuildContext context, WidgetRef ref, String id) {
    // TODO: 实现分享到世界功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Iconsax.global, color: AppColors.white, size: 18),
            SizedBox(width: 8),
            Text('分享到世界功能开发中...'),
          ],
        ),
        backgroundColor: AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget _buildMiniAvatar(String url) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 1),
      ),
      child: ImageUtils.buildAvatar(url: url, size: 16),
    );
  }
}

/// 筛选下拉菜单
class _FilterDropdown extends ConsumerWidget {
  final TimelineFilterState filter;
  final List<String> years;
  final List<User> authors;
  final int momentsCount;
  final VoidCallback onClose;

  const _FilterDropdown({
    required this.filter,
    required this.years,
    required this.authors,
    required this.momentsCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGray900.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 可滚动区域
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间与排序
                  _SectionHeader(icon: Iconsax.calendar_1, label: '时间与排序'),
                  _FilterOption(
                    label: '最新优先',
                    icon: Iconsax.arrow_down,
                    isSelected: filter.sortOrder == SortOrder.desc,
                    onTap: () {
                      ref
                          .read(timelineFilterProvider.notifier)
                          .setSortOrder(SortOrder.desc);
                    },
                  ),
                  _FilterOption(
                    label: '最早优先',
                    icon: Iconsax.arrow_up,
                    isSelected: filter.sortOrder == SortOrder.asc,
                    onTap: () {
                      ref
                          .read(timelineFilterProvider.notifier)
                          .setSortOrder(SortOrder.asc);
                    },
                  ),
                  _Divider(),
                  _FilterOption(
                    label: '全部年份',
                    isSelected: filter.filterYear == 'ALL',
                    onTap: () {
                      ref.read(timelineFilterProvider.notifier).setYear('ALL');
                    },
                  ),
                  ...years.map(
                    (year) => _FilterOption(
                      label: '$year年',
                      isSelected: filter.filterYear == year,
                      onTap: () {
                        ref.read(timelineFilterProvider.notifier).setYear(year);
                      },
                    ),
                  ),

                  // 发帖人
                  _SectionHeader(icon: Iconsax.user, label: '发帖人'),
                  _FilterOption(
                    label: '所有人',
                    isSelected: filter.filterAuthor == 'ALL',
                    onTap: () {
                      ref
                          .read(timelineFilterProvider.notifier)
                          .setAuthor('ALL');
                    },
                  ),
                  ...authors.map(
                    (author) => _FilterOption(
                      label: author.name,
                      avatar: author.avatar,
                      isSelected: filter.filterAuthor == author.id,
                      onTap: () {
                        ref
                            .read(timelineFilterProvider.notifier)
                            .setAuthor(author.id);
                      },
                    ),
                  ),

                  // 类型
                  _SectionHeader(icon: Iconsax.document, label: '类型'),
                  _FilterOption(
                    label: '全部类型',
                    isSelected: filter.filterType == 'ALL',
                    onTap: () {
                      ref.read(timelineFilterProvider.notifier).setType('ALL');
                    },
                  ),
                  _FilterOption(
                    label: '视频',
                    icon: Iconsax.video,
                    isSelected: filter.filterType == 'VIDEO',
                    onTap: () {
                      ref
                          .read(timelineFilterProvider.notifier)
                          .setType('VIDEO');
                    },
                  ),
                  _FilterOption(
                    label: '音频',
                    icon: Iconsax.microphone_2,
                    isSelected: filter.filterType == 'AUDIO',
                    onTap: () {
                      ref
                          .read(timelineFilterProvider.notifier)
                          .setType('AUDIO');
                    },
                  ),
                  _FilterOption(
                    label: '图片',
                    icon: Iconsax.image,
                    isSelected: filter.filterType == 'IMAGE',
                    onTap: () {
                      ref
                          .read(timelineFilterProvider.notifier)
                          .setType('IMAGE');
                    },
                  ),
                  _FilterOption(
                    label: '纯文字',
                    icon: Iconsax.text,
                    isSelected: filter.filterType == 'TEXT',
                    onTap: () {
                      ref.read(timelineFilterProvider.notifier).setType('TEXT');
                    },
                  ),
                ],
              ),
            ),
          ),

          // 底部操作栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.warmGray100)),
              color: AppColors.warmGray50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$momentsCount 条记录',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warmGray400,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(timelineFilterProvider.notifier).reset();
                    onClose();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.refresh,
                        size: 14,
                        color: AppColors.warmGray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '重置',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warmGray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 分区标题
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.warmGray50.withValues(alpha: 0.8),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.warmGray400),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.warmGray400,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 筛选选项
class _FilterOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color:
            isSelected
                ? AppColors.warmOrange.withValues(alpha: 0.3)
                : Colors.transparent,
        child: Row(
          children: [
            if (avatar != null) ...[
              ImageUtils.buildAvatar(url: avatar!, size: 16),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color:
                    isSelected
                        ? AppColors.warmOrangeDark
                        : AppColors.warmGray400,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? AppColors.warmGray900
                          : AppColors.warmGray600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.tick_circle5,
                size: 16,
                color: AppColors.warmOrangeDark,
              ),
          ],
        ),
      ),
    );
  }
}

/// 分隔线
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 1,
      color: AppColors.warmGray100,
    );
  }
}

/// 空状态
class _EmptyTimeline extends StatelessWidget {
  final bool isFiltering;

  const _EmptyTimeline({this.isFiltering = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltering ? Iconsax.filter : Iconsax.magic_star,
                color: AppColors.warmGray300,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            if (isFiltering) ...[
              Text(
                '没有找到符合条件的记录',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.warmGray500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Consumer(
                builder:
                    (context, ref, _) => GestureDetector(
                      onTap: () {
                        ref.read(timelineFilterProvider.notifier).reset();
                      },
                      child: Text(
                        '清除所有筛选',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warmGray400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
              ),
            ] else ...[
              Text(
                '这一条时间线，\n会慢慢被你们填满。',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.warmGray500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '不必着急，时间一直在发生。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.warmGray400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
