import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';
import '../../../core/models/user.dart';

AssetPickerConfig _buildAssetPickerConfig(
  int maxAssets, {
  RequestType requestType = RequestType.image,
}) {
  return AssetPickerConfig(
    maxAssets: maxAssets,
    requestType: requestType,
    themeColor: AppColors.softGreenDeep,
    gridCount: 3,
  );
}

/// 发布页（「留下」）- 参考 Web 版优化设计
class CreateMomentView extends ConsumerStatefulWidget {
  const CreateMomentView({super.key});

  @override
  ConsumerState<CreateMomentView> createState() => _CreateMomentViewState();
}

class _CreateMomentViewState extends ConsumerState<CreateMomentView> {
  final _textController = TextEditingController();

  final Set<ContextTag> _selectedMyMoods = {};
  final Set<ContextTag> _selectedAtmospheres = {};
  
  // 发布到世界
  bool _shareToWorld = false;
  String _worldTopic = '生活碎片';
  
  // 世界话题选项
  static const List<String> _worldTopicOptions = [
    '生活碎片',
    '今天很累',
    '写给未来',
    '小确幸',
    '想分享',
  ];

  // 已选择的媒体文件
  final List<XFile> _selectedMedia = [];
  MediaType _mediaType = MediaType.text;

  // 我的心情选项
  static const List<ContextTag> _myMoodOptions = [
    ContextTag(type: ContextTagType.myMood, emoji: '😌', label: '平静'),
    ContextTag(type: ContextTagType.myMood, emoji: '😊', label: '开心'),
    ContextTag(type: ContextTagType.myMood, emoji: '😵‍💫', label: '累'),
    ContextTag(type: ContextTagType.myMood, emoji: '🥹', label: '想哭'),
    ContextTag(type: ContextTagType.myMood, emoji: '😟', label: '担心'),
  ];

