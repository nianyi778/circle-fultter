import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/date_wheel_picker.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';

/// 圈子信息编辑页
class CircleInfoView extends ConsumerStatefulWidget {
  const CircleInfoView({super.key});

  @override
  ConsumerState<CircleInfoView> createState() => _CircleInfoViewState();
}

class _CircleInfoViewState extends ConsumerState<CircleInfoView> {
  final _nameController = TextEditingController();
  DateTime? _startDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCircleInfo();
  }

  void _loadCircleInfo() {
    final circleInfo = ref.read(childInfoProvider);
    _nameController.text = circleInfo.name;
    _startDate = circleInfo.startDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final result = await DateWheelPicker.show(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      title: '选择起始日期',
    );

    if (result != null) {
      setState(() => _startDate = result);
    }
  }

  Future<void> _saveCircleInfo() async {
    if (_nameController.text.trim().isEmpty) {
      context.showSettingsMessage('请输入圈子名称', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(circleRepositoryProvider);
      final currentInfo = ref.read(childInfoProvider);

      // 使用 CircleRepository 更新圈子信息
      await repo.updateCircle(
        circleId: currentInfo.id ?? '',
        name: _nameController.text.trim(),
        startDate: _startDate,
        clearStartDate: _startDate == null,
      );

      // 刷新认证状态以获取最新的圈子信息
      await ref.read(authProvider.notifier).refresh();

      if (mounted) {
        context.showSettingsMessage('保存成功');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSettingsMessage('保存失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // childInfoProvider 用于显示当前圈子信息
    ref.watch(childInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: SettingsAppBar(
        title: '圈子信息',
        actions: [
          SettingsSaveButton(onPressed: _saveCircleInfo, isLoading: _isLoading),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圈子名称
            SettingsSectionTitle(
              title: '圈子名称',
              subtitle: '可以是孩子的名字、情侣昵称或任何你喜欢的称呼',
            ),
            const SizedBox(height: 8),
            AppTextField(controller: _nameController, hintText: '输入圈子名称'),

            const SizedBox(height: 32),

            // 起始日期
            SettingsSectionTitle(title: '起始日期', subtitle: '用于计算时间，如孩子生日、相识日等'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _startDate != null
                            ? _formatDate(_startDate!)
                            : '选择日期（可选）',
                        style: TextStyle(
                          color:
                              _startDate != null
                                  ? AppColors.warmGray800
                                  : AppColors.warmGray400,
                        ),
                      ),
                    ),
                    Icon(
                      Iconsax.calendar_1,
                      size: 20,
                      color: AppColors.warmGray500,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 统计信息卡片（使用本地 _startDate 而不是 provider 中的数据）
            if (_startDate != null) ...[
              SettingsSectionTitle(title: '统计'),
              const SizedBox(height: 12),
              _buildStatsCard(_startDate!),
            ],

            const SizedBox(height: 40),

            // 提示说明
            SettingsHintBox(
              icon: Iconsax.heart,
              message: '这是属于你们的私密空间，珍藏每一个温暖的瞬间',
              style: HintBoxStyle.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(DateTime startDate) {
    final now = DateTime.now();
    final days = now.difference(startDate).inDays;
    final timeLabel = _calculateTimeLabel(startDate, now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warmGray100),
      ),
      child: Row(
        children: [
          _buildStatItem('$days', '天', const Color(0xFFE8A87C)),
          Container(
            width: 1,
            height: 40,
            color: AppColors.warmGray100,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _buildStatItem(timeLabel, '', AppColors.softGreenDeep),
        ],
      ),
    );
  }

  String _calculateTimeLabel(DateTime startDate, DateTime now) {
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0 && months > 0) {
      return '$years 年 $months 个月';
    } else if (years > 0) {
      return '$years 年';
    } else if (months > 0) {
      return '$months 个月';
    } else {
      return '刚开始';
    }
  }

  Widget _buildStatItem(String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.warmGray500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
