import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// 时间感知区头部
class TimeHeader extends StatelessWidget {
  final CircleInfo circleInfo;
  final bool hasHistory;

  const TimeHeader({
    super.key,
    required this.circleInfo,
    required this.hasHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasHistory ? circleInfo.seasonLabel : '这是你们的第一个时间圈',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasHistory
              ? '${circleInfo.name}的 ${circleInfo.timeLabel}。'
              : '时间会过去，但你可以留下些什么。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.warmGray500,
          ),
        ),
      ],
    );
  }
}
