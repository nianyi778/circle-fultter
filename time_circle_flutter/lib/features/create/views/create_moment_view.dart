import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';

/// 发布页（「留下」）
class CreateMomentView extends ConsumerStatefulWidget {
  const CreateMomentView({super.key});

  @override
  ConsumerState<CreateMomentView> createState() => _CreateMomentViewState();
}

class _CreateMomentViewState extends ConsumerState<CreateMomentView> {
  final _textController = TextEditingController();
  final _futureMessageController = TextEditingController();
  
  final Set<ContextTag> _selectedParentMoods = {};
  final Set<ContextTag> _selectedChildStates = {};
  bool _showFutureMessage = false;

  @override
  void dispose() {
    _textController.dispose();
    _futureMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childInfo = ref.watch(childInfoProvider);
    final currentUser = ref.watch(currentUserProvider);
    final hasContent = _textController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.warmGray100,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _showExitDialog(context),
                    icon: const Icon(
                      Iconsax.close_circle,
                      color: AppColors.warmGray500,
                    ),
                  ),
                  Text(
                    '留下此刻',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: AppDurations.fast,
                    opacity: hasContent ? 1.0 : 0.5,
                    child: GestureDetector(
                      onTap: hasContent ? () => _submitMoment(context, currentUser, childInfo) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: hasContent 
                              ? AppColors.warmGray800 
                              : AppColors.warmGray200,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '留下',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: hasContent 
                                ? AppColors.white 
                                : AppColors.warmGray400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 文字输入区
                    TextField(
                      controller: _textController,
                      maxLines: 6,
                      autofocus: true,
                      onChanged: (value) => setState(() {}),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.7,
                      ),
                      decoration: InputDecoration(
                        hintText: '这一刻，你想留下些什么？',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          color: AppColors.warmGray300,
                          height: 1.7,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    
                    // 轻提示
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      child: Text(
                        '一句话也好，留给未来就够了。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warmGray300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                    // 媒体按钮
                    Row(
                      children: [
                        _MediaButton(
                          icon: Iconsax.image,
                          label: '照片',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _MediaButton(
                          icon: Iconsax.video,
                          label: '视频',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _MediaButton(
                          icon: Iconsax.microphone_2,
                          label: '语音',
                          onTap: () {},
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 32),

                    // 语境标注区
                    _buildContextSection(context),

                    const SizedBox(height: 24),

                    // 对未来说一句
                    _buildFutureMessageSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当时的我
        Text(
          '当时的我',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.warmGray500,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ContextTag.parentMoodTags.map((tag) {
            final isSelected = _selectedParentMoods.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedParentMoods.remove(tag);
                  } else {
                    _selectedParentMoods.add(tag);
                  }
                });
              },
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.warmPeach 
                      : AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.warmPeachDeep.withValues(alpha: 0.3)
                        : AppColors.warmGray200,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag.display,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected 
                        ? AppColors.warmGray800 
                        : AppColors.warmGray600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // 当时的你
        Text(
          '当时的你',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.warmGray500,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ContextTag.childStateTags.map((tag) {
            final isSelected = _selectedChildStates.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedChildStates.remove(tag);
                  } else {
                    _selectedChildStates.add(tag);
                  }
                });
              },
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.calmBlue 
                      : AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.calmBlueDeep.withValues(alpha: 0.3)
                        : AppColors.warmGray200,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag.display,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected 
                        ? AppColors.warmGray800 
                        : AppColors.warmGray600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _buildFutureMessageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmOrange.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.warmOrangeDeep.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '对未来说一句',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warmOrangeDark.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFutureMessage = !_showFutureMessage;
                  });
                },
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 40,
                  height: 22,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _showFutureMessage 
                        ? AppColors.warmOrangeDeep 
                        : AppColors.warmGray300,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: AnimatedAlign(
                    duration: AppDurations.fast,
                    alignment: _showFutureMessage 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showFutureMessage) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _futureMessageController,
              maxLength: 40,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '比如：原来你也会长这么快...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warmOrangeDark.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warmOrangeDark.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms);
  }

  void _showExitDialog(BuildContext context) {
    if (_textController.text.isEmpty) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          '要把这一刻带走，还是留下来？',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('带走'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('留下'),
          ),
        ],
      ),
    );
  }

  void _submitMoment(BuildContext context, user, childInfo) {
    final moment = Moment(
      id: const Uuid().v4(),
      author: user,
      content: _textController.text,
      mediaType: MediaType.text,
      timestamp: DateTime.now(),
      childAgeLabel: childInfo.ageLabel,
      contextTags: [
        ..._selectedParentMoods,
        ..._selectedChildStates,
      ],
      futureMessage: _showFutureMessage && _futureMessageController.text.isNotEmpty
          ? _futureMessageController.text
          : null,
    );

    ref.read(momentsProvider.notifier).addMoment(moment);

    // 显示成功反馈
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('这一刻，已经被你留住了。'),
        backgroundColor: AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    context.pop();
  }
}

/// 媒体按钮
class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.warmGray100,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.warmGray200,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.warmGray400,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
