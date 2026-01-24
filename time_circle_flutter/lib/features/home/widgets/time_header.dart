import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// 时间感知区头部 - 重新设计
///
/// 设计理念：
/// - 时间数字是视觉焦点，使用超大字体
/// - 让用户一打开就感受到"时间"
/// - 简洁、有力、温柔
class TimeHeader extends StatefulWidget {
  final CircleInfo circleInfo;
  final bool hasHistory;
  final int momentCount;

  const TimeHeader({
    super.key,
    required this.circleInfo,
    required this.hasHistory,
    this.momentCount = 0,
  });

  @override
  State<TimeHeader> createState() => _TimeHeaderState();
}

class _TimeHeaderState extends State<TimeHeader> {
  @override
  Widget build(BuildContext context) {
    if (!widget.hasHistory) {
      // 新用户欢迎语 - 更优雅的版本
      return _buildNewUserHeader(context);
    }

    // 老用户：大号时间数字 + 日期信息
    return _buildExistingUserHeader(context);
  }

  /// 新用户头部
  Widget _buildNewUserHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '你好，',
          style: AppTypography.title(
            context,
          ).copyWith(color: AppColors.warmGray600),
        ),
        const SizedBox(height: 4),
        Text(
          '欢迎来到念念',
          style: AppTypography.title(
            context,
          ).copyWith(color: AppColors.warmGray800, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Text(
          '这是一本空白的时间之书。',
          style: AppTypography.body(
            context,
          ).copyWith(color: AppColors.warmGray500),
        ),
        const SizedBox(height: 4),
        Text(
          '所有的温情和感动，都将从此刻开始。',
          style: AppTypography.body(
            context,
          ).copyWith(color: AppColors.warmGray500),
        ),
      ],
    );
  }

  /// 老用户头部 - 大号时间数字作为主视觉
  Widget _buildExistingUserHeader(BuildContext context) {
    final now = DateTime.now();
    final dayCount = widget.circleInfo.daysSinceBirth;
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdayNames[now.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 大号天数数字
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '第 ',
              style: AppTypography.title(
                context,
              ).copyWith(color: AppColors.warmGray500, fontSize: 20),
            ),
            // 数字使用超大字体
            _AnimatedNumber(
              value: dayCount,
              style: AppTypography.hero(context),
            ),
            Text(
              ' 天',
              style: AppTypography.title(
                context,
              ).copyWith(color: AppColors.warmGray500, fontSize: 20),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 日期和圈子信息
        Row(
          children: [
            Text(
              '${now.year}年${now.month}月${now.day}日',
              style: AppTypography.caption(context),
            ),
            _buildDot(),
            Text(weekday, style: AppTypography.caption(context)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.circleInfo.name,
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400),
            ),
            _buildDot(),
            Text(
              widget.circleInfo.ageLabel,
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: AppColors.warmGray300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 数字动画组件 - 从0计数到目标值
class _AnimatedNumber extends StatefulWidget {
  final int value;
  final TextStyle style;

  const _AnimatedNumber({required this.value, required this.style});

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.ceremony,
      vsync: this,
    );
    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.enter));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.enter));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}', style: widget.style);
      },
    );
  }
}