  // 当时的氛围选项
  static const List<ContextTag> _atmosphereOptions = [
    ContextTag(type: ContextTagType.atmosphere, emoji: '🫂', label: '温馨'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '⚡️', label: '热闹'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '🤫', label: '安静'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '☕️', label: '日常'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '✨', label: '特别'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用同步 provider，确保数据可用
    final childInfo = ref.watch(childInfoProvider);
    final currentUser = ref.watch(currentUserSyncProvider);
    final hasContent = _textController.text.isNotEmpty || _selectedMedia.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航 - 简洁风格
            _buildHeader(context, hasContent, currentUser, childInfo),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 文字输入区
                    _buildTextInput(context),

                    const SizedBox(height: 24),

                    // 媒体按钮
                    _buildMediaButtons(context),

                    const SizedBox(height: 32),

                    // 语境标注区
                    _buildContextSection(context),

                    const SizedBox(height: 24),

                    // 对未来说一句
                    _buildFutureMessageSection(context),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildHeader(
    BuildContext context,
    bool hasContent,
    user,
    childInfo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGray200.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 关闭按钮
          GestureDetector(
            onTap: () => _showExitDialog(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.close, size: 24, color: AppColors.warmGray400),
            ),
          ),

          // 标题
          Expanded(
            child: Text(
              '留下此刻',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warmGray600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 提交按钮
          GestureDetector(
            onTap: hasContent
                ? () => _submitMoment(context, user, childInfo)
                : null,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: hasContent ? AppColors.warmGray800 : AppColors.warmGray100,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '留下',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: hasContent ? AppColors.white : AppColors.warmGray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  /// 文字输入区域 - 参考 Web 版简洁风格
  Widget _buildTextInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主输入框 - 完全透明，无边框
        TextField(
          controller: _textController,
          maxLines: 6,
          minLines: 4,
          autofocus: true,
          onChanged: (value) => setState(() {}),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            height: 1.8,
            color: AppColors.warmGray800,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            hintText: '这一刻，你想留下些什么？',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: AppColors.warmGray300,
              height: 1.8,
              letterSpacing: 0.3,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  /// 媒体按钮区域 - 虚线边框风格
  Widget _buildMediaButtons(BuildContext context) {
    final hasMedia = _selectedMedia.isNotEmpty;
    final isImage = _mediaType == MediaType.image;
    final isVideo = _mediaType == MediaType.video;
    final isAudio = _mediaType == MediaType.audio;
    final isAlbumActive = isImage || isVideo;
    final isAlbumDisabled = hasMedia && isAudio;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已选择的媒体预览
        if (_selectedMedia.isNotEmpty) ...[
          _buildMediaPreview(context),
          const SizedBox(height: 12),
        ],
        
        // 媒体选择按钮（根据已选类型显示不同状态）
        Row(
          children: [
            // 相册按钮（照片/视频）
            _MediaButton(
              icon: isVideo ? Iconsax.video : Iconsax.gallery,
              label: _getAlbumButtonLabel(),
              onTap: isAlbumDisabled ? null : _onAlbumPressed,
              isDisabled: isAlbumDisabled,
              isActive: isAlbumActive,
            ),
            const SizedBox(width: 12),
            // 音频按钮
            _MediaButton(
              icon: Iconsax.microphone,
              label: '音频',
              onTap: hasMedia && !isAudio ? null : _pickAudio,
              isDisabled: hasMedia && !isAudio,
              isActive: isAudio,
            ),
          ],
        ),
        
        // 提示文字
        if (hasMedia)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getMediaHint(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray400,
                fontSize: 11,
              ),
            ),
          ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  /// 获取媒体提示文字
  String _getMediaHint() {
    switch (_mediaType) {
      case MediaType.image:
        return '已选 ${_selectedMedia.length} 张照片，最多 9 张';
      case MediaType.video:
        return '已选视频，时长限制 1 分钟';
      case MediaType.audio:
        return '已选音频，时长限制 30 分钟';
      case MediaType.text:
        return '';
    }
  }

  String _getAlbumButtonLabel() {
    switch (_mediaType) {
      case MediaType.image:
        return '${_selectedMedia.length}/9';
      case MediaType.video:
        return '视频';
      case MediaType.audio:
      case MediaType.text:
        return '相册';
    }
  }

  void _onAlbumPressed() {
    if (_mediaType == MediaType.image && _selectedMedia.isNotEmpty) {
      _pickImages();
      return;
    }
    if (_mediaType == MediaType.video && _selectedMedia.isNotEmpty) {
      _pickVideo();
      return;
    }
    _showMediaTypePicker();
  }

  /// 显示媒体类型选择（照片/视频）
  void _showMediaTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMediaTypeOption(
              context: ctx,
              icon: Iconsax.image,
              label: '照片',
              hint: '最多 9 张',
              onTap: () {
                Navigator.pop(ctx);
                _pickImages();
              },
            ),
            const Divider(height: 1),
            _buildMediaTypeOption(
              context: ctx,
              icon: Iconsax.video,
              label: '视频',
              hint: '时长 1 分钟内',
              onTap: () {
                Navigator.pop(ctx);
                _pickVideo();
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '取消',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.warmGray600, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmGray800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warmGray400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 已选择媒体预览 - 仿微信朋友圈风格
  Widget _buildMediaPreview(BuildContext context) {
    final isVideo = _mediaType == MediaType.video;
    
    // 视频只显示一个
    if (isVideo) {
      return _buildVideoPreview(context, _selectedMedia.first);
    }

    // 计算网格布局
    final screenWidth = MediaQuery.of(context).size.width - 40; // 减去左右边距
    final maxGridWidth = screenWidth * 0.75; // 最大宽度为屏幕的 75%
    
    return _WechatStyleImageGrid(
      images: _selectedMedia,
      maxWidth: maxGridWidth,
      onRemove: (index) {
        setState(() {
          _selectedMedia.removeAt(index);
          if (_selectedMedia.isEmpty) {
            _mediaType = MediaType.text;
          }
        });
      },
    );
  }

  /// 视频预览
  Widget _buildVideoPreview(BuildContext context, XFile video) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.warmGray800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.video_play, color: AppColors.white, size: 40),
                SizedBox(height: 8),
                Text(
                  '视频已选择',
                  style: TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMedia.clear();
                _mediaType = MediaType.text;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.warmGray900.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  /// 选择照片（最多9张）
  Future<void> _pickImages() async {
    try {
      // 请求权限
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请允许访问相册以选择照片'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
          PhotoManager.openSetting();
        }
        return;
      }

      // 计算还能选多少张
      final currentCount = _mediaType == MediaType.image ? _selectedMedia.length : 0;
      final remaining = 9 - currentCount;
      
      if (remaining <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('最多只能选择 9 张照片'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      
      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildAssetPickerConfig(remaining),
      );

      if (!mounted || assets == null || assets.isEmpty) {
        return;
      }

      final files = await Future.wait(assets.map((asset) => asset.file));
      final pickedFiles = files.whereType<File>().toList();

      if (pickedFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('读取照片失败'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      setState(() {
        if (_mediaType != MediaType.image) {
          // 切换类型时清空
          _selectedMedia.clear();
        }

        _selectedMedia.addAll(pickedFiles.map((file) => XFile(file.path)));
        _mediaType = MediaType.image;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择照片失败: $e'),
            backgroundColor: AppColors.warmGray800,
          ),
        );
      }
    }
  }

  /// 选择视频（最多1个，时长1分钟）
  Future<void> _pickVideo() async {
    try {
      // 请求权限
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请允许访问相册以选择视频'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
          PhotoManager.openSetting();
        }
        return;
      }

      if (!mounted) return;

      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildAssetPickerConfig(
          1,
          requestType: RequestType.video,
        ),
      );

      if (!mounted || assets == null || assets.isEmpty) {
        return;
      }

      final asset = assets.first;
      if (asset.duration > 60) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('视频时长需在 1 分钟以内'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      final file = await asset.file;
      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('读取视频失败'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(XFile(file.path));
        _mediaType = MediaType.video;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择视频失败: $e'),
            backgroundColor: AppColors.warmGray800,
          ),
        );
      }
    }
  }

  /// 选择音频（最多1个，时长30分钟）
  /// 注意：image_picker 不支持音频，这里暂时显示提示
  Future<void> _pickAudio() async {
    // TODO: 集成 file_picker 或其他音频选择库
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音频选择功能开发中，敬请期待'),
          backgroundColor: AppColors.warmGray800,
        ),
      );
    }
  }

  /// 语境标注区
  Widget _buildContextSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 我的心情
        _buildContextLabel(context, '我的心情'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _myMoodOptions.map((tag) {
            final isSelected = _selectedMyMoods.contains(tag);
            return _ContextChip(
              tag: tag,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMyMoods.remove(tag);
                  } else {
                    _selectedMyMoods.add(tag);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 当时的氛围
        _buildContextLabel(context, '当时的氛围'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _atmosphereOptions.map((tag) {
            final isSelected = _selectedAtmospheres.contains(tag);
            return _ContextChip(
              tag: tag,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAtmospheres.remove(tag);
                  } else {
                    _selectedAtmospheres.add(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildContextLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.warmGray300,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        fontSize: 10,
      ),
    );
  }

  /// 发布到世界
  Widget _buildFutureMessageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _shareToWorld 
            ? AppColors.warmOrange.withValues(alpha: 0.15)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _shareToWorld 
              ? AppColors.warmOrangeDeep.withValues(alpha: 0.2)
              : AppColors.warmGray200.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGray900.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.global,
                    size: 16,
                    color: _shareToWorld 
                        ? AppColors.warmOrangeDeep 
                        : AppColors.warmGray400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '发布到世界',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _shareToWorld 
                          ? AppColors.warmGray800 
                          : AppColors.warmGray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // 开关
              GestureDetector(
                onTap: () {
                  setState(() {
                    _shareToWorld = !_shareToWorld;
                  });
                },
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 40,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _shareToWorld
                        ? AppColors.warmOrangeDeep
                        : AppColors.warmGray300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: AppDurations.fast,
                    alignment: _shareToWorld
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warmGray900.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 话题选择
          if (_shareToWorld) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.warmGray100,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择话题',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray400,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _worldTopicOptions.map((topic) {
                      final isSelected = _worldTopic == topic;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _worldTopic = topic;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.warmOrange.withValues(alpha: 0.3)
                                : AppColors.warmGray50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.warmOrangeDeep.withValues(alpha: 0.3)
                                  : AppColors.warmGray100,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '#$topic',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected 
                                  ? AppColors.warmOrangeDark 
                                  : AppColors.warmGray500,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
  }

  void _showExitDialog(BuildContext context) {
    if (_textController.text.isEmpty && _selectedMedia.isEmpty) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Text(
          '要把这一刻带走，还是留下来？',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warmGray500,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('带走'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmGray800,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              elevation: 0,
            ),
            child: const Text('留下'),
          ),
        ],
      ),
    );
  }

  void _submitMoment(BuildContext context, User user, CircleInfo circleInfo) {
    // 取第一个媒体路径（当前模型只支持单个）
    final mediaUrl = _selectedMedia.isNotEmpty ? _selectedMedia.first.path : null;
    
    final moment = Moment(
      id: const Uuid().v4(),
      author: user,
      content: _textController.text,
      mediaType: _mediaType,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
      timeLabel: circleInfo.ageLabel,
      contextTags: [
        ..._selectedMyMoods,
        ..._selectedAtmospheres,
      ],
      isSharedToWorld: _shareToWorld,
      worldTopic: _shareToWorld ? _worldTopic : null,
    );

    ref.read(momentsProvider.notifier).addMoment(moment);

    // 显示成功反馈
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.softGreen.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle5,
                size: 16,
                color: AppColors.softGreenDeep,
              ),
            ),
            const SizedBox(width: 12),
            const Text('这一刻，已经被你留住了。'),
          ],
        ),
        backgroundColor: AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );

