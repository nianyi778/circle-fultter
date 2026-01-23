import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/moment.dart';

/// 语境标签展示组件
class ContextTagsView extends StatelessWidget {
  final List<ContextTag> tags;
  final bool showContainer;
  final EdgeInsetsGeometry? padding;

  const ContextTagsView({
    super.key,
    required this.tags,
    this.showContainer = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    // 所有标签横向排列
    final content = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _ContextTagChip(tag: tag)).toList(),
    );

    if (!showContainer) {
      return Padding(padding: padding ?? EdgeInsets.zero, child: content);
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: content,
    );
  }
}

/// 单个语境标签
class _ContextTagChip extends StatelessWidget {
  final ContextTag tag;

  const _ContextTagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.warmGray200, width: 1),
      ),
      child: Text(
        tag.display,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.warmGray600),
      ),
    );
  }
}

/// 可选择的语境标签（用于编辑）
class SelectableContextTag extends StatelessWidget {
  final ContextTag tag;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectableContextTag({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warmGray800 : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.warmGray800 : AppColors.warmGray200,
            width: 1,
          ),
        ),
        child: Text(
          tag.display,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.warmGray600,
          ),
        ),
      ),
    );
  }
}
