import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/settings/settings_widgets.dart';

/// 个人资料编辑页
class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({super.key});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  final _nameController = TextEditingController();
  final _roleLabelController = TextEditingController();
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserSyncProvider);
    _nameController.text = user.name;
    _roleLabelController.text = user.roleLabel ?? '';
    _avatarPath = user.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleLabelController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _avatarPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      context.showSettingsMessage('请输入名称');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserSyncProvider);
      final api = ApiService.instance;

      // 构建更新数据
      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
      };

      // 角色标签（允许清空）
      final roleLabel = _roleLabelController.text.trim();
      updateData['roleLabel'] = roleLabel.isEmpty ? null : roleLabel;

      // 如果更换了头像（本地路径），需要先上传
      if (_avatarPath != null &&
          _avatarPath != user.avatar &&
          _avatarPath!.startsWith('/')) {
        final file = File(_avatarPath!);
        if (!await file.exists()) {
          throw Exception('头像文件不存在');
        }

        final bytes = await file.readAsBytes();
        final filename = path.basename(file.path);

        // 1) 获取上传地址
        final uploadResponse = await api.post<Map<String, dynamic>>(
          ApiConfig.mediaUploadUrl,
          data: {
            'filename': filename,
            'contentType': 'image/jpeg',
            'size': bytes.length,
          },
          fromData: (data) => data as Map<String, dynamic>,
        );

        if (!uploadResponse.success || uploadResponse.data == null) {
          throw Exception(uploadResponse.error?.message ?? '获取上传地址失败');
        }

        final uploadUrl = uploadResponse.data!['uploadUrl'] as String;
        final key = uploadResponse.data!['key'] as String;

        // 2) 上传文件
        await api.uploadFile(
          '${ApiConfig.baseUrl}$uploadUrl',
          bytes,
          contentType: 'image/jpeg',
        );

        // 3) 完成上传，获取最终 URL
        final completeResponse = await api.post<Map<String, dynamic>>(
          ApiConfig.mediaComplete,
          data: {'key': key},
          fromData: (data) => data as Map<String, dynamic>,
        );

        if (!completeResponse.success || completeResponse.data == null) {
          throw Exception(completeResponse.error?.message ?? '确认上传失败');
        }

        final mediaUrl = completeResponse.data!['url'] as String;
        updateData['avatar'] = '${ApiConfig.baseUrl}$mediaUrl';
      } else if (_avatarPath != null && _avatarPath != user.avatar) {
        updateData['avatar'] = _avatarPath;
      }

      // 调用 API 更新用户信息
      final response = await api.put(ApiConfig.authMe, data: updateData);

      if (!response.success) {
        throw Exception(response.error?.message ?? '更新失败');
      }

      // 刷新认证状态
      await ref.read(authProvider.notifier).refresh();

      if (mounted) {
        context.showSettingsMessage('保存成功');
        context.pop();
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      appBar: SettingsAppBar(
        title: '个人资料',
        actions: [
          SettingsSaveButton(onPressed: _saveProfile, isLoading: _isLoading),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像区域
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.warmGray200,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            _avatarPath != null && _avatarPath!.startsWith('/')
                                ? Image.file(
                                  File(_avatarPath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                : ImageUtils.buildAvatar(
                                  url: _avatarPath,
                                  size: 100,
                                ),
                      ),
                    ),
                    // 编辑图标
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8A87C),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(
                          Iconsax.camera,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                '点击更换头像',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
            ),

            const SizedBox(height: 32),

            // 名称输入
            const SettingsSectionTitle(title: '名称'),
            const SizedBox(height: 8),
            AppTextField(controller: _nameController, hintText: '输入你的名称'),

            const SizedBox(height: 24),

            // 角色标签
            const SettingsSectionTitle(
              title: '角色标签',
              subtitle: '可选，如"妈妈"、"爸爸"、"闺蜜"等',
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _roleLabelController,
              hintText: '输入角色标签（可选）',
            ),

            const SizedBox(height: 40),

            // 提示说明
            const SettingsHintBox(
              icon: Iconsax.info_circle,
              message: '你的资料仅在圈子内可见，不会公开显示',
              style: HintBoxStyle.neutral,
            ),
          ],
        ),
      ),
    );
  }
}
