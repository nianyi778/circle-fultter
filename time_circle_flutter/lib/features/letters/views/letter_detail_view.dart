import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/letter.dart';

/// 信件详情页（阅读态）- 沉浸式回看
class LetterDetailView extends ConsumerWidget {
  final String letterId;

  const LetterDetailView({super.key, required this.letterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letter = ref.watch(letterByIdProvider(letterId));

    if (letter == null) {
      return Scaffold(
        backgroundColor: AppColors.timeBeigeWarm,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.sms_tracking,
                size: 48,
                color: AppColors.warmGray300,
              ),
              const SizedBox(height: 16),
              Text(
                '这封信，可能已经被你带走了。',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.warmGray500),
              ),
            ],
          ),
        ),
      );
    }

    final isLocked = letter.status == LetterStatus.sealed;

    return Scaffold(
      backgroundColor: AppColors.timeBeigeWarm,
      body: Stack(
        children: [
          // 纸张纹理背景
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.timeBeigeWarm, AppColors.timeBeige],
                ),
              ),
            ),
          ),

          // 主内容
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部导航
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                floating: true,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.subtle,
                    ),
                    child: const Icon(
                      Iconsax.arrow_left_2,
                      size: 20,
                      color: AppColors.warmGray700,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.subtle,
                      ),
                      child: const Icon(
                        Iconsax.more,
                        size: 20,
                        color: AppColors.warmGray700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 信件头部
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // 状态标签
                      _buildStatusBadge(context, letter, isLocked),
                      const SizedBox(height: 24),

                      // 标题
                      Text(
                        letter.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                      const SizedBox(height: 8),

                      // 收件人
                      Text(
                        '致：${letter.recipient}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmGray400,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                      const SizedBox(height: 32),

                      // 分隔线
                      Container(
                            width: 48,
                            height: 1,
                            color: AppColors.warmGray300,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms)
                          .scale(
                            begin: const Offset(0, 1),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // 信件正文
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  child:
                      isLocked
                          ? _buildLockedContent(context, letter)
                          : _buildUnlockedContent(context, letter),
                ),
              ),

              // 底部签名装饰
              if (!isLocked)
                SliverToBoxAdapter(
                  child: _buildSignature(
                    context,
                  ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                ),

              // 底部留白
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // 底部渐变遮罩
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.timeBeigeWarm.withValues(alpha: 0),
                      AppColors.timeBeigeWarm,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Letter letter, bool isLocked) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warmGray100,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocked ? Iconsax.lock : Iconsax.calendar_1,
                size: 12,
                color: AppColors.warmGray500,
              ),
              const SizedBox(width: 6),
              Text(
                isLocked
                    ? '解锁日期: ${_formatUnlockDate(letter.unlockDate)}'
                    : '已解锁',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warmGray500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOut,
        );
  }

  Widget _buildLockedContent(BuildContext context, Letter letter) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          // 锁定图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warmGray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.lock5, size: 36, color: AppColors.warmGray400),
          ),
          const SizedBox(height: 24),

          // 锁定提示
          Text(
            '这封信已封存，要在未来才能打开。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.warmGray600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '美好的事物值得等待。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.warmGray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);
  }

  Widget _buildUnlockedContent(BuildContext context, Letter letter) {
    return Text(
      letter.content ?? letter.preview,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        height: 2.2,
        fontSize: 17,
        color: AppColors.warmGray700,
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 300.ms);
  }

  Widget _buildSignature(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
        right: AppSpacing.pagePadding,
        bottom: 20,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Transform.rotate(
          angle: -0.03,
          child: Text(
            '来自过去的时间胶囊',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warmGray400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  String _formatUnlockDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}年${date.month}月${date.day}日';
  }
}
