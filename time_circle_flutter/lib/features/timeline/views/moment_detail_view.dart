import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/media_viewer.dart';
import '../../../shared/widgets/context_tags_view.dart';
import '../../../shared/widgets/future_message_card.dart';
import '../../../shared/widgets/detail_action_bar.dart';
import '../../../shared/widgets/detail_app_bar.dart';

/// 记录详情页（沉浸回看）
class MomentDetailView extends ConsumerWidget {
  final String momentId;

  const MomentDetailView({super.key, required this.momentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moment = ref.watch(momentByIdProvider(momentId));

    if (moment == null) {
      return Scaffold(
        backgroundColor: AppColors.timeBeige,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.document_filter,
                size: 48,
                color: AppColors.warmGray300,
              ),
              const SizedBox(height: 16),
              Text(
                '这一刻，可能已经被你带走了。',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.warmGray500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部导航
          const DetailAppBar(),

          // 时间叙事区
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                8,
                AppSpacing.pagePadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moment.timeNarrative,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      height: 1.5,
                      color: AppColors.warmGray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatDate(moment.timestamp),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.warmGray400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.warmGray300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        moment.author.name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.warmGray400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
          ),

          // 主内容区 - 使用共享 MediaViewer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: MediaViewer(
                mediaType: moment.mediaType,
                mediaUrl: moment.mediaUrl,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.03, end: 0),
          ),

          // 文字内容
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Text(
                moment.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  fontSize: 17,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          ),

          // 语境还原区 - 使用共享 ContextTagsView
          if (moment.contextTags.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: ContextTagsView(tags: moment.contextTags),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            ),

          // 对未来的一句话 - 使用共享 FutureMessageCard
          if (moment.futureMessage != null)
            SliverToBoxAdapter(
              child: FutureMessageCard(
                message: moment.futureMessage!,
                margin: const EdgeInsets.all(AppSpacing.pagePadding),
              ).animate().fadeIn(duration: 700.ms, delay: 400.ms),
            ),

          // 底部操作区 - 使用共享 DetailActionBar
          SliverToBoxAdapter(
            child: DetailActionBar(
              isFavorite: moment.isFavorite,
              onFavoriteTap: () {
                ref.read(momentsProvider.notifier).toggleFavorite(momentId);
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 60),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
