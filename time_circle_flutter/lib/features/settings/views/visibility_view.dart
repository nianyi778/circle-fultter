import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';
import '../providers/settings_provider.dart';

/// 内容可见性设置页
class VisibilityView extends ConsumerWidget {
  const VisibilityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '内容可见性'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部说明
            const SettingsHintBox(
              icon: Iconsax.shield_tick,
              message: '设置新发布内容的默认可见性，发布时也可单独调整',
              style: HintBoxStyle.info,
            ),

            const SizedBox(height: 24),

            // 可见性选项
            const SettingsSectionTitle(title: '默认可见性'),
            const SizedBox(height: 12),

            SettingsListSection(
              children:
                  ContentVisibility.values.map((visibility) {
                    final isSelected = settings.defaultVisibility == visibility;
                    return _VisibilityOption(
                      visibility: visibility,
                      isSelected: isSelected,
                      onTap:
                          () =>
                              settingsNotifier.setDefaultVisibility(visibility),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // 可见性说明
            SettingsInfoList(
              title: '可见性说明',
              items: const [
                SettingsInfoItem(
                  icon: Iconsax.lock_1,
                  boldPrefix: '仅自己',
                  text: '只有你自己可以看到这些内容',
                ),
                SettingsInfoItem(
                  icon: Iconsax.people,
                  boldPrefix: '圈子',
                  text: '圈子内的所有成员都可以看到',
                ),
                SettingsInfoItem(
                  icon: Iconsax.global,
                  boldPrefix: '世界',
                  text: '公开分享到世界频道，所有人可见',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 可见性选项
class _VisibilityOption extends StatelessWidget {
  final ContentVisibility visibility;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.visibility,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (visibility) {
      case ContentVisibility.private:
        return Iconsax.lock_1;
      case ContentVisibility.circle:
        return Iconsax.people;
      case ContentVisibility.world:
        return Iconsax.global;
    }
  }

  Color get _iconColor {
    switch (visibility) {
      case ContentVisibility.private:
        return AppColors.warmGray600;
      case ContentVisibility.circle:
        return AppColors.softGreenDeep;
      case ContentVisibility.world:
        return const Color(0xFF5A8AB8);
    }
  }

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
                color: _iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, size: 18, color: _iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visibility.label,
                    style: AppTypography.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visibility.description,
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