    context.pop();
  }
}

/// 媒体按钮 - 虚线边框风格
class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isActive;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled 
        ? AppColors.warmGray200 
        : isActive 
            ? AppColors.calmBlue 
            : AppColors.warmGray400;
    final bgColor = isDisabled 
        ? AppColors.warmGray100.withValues(alpha: 0.5)
        : isActive 
            ? AppColors.calmBlue.withValues(alpha: 0.08)
            : AppColors.warmGray50;
    final borderColor = isDisabled
        ? AppColors.warmGray100
        : isActive
            ? AppColors.calmBlue.withValues(alpha: 0.3)
            : AppColors.warmGray200;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: borderColor,
              strokeWidth: 1.5,
              radius: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: effectiveColor,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: effectiveColor,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 虚线边框绘制器
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 16,
    // ignore: unused_element_parameter
    this.dashWidth = 6,
    // ignore: unused_element_parameter
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    // 绘制虚线
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 语境标签 Chip
class _ContextChip extends StatelessWidget {
  final ContextTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContextChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warmGray100
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.warmGray300
                : AppColors.warmGray200,
            width: 1,
          ),
        ),
        child: Text(
          '${tag.emoji} ${tag.label}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected
                ? AppColors.warmGray800
                : AppColors.warmGray600,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// 创建时刻浮层 Modal - 仿 Web 版效果
class CreateMomentModal extends ConsumerStatefulWidget {
  const CreateMomentModal({super.key});

  @override
  ConsumerState<CreateMomentModal> createState() => _CreateMomentModalState();
}

class _CreateMomentModalState extends ConsumerState<CreateMomentModal> {
  final _textController = TextEditingController();

  final Set<ContextTag> _selectedMyMoods = {};
  final Set<ContextTag> _selectedAtmospheres = {};
  
  // 发布到世界
  bool _shareToWorld = false;
  String _worldTopic = '生活碎片';
  
  // 世界话题选项
  static const List<String> _worldTopicOptions = [
    '生活碎片',
    '今天很累',
    '写给未来',
    '小确幸',
    '想分享',
  ];

  final List<XFile> _selectedMedia = [];
  MediaType _mediaType = MediaType.text;
  
  // 位置信息
  String? _locationName;
  
  // 拖拽删除状态
  bool _isDragging = false;
  bool _isOverDeleteZone = false;

  static const List<ContextTag> _myMoodOptions = [
    ContextTag(type: ContextTagType.myMood, emoji: '😌', label: '平静'),
    ContextTag(type: ContextTagType.myMood, emoji: '😊', label: '开心'),
    ContextTag(type: ContextTagType.myMood, emoji: '😵‍💫', label: '累'),
    ContextTag(type: ContextTagType.myMood, emoji: '🥹', label: '想哭'),
    ContextTag(type: ContextTagType.myMood, emoji: '😟', label: '担心'),
  ];

  static const List<ContextTag> _atmosphereOptions = [
    ContextTag(type: ContextTagType.atmosphere, emoji: '🫂', label: '温馨'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '⚡️', label: '热闹'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '🤫', label: '安静'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '☕️', label: '日常'),
    ContextTag(type: ContextTagType.atmosphere, emoji: '✨', label: '特别'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _hasContent => _textController.text.isNotEmpty || _selectedMedia.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          height: screenHeight * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 顶部 Header
              _buildHeader(context),

              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextInput(context),
                      const SizedBox(height: 16),
                      _buildWechatStyleMedia(context),
                      const SizedBox(height: 20),
                      _buildBottomOptions(context),
                      const SizedBox(height: 20),
                      _buildContextSection(context),
                      const SizedBox(height: 24),
                      _buildFutureMessageSection(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 拖拽删除区域（底部）
        if (_isDragging) _buildDeleteZone(context),
      ],
    ).animate().slideY(
      begin: 0.1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    );
  }

  /// 拖拽删除区域
  Widget _buildDeleteZone(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          if (!_isOverDeleteZone) {
            setState(() => _isOverDeleteZone = true);
          }
          return true;
        },
        onLeave: (data) {
          if (_isOverDeleteZone) {
            setState(() => _isOverDeleteZone = false);
          }
        },
        onAcceptWithDetails: (details) {
          final index = details.data;
          setState(() {
            _selectedMedia.removeAt(index);
            if (_selectedMedia.isEmpty) _mediaType = MediaType.text;
            _isDragging = false;
            _isOverDeleteZone = false;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isOverDeleteZone ? 80 : 60,
            decoration: BoxDecoration(
              color: _isOverDeleteZone 
                  ? const Color(0xFFE53935)  // 红色高亮
                  : const Color(0xFFEF5350).withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isOverDeleteZone ? Iconsax.trash : Iconsax.trash,
                  color: AppColors.white,
                  size: _isOverDeleteZone ? 28 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  _isOverDeleteZone ? '松手删除' : '拖动到此处删除',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 1, end: 0, duration: 200.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGray200.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 关闭按钮
          GestureDetector(
            onTap: () => _showExitDialog(context),
            child: Icon(
              Icons.close,
              color: AppColors.warmGray400,
              size: 24,
            ),
          ),

          // 标题
          Expanded(
            child: Text(
              '留下此刻',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.warmGray600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 留下按钮
          GestureDetector(
            onTap: _hasContent ? () => _submitMoment(context) : null,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _hasContent ? AppColors.warmGray800 : AppColors.warmGray200,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '留下',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _hasContent ? AppColors.white : AppColors.warmGray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context) {
    return TextField(
      controller: _textController,
      maxLines: 6,
      minLines: 4,
      autofocus: true,
      onChanged: (value) => setState(() {}),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.6,
        color: AppColors.warmGray700,
      ),
      decoration: InputDecoration(
        hintText: '这一刻，你想留下些什么？',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.warmGray300,
          height: 1.6,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
    );
  }

  /// 微信风格的媒体选择区域
  Widget _buildWechatStyleMedia(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final itemSize = (screenWidth - 8) / 3; // 3列，间距4
    final isImage = _mediaType == MediaType.image;
    final isVideo = _mediaType == MediaType.video;
    final canAddMore = isImage && _selectedMedia.length < 9;
    
    // 没有选择任何媒体时，显示添加按钮
    if (_selectedMedia.isEmpty) {
      return GestureDetector(
        onTap: _onAlbumPressed,
        child: Container(
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(
            color: AppColors.warmGray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warmGray100, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.warmGray300, size: 36),
              const SizedBox(height: 4),
              Text(
                '添加',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warmGray300,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 视频预览
    if (isVideo) {
      return _buildVideoPreviewWechat(context, itemSize);
    }
    
    // 图片网格（微信风格）
    final totalItems = canAddMore ? _selectedMedia.length + 1 : _selectedMedia.length;
    final rows = (totalItems / 3).ceil();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 拖拽提示（可选）
        if (_selectedMedia.length > 1)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warmGray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '已选 ${_selectedMedia.length} 张照片',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMedia.clear();
                      _mediaType = MediaType.text;
                    });
                  },
                  child: Icon(Icons.close, size: 16, color: AppColors.warmGray500),
                ),
              ],
            ),
          ),
        
        // 图片网格
        SizedBox(
          height: rows * (itemSize + 4) - 4,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // 最后一个是添加按钮
              if (canAddMore && index == _selectedMedia.length) {
                return _buildAddButton(itemSize);
              }
              return _buildImageItem(context, index, itemSize);
            },
          ),
        ),
      ],
    );
  }

  /// 添加按钮
  Widget _buildAddButton(double size) {
    return GestureDetector(
      onTap: _onAlbumPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.warmGray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warmGray100, width: 0.5),
        ),
        child: const Icon(Icons.add, color: AppColors.warmGray300, size: 32),
      ),
    );
  }

  /// 图片项（可拖拽删除）
  Widget _buildImageItem(BuildContext context, int index, double size) {
    final file = _selectedMedia[index];
    
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(file.path),
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
    
    return LongPressDraggable<int>(
      data: index,
      onDragStarted: () {
        setState(() => _isDragging = true);
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _isOverDeleteZone = false;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _isDragging = false;
          _isOverDeleteZone = false;
        });
      },
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: size * 1.1,
          height: size * 1.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: imageWidget,
        ),
      ),
      childWhenDragging: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.warmGray200.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: imageWidget,
    );
  }

  /// 微信风格视频预览（带播放按钮，可拖拽删除）
  Widget _buildVideoPreviewWechat(BuildContext context, double size) {
    final videoFile = _selectedMedia.first;
    
    final videoWidget = Stack(
      children: [
        // 视频预览区域
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size,
            color: AppColors.warmGray200,
            child: FutureBuilder<Widget>(
              future: _buildVideoThumbnail(videoFile, size),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return Container(
                  color: AppColors.warmGray800,
                  child: const Center(
                    child: Icon(Iconsax.video, color: AppColors.white, size: 40),
                  ),
                );
              },
            ),
          ),
        ),
        // 播放按钮覆盖层
        Positioned.fill(
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warmGray900.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white.withValues(alpha: 0.8), width: 2),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
    
    return LongPressDraggable<int>(
      data: 0,
      onDragStarted: () {
        setState(() => _isDragging = true);
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _isOverDeleteZone = false;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _isDragging = false;
          _isOverDeleteZone = false;
        });
      },
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: size * 1.1,
          height: size * 1.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: videoWidget,
        ),
      ),
      childWhenDragging: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.warmGray200.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: videoWidget,
    );
  }

  /// 生成视频缩略图
  Future<Widget> _buildVideoThumbnail(XFile videoFile, double size) async {
    // 由于 Flutter 原生不支持直接生成视频缩略图
    // 可以集成 video_thumbnail 包来实现
    // 这里使用占位样式
    return Container(
      width: size,
      height: size,
      color: AppColors.warmGray800,
      child: const Center(
        child: Icon(Iconsax.video, color: AppColors.warmGray400, size: 40),
      ),
    );
  }

  void _onAlbumPressed() {
    if (_mediaType == MediaType.image && _selectedMedia.isNotEmpty) {
      _pickImages();
      return;
    }
    if (_mediaType == MediaType.video && _selectedMedia.isNotEmpty) {
      _pickVideo();
      return;
    }
    _showMediaTypePicker();
  }

  /// 显示媒体类型选择
  void _showMediaTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMediaTypeOption(
              context: ctx,
              icon: Iconsax.image,
              label: '照片',
              hint: '最多 9 张',
              onTap: () {
                Navigator.pop(ctx);
                _pickImages();
              },
            ),
            const Divider(height: 1),
            _buildMediaTypeOption(
              context: ctx,
              icon: Iconsax.video,
              label: '视频',
              hint: '时长 1 分钟内',
              onTap: () {
                Navigator.pop(ctx);
                _pickVideo();
              },
            ),
            const Divider(height: 1),
            _buildMediaTypeOption(
              context: ctx,
              icon: Iconsax.microphone,
              label: '音频',
              hint: '时长 30 分钟内',
              onTap: () {
                Navigator.pop(ctx);
                _pickAudio();
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '取消',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.warmGray600, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmGray800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warmGray400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.warmGray300, size: 20),
          ],
        ),
      ),
    );
  }

  /// 底部选项区域（微信风格）
  Widget _buildBottomOptions(BuildContext context) {
    final hasLocation = _locationName != null;
    // 微信风格的绿色
    const wechatGreen = Color(0xFF07C160);
    
    return Column(
      children: [
        Divider(height: 1, color: AppColors.warmGray100.withValues(alpha: 0.5)),
        // 位置选项
        GestureDetector(
          onTap: _selectLocation,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  hasLocation ? Iconsax.location5 : Iconsax.location,
                  color: hasLocation ? wechatGreen : AppColors.warmGray400,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locationName ?? '所在位置',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasLocation ? wechatGreen : AppColors.warmGray400,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.warmGray200, size: 18),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: AppColors.warmGray100.withValues(alpha: 0.5)),
      ],
    );
  }

  /// 选择位置 - 全屏页面（微信风格）
  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (context) => const _LocationPickerPage(),
      ),
    );
    
    if (result != null) {
      setState(() {
        _locationName = result.isEmpty ? null : result;
      });
    }
  }

  Widget _buildContextSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContextLabel(context, '我的心情'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _myMoodOptions.map((tag) {
            final isSelected = _selectedMyMoods.contains(tag);
            return _ContextChip(
              tag: tag,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMyMoods.remove(tag);
                  } else {
                    _selectedMyMoods.add(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildContextLabel(context, '当时的氛围'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _atmosphereOptions.map((tag) {
            final isSelected = _selectedAtmospheres.contains(tag);
            return _ContextChip(
              tag: tag,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAtmospheres.remove(tag);
                  } else {
                    _selectedAtmospheres.add(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContextLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.warmGray400,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        fontSize: 11,
      ),
    );
  }

  Widget _buildFutureMessageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _shareToWorld 
            ? AppColors.warmOrange.withValues(alpha: 0.15)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _shareToWorld 
              ? AppColors.warmOrangeDeep.withValues(alpha: 0.2)
              : AppColors.warmGray200.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGray900.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.global,
                    size: 16,
                    color: _shareToWorld 
                        ? AppColors.warmOrangeDeep 
                        : AppColors.warmGray400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '发布到世界',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _shareToWorld 
                          ? AppColors.warmGray800 
                          : AppColors.warmGray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // 开关
              GestureDetector(
                onTap: () {
                  setState(() {
                    _shareToWorld = !_shareToWorld;
                  });
                },
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 40,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _shareToWorld
                        ? AppColors.warmOrangeDeep
                        : AppColors.warmGray300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: AppDurations.fast,
                    alignment: _shareToWorld
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warmGray900.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 话题选择
          if (_shareToWorld) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.warmGray100,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择话题',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray400,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _worldTopicOptions.map((topic) {
                      final isSelected = _worldTopic == topic;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _worldTopic = topic;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.warmOrange.withValues(alpha: 0.3)
                                : AppColors.warmGray50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.warmOrangeDeep.withValues(alpha: 0.3)
                                  : AppColors.warmGray100,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '#$topic',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected 
                                  ? AppColors.warmOrangeDark 
                                  : AppColors.warmGray500,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 选择照片（最多9张）
  Future<void> _pickImages() async {
    try {
      // 请求权限
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请允许访问相册以选择照片'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
          PhotoManager.openSetting();
        }
        return;
      }

      if (!mounted) return;

      // 计算还能选多少张
      final currentCount = _mediaType == MediaType.image ? _selectedMedia.length : 0;
      final remaining = 9 - currentCount;
      
      if (remaining <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('最多只能选择 9 张照片'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildAssetPickerConfig(remaining),
      );

      if (!mounted || assets == null || assets.isEmpty) {
        return;
      }

      final files = await Future.wait(assets.map((asset) => asset.file));
      final pickedFiles = files.whereType<File>().toList();

      if (pickedFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('读取照片失败'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      setState(() {
        if (_mediaType != MediaType.image) {
          // 切换类型时清空
          _selectedMedia.clear();
        }

        _selectedMedia.addAll(pickedFiles.map((file) => XFile(file.path)));
        _mediaType = MediaType.image;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择照片失败: $e'), backgroundColor: AppColors.warmGray800),
        );
      }
    }
  }

  /// 选择视频（最多1个，时长1分钟）
  Future<void> _pickVideo() async {
    try {
      // 请求权限
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请允许访问相册以选择视频'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
          PhotoManager.openSetting();
        }
        return;
      }

      if (!mounted) return;

      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: _buildAssetPickerConfig(
          1,
          requestType: RequestType.video,
        ),
      );

      if (!mounted || assets == null || assets.isEmpty) {
        return;
      }

      final asset = assets.first;
      if (asset.duration > 60) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('视频时长需在 1 分钟以内'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      final file = await asset.file;
      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('读取视频失败'),
              backgroundColor: AppColors.warmGray800,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(XFile(file.path));
        _mediaType = MediaType.video;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择视频失败: $e'), backgroundColor: AppColors.warmGray800),
        );
      }
    }
  }

  /// 选择音频（最多1个，时长30分钟）
  /// 注意：image_picker 不支持音频，这里暂时显示提示
  Future<void> _pickAudio() async {
    // TODO: 集成 file_picker 或其他音频选择库
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音频选择功能开发中，敬请期待'),
          backgroundColor: AppColors.warmGray800,
        ),
      );
    }
  }

  void _showExitDialog(BuildContext context) {
    if (_textController.text.isEmpty && _selectedMedia.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Text(
          '要把这一刻带走，还是留下来？',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warmGray500,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('带走'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmGray800,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
              elevation: 0,
            ),
            child: const Text('留下'),
          ),
        ],
      ),
    );
  }

  void _submitMoment(BuildContext context) {
    final circleInfo = ref.read(childInfoProvider);
    final currentUser = ref.read(currentUserSyncProvider);
    final mediaUrl = _selectedMedia.isNotEmpty ? _selectedMedia.first.path : null;

    final moment = Moment(
      id: const Uuid().v4(),
      author: currentUser,
      content: _textController.text,
      mediaType: _mediaType,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
      timeLabel: circleInfo.ageLabel,
      contextTags: [..._selectedMyMoods, ..._selectedAtmospheres],
      isSharedToWorld: _shareToWorld,
      worldTopic: _shareToWorld ? _worldTopic : null,
    );

    ref.read(momentsProvider.notifier).addMoment(moment);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.softGreen.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle5,
                size: 16,
                color: AppColors.softGreenDeep,
              ),
            ),
            const SizedBox(width: 12),
            const Text('这一刻，已经被你留住了。'),
          ],
        ),
        backgroundColor: AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );

    Navigator.of(context).pop();
  }
}

