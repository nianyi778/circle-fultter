import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

/// 年度信卡片 - 精美设计
///
/// 设计理念：
/// - 简洁、克制，不抢占视觉焦点
/// - 精致的卡片式设计
/// - 温柔的邀请
class AnnualLetterCard extends ConsumerWidget {
  const AnnualLetterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftLetter = ref.watch(annualDraftLetterProvider);
    final hasDraft = draftLetter != null;

    return GestureDetector(
      onTap: () {
        if (hasDraft) {
          context.push('/letter/${draftLetter.id}/edit');
        } else {
          context.push('/letters');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.warmGray150, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            // 左侧图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      hasDraft
                          ? [
                            AppColors.warningLight,
                            AppColors.warning.withValues(alpha: 0.5),
                          ]
                          : [
                            AppColors.calmBlueLight,
                            AppColors.calmBlue.withValues(alpha: 0.5),
                          ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasDraft ? Iconsax.edit_2 : Iconsax.sms,
                size: 20,
                color:
                    hasDraft ? AppColors.warningDark : AppColors.calmBlueDeep,
              ),
            ),
            const SizedBox(width: 14),

            // 中间文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDraft ? '还有一封草稿等你' : '写一封信给未来',
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.warmGray800,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDraft ? '继续编辑你的信件' : '时间会帮你保管',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 右侧箭头
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.arrow_right_3,
                size: 14,
                color: AppColors.warmGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
