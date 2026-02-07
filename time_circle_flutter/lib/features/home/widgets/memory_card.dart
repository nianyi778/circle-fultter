import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';
import '../../../core/utils/image_utils.dart';
import '../../create/views/create_moment_view.dart';

/// 显示创建时刻弹窗
void _showCreateModal(BuildContext context, {String? hint}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateMomentModal(hint: hint);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: AppCurves.enter),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: AppDurations.pageTransition,
      reverseTransitionDuration: AppDurations.normal,
    ),
  );
}

/// 回忆卡片 - 全新设计
///
/// 设计理念：
/// - 精致的玻璃拟态效果
/// - 优雅的图片展示
/// - 多条回忆可滑动切换
/// - 诗意的空状态
class MemoryCard extends ConsumerWidget {
  const MemoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyMoments = ref.watch(hasAnyMomentsProvider);
    final lastYearMoments = ref.watch(lastYearTodayMomentsProvider);
    final hasLastYearData = ref.watch(hasLastYearDataProvider);

    // 场景1: 新用户 - 显示「留下第一刻」
    if (!hasAnyMoments) {
      return const _FirstMomentCard();
    }

    // 场景4: 圈子不满一年 - 显示引导卡片
    if (!hasLastYearData) {
      return const _WelcomeCard();
    }

    // 场景3: 满一年但去年今天没有记录
    if (lastYearMoments.isEmpty) {
      return const _EmptyMemoryCard();
    }

    // 场景2: 有去年今天的记录 - 使用沉浸式滑动卡片
    return _MemorySwipeCard(moments: lastYearMoments);
  }
}

/// 沉浸式滑动回忆卡片
class _MemorySwipeCard extends ConsumerStatefulWidget {
  final List<Moment> moments;

  const _MemorySwipeCard({required this.moments});

  @override
  ConsumerState<_MemorySwipeCard> createState() => _MemorySwipeCardState();
}

class _MemorySwipeCardState extends ConsumerState<_MemorySwipeCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleInfo = ref.watch(childInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.warmOrangeDeep,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '去年的今天',
                style: AppTypography.subtitle(context).copyWith(
                  color: AppColors.warmGray800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.moments.length > 1)
                Text(
                  '${_currentPage + 1} / ${widget.moments.length}',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(color: AppColors.warmGray400),
                ),
            ],
          ),
        ),

        // 卡片区域
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.moments.length,
            itemBuilder: (context, index) {
              return _MemorySingleCard(
                moment: widget.moments[index],
                timeLabel: circleInfo.timeLabel,
              );
            },
          ),
        ),

        // 页面指示器（多于1条时显示）
        if (widget.moments.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: _PageIndicator(
                count: widget.moments.length,
                currentIndex: _currentPage,
              ),
            ),
          ),
      ],
    );
  }
}

/// 单张回忆卡片 - 精致设计
class _MemorySingleCard extends StatelessWidget {
  final Moment moment;
  final String timeLabel;

  const _MemorySingleCard({required this.moment, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    final hasImage = moment.mediaUrls.isNotEmpty;
    final coverUrl = hasImage ? moment.mediaUrls.first : null;

    return GestureDetector(
      onTap: () => context.push('/moment/${moment.id}'),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.paper,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景层
            if (coverUrl != null)
              // 有图片：显示图片
              ImageUtils.buildImage(url: coverUrl, fit: BoxFit.cover)
            else
              // 无图片：显示精美渐变背景
              _buildGradientBackground(),

            // 渐变遮罩层 - 更精致的多层渐变
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),

            // 顶部标签
            Positioned(top: 16, left: 16, child: _buildTopBadge(context)),

            // 底部内容区
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 内容文字
                  if (moment.content.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '"${moment.content}"',
                        style: AppTypography.body(context).copyWith(
                          color: Colors.white,
                          height: 1.6,
                          fontSize: 15,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // 日期和年龄
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(moment.timestamp),
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      _buildDot(),
                      Text(
                        timeLabel.isEmpty ? '刚开始' : timeLabel,
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const Spacer(),
                      // 查看详情按钮
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '查看',
                              style: AppTypography.caption(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmPeach,
            AppColors.warmOrangeLight,
            AppColors.warmPeachLight,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 装饰性圆形
          Positioned(
            right: -50,
            top: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmOrangeDeep.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmPeachDeep.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.warmOrangeDeep,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '时光漫游',
            style: AppTypography.caption(context).copyWith(
              color: AppColors.warmGray700,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// 页面指示器 - 精美设计
class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warmGray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: AppDurations.fast,
            curve: AppCurves.smooth,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  isActive ? AppColors.warmOrangeDeep : AppColors.warmGray300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// 新用户引导卡片 - 精美设计
class _FirstMomentCard extends StatelessWidget {
  const _FirstMomentCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateModal(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.paper,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 精美渐变背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.warmGray50,
                      AppColors.warmGray100,
                      AppColors.timeBeigeWarm,
                    ],
                  ),
                ),
              ),
            ),

            // 装饰性元素
            Positioned(
              right: -40,
              top: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.warmPeach.withValues(alpha: 0.3),
                      AppColors.warmPeach.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: -30,
              bottom: 40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.warmOrangeLight.withValues(alpha: 0.4),
                      AppColors.warmOrangeLight.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // 内容
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.warmOrangeDeep.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Iconsax.add_circle,
                      size: 28,
                      color: AppColors.warmOrangeDeep.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 标题
                  Text(
                    '留下第一刻',
                    style: AppTypography.title(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.warmGray800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 副标题
                  Text(
                    '一张照片，或是一句想说的话',
                    style: AppTypography.body(
                      context,
                    ).copyWith(color: AppColors.warmGray500),
                  ),
                  const SizedBox(height: 20),

                  // 按钮
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warmGray800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '开始记录',
                          style: AppTypography.body(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 有记录但不满一年的引导卡片 - 精美设计
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.paper,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 背景
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warmPeachLight,
                  AppColors.warmPeach.withValues(alpha: 0.4),
                  AppColors.white,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.warmPeachDeep,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '时间的开始',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.warmGray600,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 主文案
                Text(
                  '这里，会慢慢被时间填满',
                  style: AppTypography.subtitle(
                    context,
                  ).copyWith(color: AppColors.warmGray800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '明年的今天，你会在这里看见今天留下的痕迹',
                  style: AppTypography.body(
                    context,
                  ).copyWith(color: AppColors.warmGray500, height: 1.6),
                ),

                const SizedBox(height: 20),

                // 装饰性进度条
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.warmGray200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.1, // 10% 进度
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.warmPeachDeep,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '距离一周年',
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.warmGray400),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 装饰性圆圈
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmPeachDeep.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 满一年但去年今天没有记录 - 精美设计
class _EmptyMemoryCard extends StatelessWidget {
  const _EmptyMemoryCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.warmGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '去年的今天',
                style: AppTypography.subtitle(context).copyWith(
                  color: AppColors.warmGray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // 空状态卡片
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.warmGray150, width: 1),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: [
              // 图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.calendar_remove,
                  size: 28,
                  color: AppColors.warmGray400,
                ),
              ),
              const SizedBox(height: 20),

              // 空状态文案
              Text(
                '去年的这一天，没有留下记录',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray500),
              ),
              const SizedBox(height: 8),
              Text(
                '时间有它自己的节奏',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
