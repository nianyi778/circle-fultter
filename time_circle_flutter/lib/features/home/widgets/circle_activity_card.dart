import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/user.dart';

/// 圈子动态卡片
///
/// 设计理念：
/// - 展示今日圈子成员的记录情况
/// - 增加社交感和参与感
/// - 温柔地鼓励用户记录
class CircleActivityCard extends ConsumerWidget {
  const CircleActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);
    final currentUser = ref.watch(currentUserSyncProvider);
    final membersAsync = ref.watch(circleMembersProvider);

    // 统计今日记录
    final now = DateTime.now();
    final todayMoments =
        moments.where((m) {
          return m.timestamp.year == now.year &&
              m.timestamp.month == now.month &&
              m.timestamp.day == now.day;
        }).toList();

    final todayCount = todayMoments.length;

    // 获取今日记录的作者们
    final todayAuthors = <String, User>{};
    for (final m in todayMoments) {
      todayAuthors[m.author.id] = m.author;
    }

    return GestureDetector(
      onTap: () => context.go('/timeline'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warmGray200, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            // 左侧头像区域
            _buildAvatarSection(
              todayAuthors.values.toList(),
              currentUser,
              membersAsync,
            ),
            const SizedBox(width: 12),

            // 文字内容
            Expanded(
              child: _buildTextContent(
                context,
                todayCount,
                todayAuthors.length,
              ),
            ),

            // 右侧箭头
            Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.warmGray300),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    List<User> todayAuthors,
    User currentUser,
    AsyncValue<List<User>> membersAsync,
  ) {
    if (todayAuthors.isEmpty) {
      // 无记录时显示默认图标
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.warmGray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Iconsax.people, size: 18, color: AppColors.warmGray400),
      );
    }

    // 显示头像堆叠（最多3个）
    final displayAuthors = todayAuthors.take(3).toList();
    final avatarSize = 28.0;
    final overlap = 8.0;
    final totalWidth =
        avatarSize + (displayAuthors.length - 1) * (avatarSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: List.generate(displayAuthors.length, (index) {
          final author = displayAuthors[index];
          return Positioned(
            left: index * (avatarSize - overlap),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                color: _getAvatarColor(author.id),
              ),
              child: ClipOval(
                child:
                    author.avatar.isNotEmpty
                        ? Image.network(
                          author.avatar,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => _buildInitialAvatar(author.name),
                        )
                        : _buildInitialAvatar(author.name),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.warmGray600,
        ),
      ),
    );
  }

  Color _getAvatarColor(String id) {
    final colors = [
      AppColors.warmPeach,
      AppColors.calmBlue,
      AppColors.softGreen,
      AppColors.mutedViolet,
    ];
    return colors[id.hashCode.abs() % colors.length];
  }

  Widget _buildTextContent(
    BuildContext context,
    int todayCount,
    int authorCount,
  ) {
    String title;
    String? subtitle;

    if (todayCount == 0) {
      title = '今天还没有记录';
      subtitle = '留下这一刻吧';
    } else if (authorCount == 1) {
      title = '今天记录了 $todayCount 条';
      subtitle = todayCount >= 3 ? '真棒，继续保持！' : null;
    } else {
      title = '今天共记录了 $todayCount 条';
      subtitle = '$authorCount 位成员参与了记录';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.body(
            context,
          ).copyWith(color: AppColors.warmGray700, fontWeight: FontWeight.w500),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray400),
          ),
        ],
      ],
    );
  }
}
