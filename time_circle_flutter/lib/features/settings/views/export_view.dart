import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';

/// 导出回忆页
class ExportView extends ConsumerStatefulWidget {
  const ExportView({super.key});

  @override
  ConsumerState<ExportView> createState() => _ExportViewState();
}

class _ExportViewState extends ConsumerState<ExportView> {
  bool _isExporting = false;
  double _progress = 0.0;
  String _statusText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '导出回忆'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部说明
            const SettingsHintBox(
              icon: Iconsax.document_download,
              message: '导出所有回忆到本地，随时可以回顾和备份',
              style: HintBoxStyle.purple,
            ),

            const SizedBox(height: 24),

            // 导出选项
            const SettingsSectionTitle(title: '导出格式'),
            const SizedBox(height: 12),

            // ZIP 导出选项
            _ExportOption(
              icon: Iconsax.folder_2,
              title: 'ZIP 压缩包',
              description: '包含原始照片、视频和 JSON 数据文件',
              isRecommended: true,
              onTap: _isExporting ? null : () => _startExport('zip'),
            ),

            const SizedBox(height: 12),

            // PDF 导出选项（暂不可用）
            _ExportOption(
              icon: Iconsax.document,
              title: 'PDF 相册',
              description: '生成精美的 PDF 相册，适合打印',
              isDisabled: true,
            ),

            const SizedBox(height: 24),

            // 导出进度
            if (_isExporting)
              _ExportProgress(progress: _progress, statusText: _statusText),

            if (_isExporting) const SizedBox(height: 24),

            // 导出说明
            SettingsInfoList(
              title: '导出说明',
              items: const [
                SettingsInfoItem(icon: Iconsax.image, text: '导出包含所有照片和视频的原始文件'),
                SettingsInfoItem(
                  icon: Iconsax.document_text,
                  text: '同时导出 JSON 格式的元数据',
                ),
                SettingsInfoItem(icon: Iconsax.timer, text: '导出时间取决于内容数量'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startExport(String format) async {
    setState(() {
      _isExporting = true;
      _progress = 0.0;
      _statusText = '准备导出...';
    });

    try {
      // 模拟导出过程
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() {
          _progress = i / 100;
          if (i < 30) {
            _statusText = '正在收集照片...';
          } else if (i < 60) {
            _statusText = '正在处理视频...';
          } else if (i < 90) {
            _statusText = '正在生成压缩包...';
          } else {
            _statusText = '即将完成...';
          }
        });
      }

      if (mounted) {
        context.showSettingsMessage('导出完成！文件已保存到相册');
      }
    } catch (e) {
      if (mounted) {
        context.showSettingsMessage('导出失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}

/// 导出选项卡片
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isRecommended;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.description,
    this.isRecommended = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF8B7A9C);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SettingsCard(
        child: InkWell(
          onTap: isDisabled ? null : onTap,
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
                  child: Icon(icon, size: 24, color: purpleColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTypography.body(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            _Badge(label: '推荐', color: const Color(0xFFE8A87C)),
                          ],
                          if (isDisabled) ...[
                            const SizedBox(width: 8),
                            _Badge(label: '即将推出', color: AppColors.warmGray300),
                          ],
                        ],
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
      ),
    );
  }
}

/// 标签
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 导出进度
class _ExportProgress extends StatelessWidget {
  final double progress;
  final String statusText;

  const _ExportProgress({required this.progress, required this.statusText});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8A87C)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(statusText, style: AppTypography.body(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.warmGray200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE8A87C),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray500),
          ),
        ],
      ),
    );
  }
}
