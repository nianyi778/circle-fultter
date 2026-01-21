import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

/// 设置页
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 顶部导航
            SliverAppBar(
              backgroundColor: Colors.transparent,
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
            ),

            // 顶部说明
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.lg,
                ),
                child: Text(
                  '这里，你可以决定这些回忆如何被保存。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warmGray200,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            currentUser.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Iconsax.user, color: AppColors.warmGray400),
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${childInfo.name}的${currentUser.roleLabel}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.warmGray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Iconsax.arrow_right_3,
                        size: 20,
                        color: AppColors.warmGray400,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 设置分组
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsGroup(
                      context,
                      title: '家庭圈',
                      items: [
                        _SettingsItem(
                          icon: Iconsax.people,
                          title: '成员管理',
                          subtitle: '邀请家人加入',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Iconsax.user_octagon,
                          title: '孩子信息',
                          subtitle: childInfo.name,
                          onTap: () {},
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    _buildSettingsGroup(
                      context,
                      title: '回忆与信',
                      items: [
                        _SettingsItem(
                          icon: Iconsax.sms,
                          title: '年度信提醒',
                          subtitle: '生日月提醒',
                          trailing: _buildSwitch(true),
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Iconsax.lock_1,
                          title: '时间锁信规则',
                          subtitle: '默认 18 岁解锁',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSettingsGroup(
                      context,
                      title: '隐私与安全',
                      items: [
                        _SettingsItem(
                          icon: Iconsax.shield_tick,
                          title: '内容可见性',
                          subtitle: '默认私密',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Iconsax.eye_slash,
                          title: '面部自动模糊',
                          subtitle: '分享时保护孩子',
                          trailing: _buildSwitch(true),
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSettingsGroup(
                      context,
                      title: '存储与备份',
                      items: [
                        _SettingsItem(
                          icon: Iconsax.cloud,
                          title: '云端备份',
                          subtitle: '已使用 2.3 GB',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Iconsax.document_download,
                          title: '导出回忆',
                          subtitle: '下载 ZIP / PDF',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSettingsGroup(
                      context,
                      title: '关于',
                      items: [
                        _SettingsItem(
                          icon: Iconsax.heart,
                          title: '产品理念',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Iconsax.document_text,
                          title: '数据承诺',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Iconsax.message_question,
                          title: '帮助与反馈',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 底部说明
                    Center(
                      child: Text(
                        '我们希望，这些回忆能陪你很久。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warmGray400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 版本号
                    Center(
                      child: Text(
                        'TimeCircle v1.0.0',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warmGray300,
                        ),
                      ),
                    ),
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

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.warmGray500,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildSettingsItem(context, item),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 56),
                      child: Container(
                        height: 1,
                        color: AppColors.warmGray100,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, _SettingsItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: AppColors.warmGray600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            item.trailing ?? const Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: AppColors.warmGray300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value) {
    return Container(
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? AppColors.softGreenDeep : AppColors.warmGray300,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Align(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
