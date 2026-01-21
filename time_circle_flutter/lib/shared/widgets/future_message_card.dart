import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "对未来说一句" 展示卡片
class FutureMessageCard extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;

  const FutureMessageCard({
    super.key,
    required this.message,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmPeach.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.warmPeachDeep.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '"$message"',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.warmGray700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
