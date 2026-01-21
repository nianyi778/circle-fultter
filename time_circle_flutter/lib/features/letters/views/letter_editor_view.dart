import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/letter.dart';

/// 灵感提示列表
const List<String> _inspirations = [
  "这一年最想记住的瞬间...",
  "做父母学会的一件事...",
  "对未来的期许...",
  "最近的一次大笑...",
  "最艰难的时刻...",
  "想对现在的你说...",
];

/// 信件编辑页（写作态）- 自由书写模式
class LetterEditorView extends ConsumerStatefulWidget {
  final String letterId;

  const LetterEditorView({super.key, required this.letterId});

  @override
  ConsumerState<LetterEditorView> createState() => _LetterEditorViewState();
}

class _LetterEditorViewState extends ConsumerState<LetterEditorView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _contentController;
  final FocusNode _focusNode = FocusNode();
  
  // 封存动画状态
  bool _isSealing = false;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    final letter = ref.read(letterByIdProvider(widget.letterId));
    _contentController = TextEditingController(
      text: letter?.content ?? 
        "亲爱的${letter?.recipient ?? '宝贝'}：\n\n",
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertInspiration(String text) {
    final cleanText = text.replaceAll('...', '');
    final newText = '${_contentController.text}\n\n[$cleanText]\n';
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: newText.length,
    );
  }

  Future<void> _handleSeal() async {
    setState(() => _isSealing = true);
    
    // 等待纸张下落动画
    await Future.delayed(AppDurations.ceremony);
    
    setState(() => _showToast = true);
    
    // 封存信件
    ref.read(lettersProvider.notifier).sealLetter(widget.letterId);
    
    // 显示 toast 后关闭
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter = ref.watch(letterByIdProvider(widget.letterId));
    final childInfo = ref.watch(childInfoProvider);

    if (letter == null) {
      return Scaffold(
        backgroundColor: AppColors.timeBeigeWarm,
        body: Center(
          child: Text(
            '信件不存在',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.warmGray500,
            ),
          ),
        ),
      );
    }

    final year = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.timeBeigeWarm,
      body: Stack(
        children: [
          // 纸张纹理背景
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.timeBeigeWarm,
                    AppColors.timeBeige,
                  ],
                ),
              ),
            ),
          ),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 顶部导航 - 封存时淡出
                AnimatedOpacity(
                  opacity: _isSealing ? 0 : 1,
                  duration: AppDurations.slow,
                  child: _buildHeader(context, letter),
                ),

                // 内容区域 - 封存时下落动画
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    transform: _isSealing 
                        ? (Matrix4.translationValues(0.0, 120.0, 0.0)..setEntry(0, 0, 0.9)..setEntry(1, 1, 0.9))
                        : Matrix4.identity(),
                    child: AnimatedOpacity(
                      opacity: _isSealing ? 0 : 1,
                      duration: const Duration(milliseconds: 800),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),

                            // 年份标签
                            _buildYearBadge(context, year),
                            const SizedBox(height: 16),

                            // 标题
                            Text(
                              '写给 ${childInfo.shortAgeLabel} 的${childInfo.name}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 500.ms),
                            const SizedBox(height: 8),

                            // 副标题
                            Text(
                              '没有固定的格式，只写你想留下的。',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.warmGray400,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                            const SizedBox(height: 32),

                            // 灵感提示区
                            _buildInspirationChips(context),

                            const SizedBox(height: 32),

                            // 自由书写区
                            _buildEditor(context),

                            // 装饰性结尾符号
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                '❧',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: AppColors.warmGray300,
                                ),
                              ),
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 底部封存按钮 - 封存时下滑消失
          AnimatedPositioned(
            duration: AppDurations.slow,
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isSealing ? -200 : 0,
            child: AnimatedOpacity(
              opacity: _isSealing ? 0 : 1,
              duration: AppDurations.normal,
              child: _buildSealButton(context),
            ),
          ),

          // 封存成功 Toast
          if (_showToast) _buildSealingToast(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Letter letter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _showExitDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: AppShadows.subtle,
              ),
              child: const Icon(
                Iconsax.close_circle,
                size: 20,
                color: AppColors.warmGray500,
              ),
            ),
          ),
          Row(
            children: [
              Icon(Iconsax.edit_2, size: 12, color: AppColors.warmGray400),
              const SizedBox(width: 4),
              Text(
                '年度信 · 草稿',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warmGray400,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // 占位平衡
        ],
      ),
    );
  }

  Widget _buildYearBadge(BuildContext context, int year) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warmGray100,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.calendar_1, size: 12, color: AppColors.warmGray500),
          const SizedBox(width: 6),
          Text(
            '$year 年',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.warmGray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      curve: Curves.easeOut,
    );
  }

  Widget _buildInspirationChips(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // 灵感标签
          Row(
            children: [
              Icon(
                Iconsax.magic_star5,
                size: 14,
                color: AppColors.warmOrangeDark,
              ),
              const SizedBox(width: 4),
              Text(
                '灵感',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warmOrangeDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // 灵感按钮列表
          ..._inspirations.map((text) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _insertInspiration(text),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.warmGray200),
                  boxShadow: AppShadows.subtle,
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warmGray500,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildEditor(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      child: TextField(
        controller: _contentController,
        focusNode: _focusNode,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 2.0,
          fontSize: 17,
          color: AppColors.warmGray700,
        ),
        decoration: InputDecoration(
          hintText: '在这里开始写...',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.warmGray300.withValues(alpha: 0.5),
            height: 2.0,
            fontSize: 17,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);
  }

  Widget _buildSealButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.timeBeigeWarm.withValues(alpha: 0),
            AppColors.timeBeigeWarm.withValues(alpha: 0.95),
            AppColors.timeBeigeWarm,
          ],
          stops: const [0, 0.3, 1],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 封存按钮
            GestureDetector(
              onTap: _handleSeal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.warmGray800,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warmGray400.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  '封存这一年',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 说明文字
            Text(
              '封存后不可修改正文，只允许追加"后记"',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSealingToast(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.warmGray800.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: AppShadows.elevated,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.softGreen.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.tick_circle5,
                size: 16,
                color: AppColors.softGreenDeep,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '这一刻，已经被你留住了。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        curve: Curves.easeOut,
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
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
            child: Text(
              '带走',
              style: TextStyle(color: AppColors.warmGray500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmGray800,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('留下'),
          ),
        ],
      ),
    );
  }
}
