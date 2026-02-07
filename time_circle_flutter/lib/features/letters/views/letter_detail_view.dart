import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/animations/animation_config.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/letter.dart';
import '../../../shared/widgets/date_wheel_picker.dart';
import '../../../shared/widgets/aura/aura_toast.dart';
import '../../../shared/widgets/aura/aura_dialog.dart';
import '../../../presentation/shared/aura/animations/aura_stagger_list.dart';

/// 信件详情页（阅读态）- 沉浸式回看
class LetterDetailView extends ConsumerStatefulWidget {
  final String letterId;

  const LetterDetailView({super.key, required this.letterId});

  @override
  ConsumerState<LetterDetailView> createState() => _LetterDetailViewState();
}

class _LetterDetailViewState extends ConsumerState<LetterDetailView> {
  @override
  Widget build(BuildContext context) {
    final letter = ref.watch(letterByIdProvider(widget.letterId));

    if (letter == null) {
      return Scaffold(
        backgroundColor: AppColors.timeBeigeWarm,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.sms_tracking,
                size: 48,
                color: AppColors.warmGray300,
              ),
              const SizedBox(height: 16),
              Text(
                '这封信，可能已经被你带走了。',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.warmGray500),
              ),
            ],
          ),
        ),
      );
    }

    final isLocked = letter.status == LetterStatus.sealed;

    return Scaffold(
      backgroundColor: AppColors.timeBeigeWarm,
      body: Stack(
        children: [
          // 纸张纹理背景
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.timeBeigeWarm, AppColors.timeBeige],
                ),
              ),
            ),
          ),

          // 主内容
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部导航
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                floating: true,
                leading: IconButton(
                  onPressed: () {
                    HapticService.lightTap();
                    context.pop();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.subtle,
                    ),
                    child: const Icon(
                      Iconsax.arrow_left_2,
                      size: 20,
                      color: AppColors.warmGray700,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      HapticService.lightTap();
                      _showActionSheet(context, letter);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.subtle,
                      ),
                      child: const Icon(
                        Iconsax.more,
                        size: 20,
                        color: AppColors.warmGray700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 信件头部
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // 状态标签
                      _buildStatusBadge(context, letter, isLocked),
                      const SizedBox(height: 24),

                      // 标题
                      AuraStaggerItem(
                        index: 0,
                        child: Text(
                          letter.title,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 收件人
                      AuraStaggerItem(
                        index: 1,
                        child: Text(
                          '致：${letter.recipient}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.warmGray400),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 分隔线
                      AuraStaggerItem(
                        index: 2,
                        child: Container(
                          width: 48,
                          height: 1,
                          color: AppColors.warmGray300,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // 信件正文
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  child:
                      isLocked
                          ? _buildLockedContent(context, letter)
                          : _buildUnlockedContent(context, letter),
                ),
              ),

              // 底部签名装饰
              if (!isLocked)
                SliverToBoxAdapter(
                  child: AuraStaggerItem(
                    index: 4,
                    child: _buildSignature(context),
                  ),
                ),

              // 底部留白
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // 底部渐变遮罩
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.timeBeigeWarm.withValues(alpha: 0),
                      AppColors.timeBeigeWarm,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Letter letter, bool isLocked) {
    return _FadeScaleInWidget(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warmGray100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLocked ? Iconsax.lock : Iconsax.calendar_1,
              size: 12,
              color: AppColors.warmGray500,
            ),
            const SizedBox(width: 6),
            Text(
              isLocked
                  ? '解锁日期: ${_formatUnlockDate(letter.unlockDate)}'
                  : '已解锁',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray500,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedContent(BuildContext context, Letter letter) {
    return AuraStaggerItem(
      index: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            // 锁定图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.lock5,
                size: 36,
                color: AppColors.warmGray400,
              ),
            ),
            const SizedBox(height: 24),

            // 锁定提示
            Text(
              '这封信已封存，要在未来才能打开。',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.warmGray600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '美好的事物值得等待。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.warmGray400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedContent(BuildContext context, Letter letter) {
    return AuraStaggerItem(
      index: 3,
      child: Text(
        letter.content ?? letter.preview,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 2.2,
          fontSize: 17,
          color: AppColors.warmGray700,
        ),
      ),
    );
  }

  Widget _buildSignature(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
        right: AppSpacing.pagePadding,
        bottom: 20,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Transform.rotate(
          angle: -0.03,
          child: Text(
            '来自过去的时间胶囊',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warmGray400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  String _formatUnlockDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 显示操作菜单
  void _showActionSheet(BuildContext context, Letter letter) {
    final isDraft = letter.status == LetterStatus.draft;
    final isSealed = letter.status == LetterStatus.sealed;
    final isUnlocked = letter.status == LetterStatus.unlocked;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 主菜单卡片
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 编辑信件（仅草稿状态）
                      if (isDraft)
                        _ActionSheetItem(
                          icon: Iconsax.edit_2,
                          label: '编辑信件',
                          onTap: () {
                            Navigator.pop(ctx);
                            context.push('/letter/edit/${letter.id}');
                          },
                        ),

                      // 修改解锁日期（草稿或封存状态）
                      if (isDraft || isSealed)
                        _ActionSheetItem(
                          icon: Iconsax.calendar_edit,
                          label: '修改解锁日期',
                          showDivider: isDraft,
                          onTap: () {
                            Navigator.pop(ctx);
                            _showDatePicker(context, letter);
                          },
                        ),

                      // 分享信件（仅已解锁状态）
                      if (isUnlocked)
                        _ActionSheetItem(
                          icon: Iconsax.share,
                          label: '分享信件',
                          onTap: () {
                            Navigator.pop(ctx);
                            _shareLetter(context, letter);
                          },
                        ),

                      // 删除信件（所有状态）
                      _ActionSheetItem(
                        icon: Iconsax.trash,
                        label: '删除信件',
                        isDestructive: true,
                        showDivider: false,
                        onTap: () {
                          Navigator.pop(ctx);
                          _showDeleteConfirmation(context, letter);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 取消按钮
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '取消',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.warmGray600,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(ctx).padding.bottom),
              ],
            ),
          ),
    );
  }

  /// 显示日期选择器
  Future<void> _showDatePicker(BuildContext context, Letter letter) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final initialDate = letter.unlockDate ?? now.add(const Duration(days: 365));

    final pickedDate = await DateWheelPicker.show(
      context: context,
      initialDate:
          initialDate.isBefore(now)
              ? now.add(const Duration(days: 1))
              : initialDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 10)),
      title: '选择解锁日期',
      cancelText: '取消',
      confirmText: '确定',
    );

    if (pickedDate != null && mounted) {
      ref
          .read(lettersProvider.notifier)
          .updateUnlockDate(letter.id, pickedDate);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('解锁日期已更新为 ${_formatUnlockDate(pickedDate)}'),
          backgroundColor: AppColors.warmGray800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  /// 分享信件
  void _shareLetter(BuildContext context, Letter letter) {
    // TODO: 集成 share_plus 包实现分享功能
    AuraToast.show(context, message: '分享功能开发中，敬请期待', type: AuraToastType.info);
  }

  /// 显示删除确认弹窗
  void _showDeleteConfirmation(BuildContext context, Letter letter) async {
    final message = letter.isLocked ? '这封信还未解锁，删除后将无法恢复。' : '删除后将无法恢复。';
    final confirmed = await AuraDialog.showDelete(
      context,
      title: '确定要删除这封信吗？',
      message: message,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(lettersProvider.notifier).deleteLetter(letter.id);
        if (context.mounted) {
          context.pop(); // 返回上一页
          AuraToast.success(context, '信件已删除');
        }
      } catch (e) {
        if (context.mounted) {
          AuraToast.error(context, '删除失败：${e.toString()}');
        }
      }
    }
  }
}

/// 操作菜单项
class _ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showDivider;

  const _ActionSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFE53935) : AppColors.warmGray800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider) Divider(height: 1, color: AppColors.warmGray100),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 淡入 + 缩放动画组件
class _FadeScaleInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const _FadeScaleInWidget({
    required this.child,
    this.duration = AuraDurations.normal,
    this.delay = Duration.zero,
  });

  @override
  State<_FadeScaleInWidget> createState() => _FadeScaleInWidgetState();
}

class _FadeScaleInWidgetState extends State<_FadeScaleInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.enter));

    _scale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.enter));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