/// 微信朋友圈风格的图片网格组件
class _WechatStyleImageGrid extends StatelessWidget {
  final List<XFile> images;
  final double maxWidth;
  final Function(int) onRemove;

  const _WechatStyleImageGrid({
    required this.images,
    required this.maxWidth,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final count = images.length;
    if (count == 0) return const SizedBox.shrink();

    final spacing = 4.0;
    
    // 根据图片数量计算布局
    if (count == 1) {
      return _buildSingleImage(context);
    } else if (count == 2) {
      return _buildTwoImages(context, spacing);
    } else if (count == 3) {
      return _buildThreeImages(context, spacing);
    } else if (count == 4) {
      return _buildFourImages(context, spacing);
    } else {
      return _buildGridImages(context, spacing);
    }
  }

  /// 单张大图
  Widget _buildSingleImage(BuildContext context) {
    final size = maxWidth * 0.7;
    return _buildImageItem(context, 0, size, size);
  }

  /// 两张图并排
  Widget _buildTwoImages(BuildContext context, double spacing) {
    final itemSize = (maxWidth - spacing) / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImageItem(context, 0, itemSize, itemSize),
        SizedBox(width: spacing),
        _buildImageItem(context, 1, itemSize, itemSize),
      ],
    );
  }

  /// 三张图一行
  Widget _buildThreeImages(BuildContext context, double spacing) {
    final itemSize = (maxWidth - spacing * 2) / 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImageItem(context, 0, itemSize, itemSize),
        SizedBox(width: spacing),
        _buildImageItem(context, 1, itemSize, itemSize),
        SizedBox(width: spacing),
        _buildImageItem(context, 2, itemSize, itemSize),
      ],
    );
  }

  /// 四张图 2x2 网格
  Widget _buildFourImages(BuildContext context, double spacing) {
    final itemSize = (maxWidth - spacing) / 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageItem(context, 0, itemSize, itemSize),
            SizedBox(width: spacing),
            _buildImageItem(context, 1, itemSize, itemSize),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageItem(context, 2, itemSize, itemSize),
            SizedBox(width: spacing),
            _buildImageItem(context, 3, itemSize, itemSize),
          ],
        ),
      ],
    );
  }

  /// 5-9张图网格
  Widget _buildGridImages(BuildContext context, double spacing) {
    final itemSize = (maxWidth - spacing * 2) / 3;
    final rows = <Widget>[];
    
    for (var i = 0; i < images.length; i += 3) {
      final rowItems = <Widget>[];
      for (var j = i; j < i + 3 && j < images.length; j++) {
        if (rowItems.isNotEmpty) {
          rowItems.add(SizedBox(width: spacing));
        }
        rowItems.add(_buildImageItem(context, j, itemSize, itemSize));
      }
      
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: spacing));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: rowItems));
    }
    
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  /// 单个图片项（带删除按钮）
  Widget _buildImageItem(BuildContext context, int index, double width, double height) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            File(images[index].path),
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
        ),
        // 删除按钮
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.warmGray900.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 位置选择页面（微信风格）
class _LocationPickerPage extends StatefulWidget {
  const _LocationPickerPage();

