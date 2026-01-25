import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';
import '../providers/settings_provider.dart';

/// 设置页
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 顶部导航
            SliverAppBar(
              backgroundColor: AppColors.timeBeige,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Iconsax.arrow_left_2,
                  color: AppColors.warmGray700,
                ),
              ),
              title: Text(
                '设置',
                style: AppTypography.title(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),

            // 顶部说明
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  '这里，你可以决定这些回忆如何被保存。',
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.warmGray400,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // 用户信息卡片
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: _UserCard(
                  currentUser: currentUser,
                  childInfo: childInfo,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // 设置分组
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 我的圈子
                    _SettingsGroup(
                      title: '我的圈子',
                      iconColor: AppColors.softGreenDeep,
                      children: [
                        SettingsListTile(
                          icon: Iconsax.people,
                          iconColor: AppColors.softGreenDeep,
                          title: '成员管理',
                          subtitle: '邀请成员加入',
                          onTap: () => context.push('/settings/members'),
                        ),
                        SettingsListTile(
                          icon: Iconsax.user_octagon,
                          iconColor: AppColors.softGreenDeep,
                          title: '圈子信息',
                          subtitle: childInfo.name,
                          onTap: () => context.push('/settings/circle'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 隐私与安全
                    _SettingsGroup(
                      title: '隐私与安全',
                      iconColor: const Color(0xFF5A8AB8),
                      children: [
                        SettingsListTile(
                          icon: Iconsax.shield_tick,
                          iconColor: const Color(0xFF5A8AB8),
                          title: '内容可见性',
                          subtitle: '默认私密',
                          onTap: () => context.push('/settings/visibility'),
                        ),
                        SettingsListTile(
                          icon: Iconsax.eye_slash,
                          iconColor: const Color(0xFF5A8AB8),
                          title: '面部自动模糊',
                          subtitle: '分享时保护隐私',
                          trailing: SettingsSwitch(
                            value: settings.faceBlurEnabled,
                            onChanged:
                                (v) => ref
                                    .read(settingsProvider.notifier)
                                    .setFaceBlurEnabled(v),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 回忆与信
                    _SettingsGroup(
                      title: '回忆与信',
                      iconColor: const Color(0xFFE8A87C),
                      children: [
                        SettingsListTile(
                          icon: Iconsax.sms,
                          iconColor: const Color(0xFFE8A87C),
                          title: '年度信提醒',
                          subtitle: '纪念日提醒',
                          trailing: SettingsSwitch(
                            value: settings.annualLetterReminder,
                            onChanged:
                                (v) => ref
                                    .read(settingsProvider.notifier)
                                    .setAnnualLetterReminder(v),
                          ),
                        ),
                        SettingsListTile(
                          icon: Iconsax.lock_1,
                          iconColor: const Color(0xFFE8A87C),
                          title: '时间锁信规则',
                          subtitle: '默认锁定时长',
                          onTap: () => context.push('/settings/time-lock'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 导出
                    _SettingsGroup(
                      title: '导出',
                      iconColor: const Color(0xFF8B7A9C),
                      children: [
                        SettingsListTile(
                          icon: Iconsax.document_download,
                          iconColor: const Color(0xFF8B7A9C),
                          title: '导出回忆',
                          subtitle: '下载 ZIP / PDF',
                          onTap: () => context.push('/settings/export'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 关于
                    _SettingsGroup(
                      title: '关于',
                      iconColor: AppColors.warmGray600,
                      children: [
                        SettingsListTile(
                          icon: Iconsax.heart,
                          iconColor: AppColors.warmGray600,
                          title: '产品理念',
                          onTap: () => context.push('/settings/about'),
                        ),
                        SettingsListTile(
                          icon: Iconsax.document_text,
                          iconColor: AppColors.warmGray600,
                          title: '数据承诺',
                          onTap: () => context.push('/settings/about'),
                        ),
                        SettingsListTile(
                          icon: Iconsax.message_question,
                          iconColor: AppColors.warmGray600,
                          title: '帮助与反馈',
                          onTap: () => context.push('/settings/feedback'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 底部 Logo + 版本号
                    _buildFooter(context),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          '我们希望，这些回忆能陪你很久。',
          style: AppTypography.caption(
            context,
          ).copyWith(color: AppColors.warmGray400, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: AppLogoSize.small),
            const SizedBox(width: 8),
            Text(
              '念念 v1.0.0',
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

/// 用户信息卡片
class _UserCard extends StatelessWidget {
  final dynamic currentUser;
  final dynamic childInfo;

  const _UserCard({required this.currentUser, required this.childInfo});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: InkWell(
        onTap: () => context.push('/settings/profile'),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.warmGray200, width: 1),
                ),
                child: ClipOval(
                  child: ImageUtils.buildAvatar(
                    url: currentUser.avatar,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.name,
                      style: AppTypography.subtitle(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      childInfo.name,
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.warmGray500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: AppColors.warmGray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 设置分组组件
class _SettingsGroup extends StatelessWidget {
  final String title;
  final Color iconColor;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroupHeader(title: title, indicatorColor: iconColor),
        SettingsListSection(dividerIndent: 64, children: children),
      ],
    );
  }
}
