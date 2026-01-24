import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

/// 年度信卡片 - 简化版一行式设计
///
/// 设计理念：
/// - 简洁、克制，不抢占视觉焦点
/// - 一行式设计，温柔的邀请
/// - 整个卡片可点击
class AnnualLetterCard extends ConsumerWidget {
  const AnnualLetterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftLetter = ref.watch(annualDraftLetterProvider);
    final childInfo = ref.watch(childInfoProvider);
    final hasLastYearData = ref.watch(hasLastYearDataProvider);

    final hasDraft = draftLetter != null;
    final isFirstYear = !hasLastYearData;

    // 根据不同场景设置文案
    String title;
    IconData icon;

    if (hasDraft) {
      title = '还有一封草稿等你';
      icon = Iconsax.edit_2;
    } else if (isFirstYear) {
      title = '写一封信给未来的自己';
      icon = Iconsax.sms;
    } else {
      title = '给 ${childInfo.shortAgeLabel} 的他写封信';
      icon = Iconsax.sms;
    }

    return GestureDetector(
      onTap: () {
        if (hasDraft) {
          context.push('/letter/${draftLetter.id}/edit');
        } else {
          context.push('/letters');
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warmGray150, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 左侧图标
            Icon(icon, size: 20, color: AppColors.warmGray500),
            const SizedBox(width: 12),

            // 中间文字
            Expanded(
              child: Text(
                title,
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 右侧箭头
            Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.warmGray300),
          ],
        ),
      ),
    );
  }
}
