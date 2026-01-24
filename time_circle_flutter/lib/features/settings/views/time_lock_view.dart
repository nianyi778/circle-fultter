import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';
import '../providers/settings_provider.dart';

/// 时间锁选项图标
const _timeLockIcons = {
  30: '📅',
  90: '🗓️',
  180: '🌙',
  365: '🎂',
  730: '🌟',
  1825: '✨',
  3650: '💫',
};

/// 时间锁规则设置页
class TimeLockView extends ConsumerWidget {
  const TimeLockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '时间锁信规则'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部说明
            const SettingsHintBox(
              icon: Iconsax.lock_1,
              message: '时间锁信会在设定的时间后才能打开，写给未来的自己或家人',
              style: HintBoxStyle.warning,
            ),

            const SizedBox(height: 24),

            // 默认锁定时长
            const SettingsSectionTitle(title: '默认锁定时长'),
            const SizedBox(height: 12),

            SettingsListSection(
              children:
                  TimeLockOption.options.map((option) {
                    final isSelected = settings.timeLockDuration == option.days;
                    return _TimeLockOptionTile(
                      option: option,
                      isSelected: isSelected,
                      onTap:
                          () =>
                              settingsNotifier.setTimeLockDuration(option.days),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // 温馨提示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 18,
                        color: AppColors.warmGray500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '温馨提示',
                        style: AppTypography.caption(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warmGray600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 锁定期间信件内容完全不可见\n• 时间到后会收到通知提醒\n• 发送后无法修改锁定时间',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray500, height: 1.6),
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

/// 时间锁选项
class _TimeLockOptionTile extends StatelessWidget {
  final TimeLockOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeLockOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8A87C).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _timeLockIcons[option.days] ?? '📅',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTypography.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray400, fontSize: 12),
                  ),
                ],
              ),
            ),
            SettingsRadioIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
