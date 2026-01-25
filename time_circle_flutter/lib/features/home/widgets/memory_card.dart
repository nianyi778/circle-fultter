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

/// 回忆卡片 - 重新设计
///
/// 设计理念：
/// - 全宽沉浸式图片卡片
/// - 渐变遮罩承载文字
/// - 多条回忆可滑动切换
/// - 280px 高度，24px 圆角
///
/// 场景1: 新用户（无任何记录）→ 显示「留下第一刻」引导卡片
/// 场景2: 有去年今天的数据 → 显示沉浸式回忆卡片
/// 场景3: 无去年今天数据但圈子满一年 → 显示"去年的今天没有记录"
/// 场景4: 圈子不满一年但有记录 → 显示温暖的引导卡片
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
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // 滑动卡片区
          PageView.builder(
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

          // 页面指示器（多于1条时显示）
          if (widget.moments.length > 1)
            Positioned(
              bottom: 16,
              right: 20,
              child: _PageIndicator(
                count: widget.moments.length,
                currentIndex: _currentPage,
              ),
            ),
        ],
      ),
    );
  }
}

/// 单张回忆卡片 - 沉浸式设计
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
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.soft,
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
              // 无图片：显示渐变背景
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.warmPeach.withValues(alpha: 0.6),
                      AppColors.warmOrangeLight.withValues(alpha: 0.4),
                      AppColors.timeBeigeLight,
                    ],
                  ),
                ),
              ),

            // 渐变遮罩层
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // 顶部标签
            Positioned(
              top: 16,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  '去年的今天',
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.warmOrangeDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

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
                    Text(
                      '"${moment.content}"',
                      style: AppTypography.body(context).copyWith(
                        color: Colors.white,
                        height: 1.6,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  // 日期和年龄
                  Row(
                    children: [
                      Text(
                        _formatDate(moment.timestamp),
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      _buildDot(),
                      Text(
                        timeLabel.isEmpty ? '刚开始' : timeLabel,
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: Colors.white.withValues(alpha: 0.8)),
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

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// 页面指示器 - 小圆点样式
class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.smooth,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// 新用户引导卡片 - 「留下第一刻」
class _FirstMomentCard extends StatelessWidget {
  const _FirstMomentCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateModal(context),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 渐变背景
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.warmGray100,
                    AppColors.warmGray50,
                    AppColors.timeBeige,
                  ],
                ),
              ),
            ),

            // 背景装饰 - 大号笔图标
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.04,
                child: Icon(
                  Iconsax.edit,
                  size: 200,
                  color: AppColors.warmGray900,
                ),
              ),
            ),

            // 内容
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 标题
                  Text(
                    '留下第一刻',
                    style: AppTypography.title(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  // 副标题
                  Text(
                    '一张照片，或是一句想说的话。',
                    style: AppTypography.body(
                      context,
                    ).copyWith(color: AppColors.warmGray500),
                  ),
                  const SizedBox(height: 20),

                  // 开始记录按钮
                  Row(
                    children: [
                      Text(
                        '开始记录',
                        style: AppTypography.body(context).copyWith(
                          color: AppColors.warmOrangeDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 18,
                        color: AppColors.warmOrangeDark,
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
}

/// 有记录但不满一年的引导卡片
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // 稍矮一点
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 渐变背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warmPeach.withValues(alpha: 0.4),
                  AppColors.warmPeachLight.withValues(alpha: 0.6),
                  AppColors.timeBeigeLight,
                ],
              ),
            ),
          ),

          // 装饰性圆圈
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmPeachDeep.withValues(alpha: 0.08),
              ),
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 小标签
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.warmPeachDeep.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '时间的开始',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.warmGray500,
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
                  ).copyWith(color: AppColors.warmGray800),
                ),
                const SizedBox(height: 8),
                Text(
                  '明年的今天，你会在这里看见今天留下的痕迹。',
                  style: AppTypography.body(
                    context,
                  ).copyWith(color: AppColors.warmGray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 满一年但去年今天没有记录
class _EmptyMemoryCard extends StatelessWidget {
  const _EmptyMemoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160, // 更矮
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warmGray150, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.warmGray300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '去年的今天',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray500, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 空状态文案
          Text(
            '去年的这一天，没有留下记录。',
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.warmGray400),
          ),
          const SizedBox(height: 4),
          Text(
            '时间有它自己的节奏。',
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray300),
          ),
        ],
      ),
    );
  }
}
