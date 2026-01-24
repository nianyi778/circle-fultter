import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 今日一句 - 每日温暖语句
///
/// 设计理念：
/// - 简洁优雅，不抢占视觉焦点
/// - 每天显示一句温暖的话
/// - 增加仪式感和情感连接
class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  /// 温暖语句库
  static const List<String> _quotes = [
    '记录平凡，才能看见不凡。',
    '今天也是值得珍藏的一天。',
    '时间会记住你的温柔。',
    '慢慢来，时间不着急。',
    '每一刻都是礼物。',
    '你正在创造美好的回忆。',
    '生活的美好，藏在细节里。',
    '今天是适合拍照的日子。',
    '留下这一刻，未来会感谢你。',
    '平凡的日子，也值得被记住。',
    '时光温柔，岁月静好。',
    '每一天都在书写故事。',
    '用心感受，用爱记录。',
    '最好的时光，就是现在。',
    '生活不止眼前，还有回忆。',
    '今天的阳光，值得被收藏。',
    '小事也是大事，因为是你的事。',
    '时间会证明，这些都值得。',
    '温柔地对待每一天。',
    '记录是一种温柔的坚持。',
    '让时间慢下来。',
    '美好正在发生。',
    '这一刻，值得被铭记。',
    '生活需要仪式感。',
    '每一帧都是风景。',
    '时间是最好的礼物。',
    '用记录拥抱时光。',
    '今天的你，比昨天更好。',
    '幸福就藏在日常里。',
    '记住现在，温暖未来。',
  ];

  /// 根据日期获取今日语句
  String _getTodayQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final quote = _getTodayQuote();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧装饰引号
          Text(
            '"',
            style: TextStyle(
              fontSize: 32,
              height: 0.8,
              fontWeight: FontWeight.w300,
              color: AppColors.warmGray300,
            ),
          ),
          const SizedBox(width: 8),

          // 语句内容
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                quote,
                style: AppTypography.body(context).copyWith(
                  color: AppColors.warmGray500,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
