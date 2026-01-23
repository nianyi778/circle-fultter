import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

/// 年度信状态卡片
///
/// 根据用户情况显示不同文案：
/// - 有草稿：继续写
/// - 第一年用户（圈子不满1年）：温柔的邀请
/// - 老用户：常规写信提示
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
    String subtitle;
    String buttonText;

    if (hasDraft) {
      // 有草稿
      title = '这一年还没结束';
      subtitle = '还有一封草稿。简单写写就好。';
      buttonText = '继续写';
    } else if (isFirstYear) {
      // 第一年用户 - 温柔邀请
      title = '写一封信给未来';
      subtitle = '不必完美，只是留下此刻的心情。一年后，它会回来找你。';
      buttonText = '开始写';
    } else {
      // 老用户 - 常规提示
      title = '该写信了';
      subtitle = '写给 ${_extractAge(childInfo.shortAgeLabel)} 的他。';
      buttonText = '开始写';
    }

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
          color:
              isFirstYear
                  ? AppColors.warmPeach.withValues(alpha: 0.15)
                  : AppColors.timeBeigeLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.warmGray200, width: 1),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray500,
                    height: 1.5,
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
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: AppColors.white),
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
