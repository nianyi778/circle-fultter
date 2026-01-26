import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/date_wheel_picker.dart';

/// 圈子设置页面
///
/// 新用户注册后需要创建或加入一个圈子
/// 设计理念：
/// - 两个选项卡：创建新圈子 / 加入已有圈子
/// - 简洁的表单设计
class CircleSetupView extends ConsumerStatefulWidget {
  const CircleSetupView({super.key});

  @override
  ConsumerState<CircleSetupView> createState() => _CircleSetupViewState();
}

class _CircleSetupViewState extends ConsumerState<CircleSetupView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 创建圈子表单
  final _createFormKey = GlobalKey<FormState>();
  final _circleNameController = TextEditingController();
  DateTime? _startDate;

  // 加入圈子表单
  final _joinFormKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _roleLabelController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _circleNameController.dispose();
    _inviteCodeController.dispose();
    _roleLabelController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateCircle() async {
    if (!_createFormKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authProvider.notifier)
          .createCircle(
            name: _circleNameController.text.trim(),
            startDate: _startDate,
          );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleJoinCircle() async {
    if (!_joinFormKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authProvider.notifier)
          .joinCircle(
            inviteCode: _inviteCodeController.text.trim().toUpperCase(),
            roleLabel:
                _roleLabelController.text.trim().isEmpty
                    ? null
                    : _roleLabelController.text.trim(),
          );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showDatePicker() async {
    final date = await DateWheelPicker.show(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      title: '选择起始日期',
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: Stack(
        children: [
          // 背景光晕
          _buildBackgroundGlows(),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 头部
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // 欢迎语
                      Text(
                        '欢迎，${user?.name ?? ''}',
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warmGray800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '创建或加入一个圈子，开始记录你们的故事',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 14,
                          color: AppColors.warmGray500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 选项卡
                _buildTabBar(),

                // 内容
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildCreateTab(), _buildJoinTab()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 背景光晕效果
  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 选项卡栏
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.warmGray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppShadows.subtle,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: AppColors.warmGray800,
        unselectedLabelColor: AppColors.warmGray500,
        labelStyle: GoogleFonts.notoSansSc(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSansSc(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [Tab(text: '创建新圈子'), Tab(text: '加入已有圈子')],
      ),
    );
  }

  /// 创建圈子选项卡
  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _createFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圈子类型提示
            _buildCircleTypeSuggestions(),

            const SizedBox(height: 32),

            // 圈子名称
            Text(
              '圈子名称',
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.warmGray700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _circleNameController,
              style: GoogleFonts.notoSansSc(
                fontSize: 16,
                color: AppColors.warmGray800,
              ),
              decoration: InputDecoration(
                hintText: '给圈子起个名字',
                hintStyle: GoogleFonts.notoSansSc(
                  fontSize: 16,
                  color: AppColors.warmGray400,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray250,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray250,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray400,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入圈子名称';
                }
                if (value.length > 20) {
                  return '名称最多20个字符';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // 起始日期（可选）
            Text(
              '起始日期（可选）',
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.warmGray700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '可以是你们相识的日期、纪念日等',
              style: GoogleFonts.notoSansSc(
                fontSize: 12,
                color: AppColors.warmGray400,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warmGray250, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.warmGray400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.year}年${_startDate!.month}月${_startDate!.day}日'
                            : '选择日期',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 16,
                          color:
                              _startDate != null
                                  ? AppColors.warmGray800
                                  : AppColors.warmGray400,
                        ),
                      ),
                    ),
                    if (_startDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _startDate = null),
                        child: Icon(
                          Icons.close,
                          color: AppColors.warmGray400,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 创建按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleCreateCircle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmGray800,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.warmGray400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    _isSubmitting
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                        : Text(
                          '创建圈子',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 圈子类型建议
  Widget _buildCircleTypeSuggestions() {
    final suggestions = [
      {'icon': Icons.child_care_rounded, 'label': '亲子圈', 'example': '如：小明的时光记'},
      {'icon': Icons.favorite_rounded, 'label': '情侣圈', 'example': '如：我们的恋爱日记'},
      {'icon': Icons.people_rounded, 'label': '好友圈', 'example': '如：闺蜜时光'},
      {'icon': Icons.person_rounded, 'label': '个人独白', 'example': '如：我的时间胶囊'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '圈子可以是...',
          style: GoogleFonts.notoSansSc(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.warmGray600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              suggestions.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.warmGray200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                          color: AppColors.warmGray700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// 加入圈子选项卡
  Widget _buildJoinTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _joinFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '向圈子创建者索取邀请码即可加入',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 13,
                        color: AppColors.warmGray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 邀请码
            Text(
              '邀请码',
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.warmGray700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _inviteCodeController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                color: AppColors.warmGray800,
              ),
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: AppColors.warmGray300,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray250,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray250,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray400,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入邀请码';
                }
                if (value.length < 6) {
                  return '邀请码格式不正确';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // 你的称呼（可选）
            Text(
              '你在圈子中的称呼（可选）',
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.warmGray700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '如：爸爸、妈妈、闺蜜等',
              style: GoogleFonts.notoSansSc(
                fontSize: 12,
                color: AppColors.warmGray400,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _roleLabelController,
              style: GoogleFonts.notoSansSc(
                fontSize: 16,
                color: AppColors.warmGray800,
              ),
              decoration: InputDecoration(
                hintText: '输入你的称呼',
                hintStyle: GoogleFonts.notoSansSc(
                  fontSize: 16,
                  color: AppColors.warmGray400,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray250,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray250,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.warmGray400,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 加入按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleJoinCircle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmGray800,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.warmGray400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    _isSubmitting
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                        : Text(
                          '加入圈子',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
