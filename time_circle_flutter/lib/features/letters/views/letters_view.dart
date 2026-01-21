import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/letter.dart';

class LettersView extends ConsumerWidget {
  const LettersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letters = ref.watch(lettersProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 顶部标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.xxl,
                  AppSpacing.pagePadding,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '信',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '给未来的时间胶囊。',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.warmGray500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.warmGray800,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // 检查是否有草稿
                          final draft = letters.firstWhere(
                            (l) => l.status == LetterStatus.draft,
                            orElse: () => letters.first,
                          );
                          if (draft.status == LetterStatus.draft) {
                            context.push('/letter/${draft.id}/edit');
                          } else {
                            // TODO: 创建新信件
                          }
                        },
                        icon: const Icon(
                          Iconsax.edit,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // 提示文字
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.lg,
                  AppSpacing.pagePadding,
                  AppSpacing.lg,
                ),
                child: Text(
                  '你不必现在写完。',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warmGray400,
                    letterSpacing: 1,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            // 信件列表或空状态
            if (letters.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(context, ref),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final letter = letters[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LetterCard(
                          letter: letter,
                          onTap: () {
                            if (letter.status == LetterStatus.draft) {
                              context.push('/letter/${letter.id}/edit');
                            } else {
                              context.push('/letter/${letter.id}');
                            }
                          },
                        ),
                      ).animate().fadeIn(
                        duration: 400.ms,
                        delay: Duration(milliseconds: 100 + (index * 50)),
                        curve: Curves.easeOut,
                      ).slideY(begin: 0.05, end: 0);
                    },
                    childCount: letters.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  /// 空状态设计
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.warmGray200,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: CustomPaint(
          painter: _DottedBackgroundPainter(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 羽毛笔图标
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.edit_2,
                  size: 28,
                  color: AppColors.warmGray400,
                ),
              ),
              const SizedBox(height: 28),

              // 主文案
              Text(
                '这一年的信，还没开始',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.warmGray700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 副文案
              Text(
                '哪怕只写下"你今天学会了叫妈妈"，\n也是给未来最好的礼物。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warmGray400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // CTA 按钮
              GestureDetector(
                onTap: () => _createNewLetter(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.warmGray700,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    '提笔写下第一句',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.warmGray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 200.ms)
      .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }

  /// 创建新信件
  void _createNewLetter(BuildContext context, WidgetRef ref) {
    final childInfo = ref.read(childInfoProvider);
    final newLetter = Letter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '给 ${childInfo.shortAgeLabel} 的${childInfo.name}',
      preview: '',
      status: LetterStatus.draft,
      recipient: childInfo.name,
      type: LetterType.annual,
      createdAt: DateTime.now(),
    );
    
    ref.read(lettersProvider.notifier).addLetter(newLetter);
    context.push('/letter/${newLetter.id}/edit');
  }
}

/// 点状背景绘制器
class _DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.warmGray200.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 信件卡片
class _LetterCard extends StatelessWidget {
  final Letter letter;
  final VoidCallback onTap;

  const _LetterCard({
    required this.letter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = letter.status == LetterStatus.sealed;
    final isDraft = letter.status == LetterStatus.draft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked 
              ? AppColors.warmGray100 
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isLocked 
                ? AppColors.warmGray200 
                : AppColors.warmGray200.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isLocked ? null : AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    letter.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isLocked 
                          ? AppColors.warmGray600 
                          : AppColors.warmGray800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warmGray200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.lock,
                      size: 14,
                      color: AppColors.warmGray500,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDraft 
                          ? AppColors.warmOrange 
                          : AppColors.softGreen,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isDraft 
                            ? AppColors.warmOrangeDeep.withValues(alpha: 0.3)
                            : AppColors.softGreenDeep.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      letter.statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDraft 
                            ? AppColors.warmOrangeDark 
                            : AppColors.successDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 预览内容
            Text(
              isLocked 
                  ? '这封信已封存，直到解锁日期。它很安全。' 
                  : letter.preview,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.warmGray500,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // 底部信息
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.warmGray200,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isLocked 
                        ? '解锁于：${_formatDate(letter.unlockDate)}' 
                        : '给：${letter.recipient}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray400,
                    ),
                  ),
                  const Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: AppColors.warmGray300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}年${date.month}月${date.day}日';
  }
}
