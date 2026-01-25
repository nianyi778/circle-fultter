import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/models/user.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_popup_menu.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';

/// 成员管理页
class MembersView extends ConsumerStatefulWidget {
  const MembersView({super.key});

  @override
  ConsumerState<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends ConsumerState<MembersView> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(circleMembersProvider);
    final currentUser = ref.watch(currentUserSyncProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: const SettingsAppBar(title: '成员管理'),
      body: usersAsync.when(
        data: (users) => _buildContent(context, users, currentUser),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      // TODO: 添加成员需要通过邀请码，暂时隐藏添加按钮
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showInviteSheet(context),
      //   backgroundColor: const Color(0xFFE8A87C),
      //   child: const Icon(Iconsax.user_add, color: AppColors.white),
      // ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<User> users,
    User currentUser,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部说明
          SettingsHintBox(
            icon: Iconsax.people,
            message: '圈子成员可以查看和记录回忆，共同守护这段时光。\n通过邀请码邀请新成员加入。',
            style: HintBoxStyle.success,
          ),

          const SizedBox(height: 24),

          // 成员列表
          SettingsSectionTitle(title: '圈子成员 (${users.length})'),
          const SizedBox(height: 12),

          SettingsCard(
            child: Column(
              children:
                  users.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value;
                    final isLast = index == users.length - 1;
                    final isCurrentUser = user.id == currentUser.id;

                    return Column(
                      children: [
                        _buildMemberItem(
                          context,
                          user,
                          isCurrentUser: isCurrentUser,
                        ),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.only(left: 72),
                            child: Container(
                              height: 1,
                              color: AppColors.warmGray100,
                            ),
                          ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    User user, {
    required bool isCurrentUser,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // 头像
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warmGray200, width: 1),
            ),
            child: ClipOval(
              child: ImageUtils.buildAvatar(url: user.avatar, size: 44),
            ),
          ),
          const SizedBox(width: 14),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.body(
                        context,
                      ).copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8A87C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '我',
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFFE8A87C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (user.roleLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.roleLabel!,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray400),
                  ),
                ],
              ],
            ),
          ),
          // 操作按钮（仅管理员可以编辑其他成员）
          if (!isCurrentUser)
            GestureDetector(
              onTapDown: (details) {
                _showMemberMenu(context, details.globalPosition, user);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Iconsax.more,
                  size: 20,
                  color: AppColors.warmGray400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMemberMenu(BuildContext context, Offset position, User user) {
    showAppPopupMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 120,
        position.dy,
        position.dx,
        position.dy + 100,
      ),
      items: [
        AppPopupMenuItemData(
          icon: Iconsax.edit,
          label: '编辑角色',
          onTap: () => _showEditRoleLabelSheet(context, user),
        ),
        AppPopupMenuItemData(
          icon: Iconsax.trash,
          label: '移除成员',
          isDestructive: true,
          onTap: () => _confirmDeleteMember(context, user),
        ),
      ],
    );
  }

  void _showEditRoleLabelSheet(BuildContext context, User user) {
    final outerContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => _RoleLabelEditSheet(
            initialRoleLabel: user.roleLabel,
            onSave: (roleLabel) async {
              final repo = ref.read(memberRepositoryProvider);
              final selectedCircle = ref.read(selectedCircleProvider);

              if (selectedCircle == null) return;

              await repo.updateMember(
                circleId: selectedCircle.id,
                userId: user.id,
                roleLabel: roleLabel ?? '',
              );
              ref.invalidate(circleMembersProvider);
              if (sheetContext.mounted) {
                Navigator.pop(sheetContext);
              }
              if (outerContext.mounted) {
                outerContext.showSettingsMessage('角色标签已更新');
              }
            },
          ),
    );
  }

  void _confirmDeleteMember(BuildContext context, User user) {
    final outerContext = context;
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('确认移除'),
            content: Text('确定要将 ${user.name} 从圈子中移除吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final repo = ref.read(memberRepositoryProvider);
                  final selectedCircle = ref.read(selectedCircleProvider);

                  if (selectedCircle == null) return;

                  await repo.removeMember(
                    circleId: selectedCircle.id,
                    userId: user.id,
                  );
                  ref.invalidate(circleMembersProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (outerContext.mounted) {
                    outerContext.showSettingsMessage('成员已移除');
                  }
                },
                child: const Text('移除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

/// 角色标签编辑弹窗
class _RoleLabelEditSheet extends StatefulWidget {
  final String? initialRoleLabel;
  final Future<void> Function(String? roleLabel) onSave;

  const _RoleLabelEditSheet({this.initialRoleLabel, required this.onSave});

  @override
  State<_RoleLabelEditSheet> createState() => _RoleLabelEditSheetState();
}

class _RoleLabelEditSheetState extends State<_RoleLabelEditSheet> {
  late final TextEditingController _roleLabelController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roleLabelController = TextEditingController(text: widget.initialRoleLabel);
  }

  @override
  void dispose() {
    _roleLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '编辑角色标签',
                    style: AppTypography.subtitle(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 角色标签
              Text(
                '角色标签',
                style: AppTypography.caption(context).copyWith(
                  color: AppColors.warmGray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _roleLabelController,
                hintText: '如：妈妈、爸爸、闺蜜',
                autofocus: true,
              ),

              const SizedBox(height: 24),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8A87C),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                          : const Text(
                            '保存',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      final roleLabel = _roleLabelController.text.trim();
      await widget.onSave(roleLabel.isEmpty ? null : roleLabel);
    } catch (e) {
      if (mounted) {
        context.showSettingsMessage('保存失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
