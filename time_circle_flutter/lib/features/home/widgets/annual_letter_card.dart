import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

/// 年度信状态卡片
class AnnualLetterCard extends ConsumerWidget {
  const AnnualLetterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftLetter = ref.watch(annualDraftLetterProvider);
    final childInfo = ref.watch(childInfoProvider);

    final hasDraft = draftLetter != null;
    final title = hasDraft ? '这一年还没结束' : '该写信了';
    final subtitle = hasDraft 
        ? '还有一封草稿。简单写写就好。' 
        : '写给 ${_extractAge(childInfo.shortAgeLabel)} 的他。';
    final buttonText = hasDraft ? '继续写' : '开始写';

    return GestureDetector(
      onTap: () {
        if (hasDraft) {
          context.push('/letter/${draftLetter.id}/edit');
        } else {
          // TODO: 创建新的年度信
          context.push('/letters');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.timeBeigeLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.warmGray200,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 背景装饰
            Positioned(
              top: 0,
              right: 0,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Iconsax.sms,
                  size: 100,
                  color: AppColors.warmGray900,
                ),
              ),
            ),
            
            // 内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warmGray800,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Text(
                    buttonText,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _extractAge(String ageLabel) {
    // 从 "3岁" 提取 "3 岁"
    return ageLabel.replaceAll('岁', ' 岁');
  }
}
