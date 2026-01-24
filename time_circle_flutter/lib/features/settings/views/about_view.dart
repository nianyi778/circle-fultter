import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';

/// 关于页面
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '关于'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo 和名称
            const AppLogo(size: AppLogoSize.large),
            const SizedBox(height: 16),
            Text(
              '念念',
              style: AppTypography.title(context).copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.warmGray800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0.0',
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400),
            ),

            const SizedBox(height: 32),

            // 产品理念
            _AboutSection(
              icon: Iconsax.heart,
              iconColor: const Color(0xFFE8A87C),
              title: '产品理念',
              content: '''我们相信，每一个平凡的瞬间都值得被温柔地记住。

念念不是一个效率工具，而是一个「时间容器」——它安静地陪伴你，收纳那些看似微不足道却无比珍贵的日常。

这里没有点赞、没有评论、没有社交压力。只有你和你爱的人，在时间的长河中，慢慢积累属于你们的故事。

我们希望，这些回忆能陪你很久。''',
            ),

            const SizedBox(height: 24),

            // 数据承诺
            _AboutSection(
              icon: Iconsax.shield_tick,
              iconColor: AppColors.softGreenDeep,
              title: '数据承诺',
              content: '''你的回忆，只属于你。

• 所有数据本地优先存储，你的手机就是你的保险箱
• 我们绝不会将你的内容用于任何商业目的
• 你可以随时导出所有数据，这是你的权利
• 即使有一天我们不在了，你的回忆也不会消失

这是我们对你的承诺。''',
            ),

            const SizedBox(height: 24),

            // 设计哲学
            _AboutSection(
              icon: Iconsax.magic_star,
              iconColor: const Color(0xFF5A8AB8),
              title: '设计哲学',
              content: '''温柔、安静、克制。

我们刻意选择了柔和的米白色调，让眼睛得到休息；
我们故意放慢了动画节奏，让心跳平静下来；
我们特意减少了功能入口，让注意力回归本质。

因为我们相信，记录生活不应该是一种负担，而是一种享受。''',
            ),

            const SizedBox(height: 40),

            // 底部温馨语
            Text(
              '愿时光温柔，愿回忆常在。',
              style: AppTypography.body(context).copyWith(
                color: AppColors.warmGray400,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

/// 关于页面的内容区块
class _AboutSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _AboutSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.subtitle(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.warmGray600, height: 1.8),
          ),
        ],
      ),
    );
  }
}