  @override
  State<_LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<_LocationPickerPage> {
  final _searchController = TextEditingController();
  String? _selectedLocation;
  final bool _isLoading = false;
  
  // 模拟附近地点（实际应接入高德/百度地图 SDK）
  final List<_LocationItem> _nearbyLocations = [
    _LocationItem(name: '家', address: '100m内 | 北京市朝阳区建国路88号'),
    _LocationItem(name: '公司', address: '200m内 | 北京市朝阳区光华路9号'),
    _LocationItem(name: '朝阳公园', address: '500m内 | 北京市朝阳区朝阳公园南路1号'),
    _LocationItem(name: '国贸大厦', address: '800m内 | 北京市朝阳区建国门外大街1号'),
    _LocationItem(name: '三里屯太古里', address: '1.2km | 北京市朝阳区三里屯路19号'),
    _LocationItem(name: '望京SOHO', address: '3km | 北京市朝阳区望京街10号'),
    _LocationItem(name: '颐和园', address: '15km | 北京市海淀区新建宫门路19号'),
    _LocationItem(name: '故宫博物院', address: '8km | 北京市东城区景山前街4号'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const wechatGreen = Color(0xFF07C160);
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.warmGray800, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '所在位置',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.warmGray900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: AppColors.warmGray800, size: 22),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 不显示位置选项
          GestureDetector(
            onTap: () => Navigator.pop(context, ''),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.warmGray100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '不显示位置',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: wechatGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedLocation == null)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: wechatGreen, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: wechatGreen,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 附近地点列表
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: wechatGreen),
                  )
                : ListView.builder(
                    itemCount: _nearbyLocations.length,
                    itemBuilder: (context, index) {
                      final location = _nearbyLocations[index];
                      final isSelected = _selectedLocation == location.name;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedLocation = location.name);
                          Navigator.pop(context, location.name);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.warmGray50, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.name,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.warmGray900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      location.address,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.warmGray400,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: wechatGreen, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 位置项数据类
class _LocationItem {
  final String name;
  final String address;

  const _LocationItem({required this.name, required this.address});
}
