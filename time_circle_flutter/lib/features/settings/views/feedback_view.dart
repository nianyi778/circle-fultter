import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';
import '../../../shared/widgets/aura/aura_dialog.dart';

/// 帮助与反馈页
class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '帮助与反馈'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 常见问题
            const SettingsSectionTitle(title: '常见问题'),
            const SizedBox(height: 12),

            _FAQItem(
              question: '如何添加新成员到圈子？',
              answer: '进入「设置 > 成员管理」，点击右下角的加号按钮即可添加新成员。每个成员可以设置名称和角色标签。',
            ),

            _FAQItem(
              question: '我的数据安全吗？',
              answer: '非常安全！所有数据优先存储在你的手机本地，我们不会将你的内容上传到云端，除非你主动开启云备份功能。',
            ),

            _FAQItem(
              question: '时间锁信是什么？',
              answer: '时间锁信是一个特别的功能，让你可以写一封信给未来的自己或家人。在设定的时间到来之前，信件会被锁定，无法打开。',
            ),

            _FAQItem(
              question: '如何导出我的所有回忆？',
              answer: '进入「设置 > 导出回忆」，选择 ZIP 格式导出，你的所有照片、视频和文字都会被打包下载。',
            ),

            _FAQItem(
              question: '可以多人同时记录吗？',
              answer: '当然可以！圈子内的所有成员都可以记录瞬间和查看回忆。每条记录都会显示是谁发布的。',
            ),

            const SizedBox(height: 32),

            // 联系我们
            const SettingsSectionTitle(title: '联系我们'),
            const SizedBox(height: 12),

            SettingsListSection(
              children: [
                SettingsListTile(
                  icon: Iconsax.sms,
                  iconColor: const Color(0xFFE8A87C),
                  title: '发送邮件',
                  subtitle: 'feedback@niannian.app',
                  onTap: () => _copyEmail(context),
                ),
                SettingsListTile(
                  icon: Iconsax.message_question,
                  iconColor: const Color(0xFFE8A87C),
                  title: '问题反馈',
                  subtitle: '提交问题或建议',
                  onTap: () => _showFeedbackDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 温馨提示
            SettingsHintBox(
              icon: Iconsax.heart,
              message: '感谢你选择念念，有任何问题都可以联系我们',
              style: HintBoxStyle.neutral,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyEmail(BuildContext context) async {
    const email = 'feedback@niannian.app';
    await Clipboard.setData(const ClipboardData(text: email));
    if (context.mounted) {
      context.showSettingsMessage('邮箱已复制到剪贴板');
    }
  }

  void _showFeedbackDialog(BuildContext context) async {
    final controller = TextEditingController();

    final confirmed = await AuraDialog.show(
      context,
      title: '问题反馈',
      content: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: '请描述你遇到的问题或建议...',
          hintStyle: TextStyle(color: AppColors.warmGray400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.warmGray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.warmGray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.warmOrange),
          ),
        ),
      ),
      confirmText: '提交',
      cancelText: '取消',
    );

    if (confirmed == true && context.mounted) {
      context.showSettingsMessage('感谢你的反馈！');
    }

    controller.dispose();
  }
}

/// FAQ 项目
class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warmGray100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: AppTypography.body(
              context,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
          iconColor: AppColors.warmGray400,
          collapsedIconColor: AppColors.warmGray400,
          children: [
            Text(
              answer,
              style: AppTypography.body(
                context,
              ).copyWith(color: AppColors.warmGray600, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
