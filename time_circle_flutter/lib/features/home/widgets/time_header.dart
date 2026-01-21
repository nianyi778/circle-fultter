import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// 时间感知区头部
class TimeHeader extends StatelessWidget {
  final ChildInfo childInfo;
  final bool hasHistory;

  const TimeHeader({
    super.key,
    required this.childInfo,
    required this.hasHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasHistory ? childInfo.seasonLabel : '这是你们的第一个时间圈',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasHistory
              ? '你正在经历${childInfo.name}的 ${childInfo.ageLabel}。'
              : '时间会过去，但你可以留下些什么。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.warmGray500,
          ),
        ),
      ],
    );
  }
}
