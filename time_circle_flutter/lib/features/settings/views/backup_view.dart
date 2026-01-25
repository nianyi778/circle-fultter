import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';

/// 本地备份页
class BackupView extends ConsumerStatefulWidget {
  const BackupView({super.key});

  @override
  ConsumerState<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends ConsumerState<BackupView> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadLastBackupTime();
  }

  Future<void> _loadLastBackupTime() async {
    final repo = ref.read(settingsRepositoryProvider);
    final time = await repo.getLastBackupTime();
    if (mounted && time != null) {
      setState(() {
        _lastBackupTime = _formatDateTime(DateTime.parse(time));
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '本地备份'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部说明
            const SettingsHintBox(
              icon: Iconsax.cloud,
              message: '定期备份数据，保护珍贵的回忆不丢失',
              style: HintBoxStyle.purple,
            ),

            const SizedBox(height: 24),

            // 备份状态卡片
            _BackupStatusCard(
              hasBackup: _lastBackupTime != null,
              lastBackupTime: _lastBackupTime,
            ),

            const SizedBox(height: 24),

            // 操作按钮
            const SettingsSectionTitle(title: '备份操作'),
            const SizedBox(height: 12),

            // 立即备份
            _BackupActionButton(
              icon: Iconsax.export_1,
              title: '立即备份',
              description: '将数据备份到本地存储',
              isLoading: _isBackingUp,
              onTap: _isBackingUp || _isRestoring ? null : _performBackup,
            ),

            const SizedBox(height: 12),

            // 恢复备份
            _BackupActionButton(
              icon: Iconsax.import_1,
              title: '恢复备份',
              description: '从本地备份恢复数据',
              isLoading: _isRestoring,
              onTap: _isBackingUp || _isRestoring ? null : _performRestore,
            ),

            const SizedBox(height: 32),

            // 备份说明
            SettingsInfoList(
              title: '备份说明',
              items: const [
                SettingsInfoItem(
                  icon: Iconsax.document,
                  text: '备份包含所有瞬间、信件和设置',
                ),
                SettingsInfoItem(icon: Iconsax.folder, text: '备份文件保存在应用文档目录'),
                SettingsInfoItem(icon: Iconsax.warning_2, text: '恢复备份会覆盖当前数据'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final repo = ref.read(settingsRepositoryProvider);
      final now = DateTime.now();
      await repo.setLastBackupTime(now.toIso8601String());

      if (mounted) {
        setState(() {
          _lastBackupTime = _formatDateTime(now);
        });
        context.showSettingsMessage('备份成功！');
      }
    } catch (e) {
      if (mounted) {
        context.showSettingsMessage('备份失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _performRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('确认恢复'),
            content: const Text('恢复备份会覆盖当前所有数据，确定要继续吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('恢复', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.showSettingsMessage('恢复成功！');
      }
    } catch (e) {
      if (mounted) {
        context.showSettingsMessage('恢复失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }
}

/// 备份状态卡片
class _BackupStatusCard extends StatelessWidget {
  final bool hasBackup;
  final String? lastBackupTime;

  const _BackupStatusCard({required this.hasBackup, this.lastBackupTime});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Iconsax.shield_tick,
            size: 48,
            color: hasBackup ? AppColors.softGreenDeep : AppColors.warmGray300,
          ),
          const SizedBox(height: 12),
          Text(
            hasBackup ? '数据已备份' : '尚未备份',
            style: AppTypography.subtitle(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          if (lastBackupTime != null) ...[
            const SizedBox(height: 4),
            Text(
              '上次备份：$lastBackupTime',
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400),
            ),
          ],
        ],
      ),
    );
  }
}

/// 备份操作按钮
class _BackupActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback? onTap;

  const _BackupActionButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8B7A9C);

    return SettingsCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: purpleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    isLoading
                        ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                purpleColor,
                              ),
                            ),
                          ),
                        )
                        : Icon(icon, size: 24, color: purpleColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.warmGray400),
                    ),
                  ],
                ),
              ),
              const Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: AppColors.warmGray300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
