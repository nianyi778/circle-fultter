import 'dart:io';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/api_config.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';
import '../../../shared/widgets/app_snackbar.dart';

AssetPickerConfig _buildAssetPickerConfig(
  int maxAssets, {
  RequestType requestType = RequestType.image,
}) {
  return AssetPickerConfig(
    maxAssets: maxAssets,
    requestType: requestType,
    themeColor: AppColors.softGreenDeep,
    gridCount: 3,
    pageSize: 60,
  );
}

/// 创建时刻浮层 Modal - 仿 Web 版效果
class CreateMomentModal extends ConsumerStatefulWidget {
  final String? hint;

  const CreateMomentModal({super.key, this.hint});

  @override
  ConsumerState<CreateMomentModal> createState() => _CreateMomentModalState();
}

class _CreateMomentModalState extends ConsumerState<CreateMomentModal> {
  final _textController = TextEditingController();

  final Set<ContextTag> _selectedMyMoods = {};
  final Set<ContextTag> _selectedAtmospheres = {};

  // 可折叠区域状态
  bool _isMoodExpanded = false;
  bool _isAtmosphereExpanded = false;

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

  @override
  void initState() {
    super.initState();
    // 如果有 hint，预填充到输入框
    if (widget.hint != null) {
      _textController.text = widget.hint!;
    }
  }

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

  bool get _hasContent =>
      _textController.text.isNotEmpty || _selectedMedia.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false, // 键盘覆盖底部内容，不顶起页面
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Stack(
        children: [
          // 点击遮罩区域关闭
          GestureDetector(
            onTap: () => _showExitDialog(context),
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),

          // 底部弹出的白色卡片
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.92,
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
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        // 底部预留键盘高度，确保内容可滚动到可见区域
                        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                      ),
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
            ).animate().slideY(
              begin: 0.3,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
          ),

          // 拖拽删除区域（底部）
          if (_isDragging) _buildDeleteZone(context),
        ],
      ),
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
                  color:
                      _isOverDeleteZone
                          ? const Color(0xFFE53935) // 红色高亮
                          : const Color(0xFFEF5350).withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
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
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 1, end: 0, duration: 200.ms);
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
            child: Icon(Icons.close, color: AppColors.warmGray400, size: 24),
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
                color:
                    _hasContent ? AppColors.warmGray800 : AppColors.warmGray200,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmGray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warmGray200, width: 1),
      ),
      child: TextField(
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
            color: AppColors.warmGray400,
            height: 1.6,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          isDense: true,
        ),
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
            color: AppColors.warmGray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warmGray300, width: 0.8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.warmGray500, size: 36),
              const SizedBox(height: 4),
              Text(
                '添加',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warmGray500,
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
    final totalItems =
        canAddMore ? _selectedMedia.length + 1 : _selectedMedia.length;
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
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.warmGray500,
                  ),
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
          color: AppColors.warmGray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warmGray300, width: 0.8),
        ),
        child: const Icon(Icons.add, color: AppColors.warmGray500, size: 32),
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
                    child: Icon(
                      Iconsax.video,
                      color: AppColors.white,
                      size: 40,
                    ),
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
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
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
      builder:
          (ctx) => Container(
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
        Divider(height: 1, color: AppColors.warmGray200.withValues(alpha: 0.8)),
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
                  color: hasLocation ? wechatGreen : AppColors.warmGray500,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locationName ?? '所在位置',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasLocation ? wechatGreen : AppColors.warmGray500,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.warmGray300,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: AppColors.warmGray200.withValues(alpha: 0.8)),
      ],
    );
  }

  /// 选择位置 - 全屏页面（微信风格）
  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (context) => const _LocationPickerPage()),
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
        // 我的心情 - 可折叠
        _buildCollapsibleTagSection(
          context: context,
          label: '我的心情',
          isExpanded: _isMoodExpanded,
          selectedTags: _selectedMyMoods,
          allTags: _myMoodOptions,
          onToggle: () => setState(() => _isMoodExpanded = !_isMoodExpanded),
          onTagTap: (tag) {
            setState(() {
              if (_selectedMyMoods.contains(tag)) {
                _selectedMyMoods.remove(tag);
              } else {
                _selectedMyMoods.add(tag);
              }
            });
          },
        ),

        const SizedBox(height: 16),

        // 当时的氛围 - 可折叠
        _buildCollapsibleTagSection(
          context: context,
          label: '当时的氛围',
          isExpanded: _isAtmosphereExpanded,
          selectedTags: _selectedAtmospheres,
          allTags: _atmosphereOptions,
          onToggle:
              () => setState(
                () => _isAtmosphereExpanded = !_isAtmosphereExpanded,
              ),
          onTagTap: (tag) {
            setState(() {
              if (_selectedAtmospheres.contains(tag)) {
                _selectedAtmospheres.remove(tag);
              } else {
                _selectedAtmospheres.add(tag);
              }
            });
          },
        ),
      ],
    );
  }

  /// 可折叠的标签区域
  Widget _buildCollapsibleTagSection({
    required BuildContext context,
    required String label,
    required bool isExpanded,
    required Set<ContextTag> selectedTags,
    required List<ContextTag> allTags,
    required VoidCallback onToggle,
    required Function(ContextTag) onTagTap,
  }) {
    final hasSelection = selectedTags.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color:
            isExpanded
                ? AppColors.warmGray100.withValues(alpha: 0.6)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.warmGray200 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行 - 可点击展开/折叠
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 12 : 0,
                vertical: isExpanded ? 12 : 4,
              ),
              child: Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 已选标签摘要（折叠时显示）
                  if (!isExpanded && hasSelection)
                    Expanded(
                      child: Text(
                        selectedTags
                            .map((t) => '${t.emoji}${t.label}')
                            .join(' '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warmGray600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (!isExpanded && !hasSelection) const Spacer(),
                  // 展开/折叠图标
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppDurations.fast,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.warmGray500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 标签列表（展开时显示）
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    allTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return _ContextChip(
                        tag: tag,
                        isSelected: isSelected,
                        onTap: () => onTagTap(tag),
                      );
                    }).toList(),
              ),
            ),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: AppDurations.fast,
            sizeCurve: AppCurves.gentle,
          ),
        ],
      ),
    );
  }

  Widget _buildFutureMessageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            _shareToWorld
                ? AppColors.warmOrange.withValues(alpha: 0.15)
                : AppColors.warmGray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _shareToWorld
                  ? AppColors.warmOrangeDeep.withValues(alpha: 0.25)
                  : AppColors.warmGray300.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGray900.withValues(alpha: 0.05),
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
                    color:
                        _shareToWorld
                            ? AppColors.warmOrangeDeep
                            : AppColors.warmGray600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '发布到世界',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          _shareToWorld
                              ? AppColors.warmGray800
                              : AppColors.warmGray700,
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
                    color:
                        _shareToWorld
                            ? AppColors.warmOrangeDeep
                            : AppColors.warmGray400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: AppDurations.fast,
                    alignment:
                        _shareToWorld
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
                  top: BorderSide(color: AppColors.warmGray200, width: 1),
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
                    children:
                        _worldTopicOptions.map((topic) {
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
                                color:
                                    isSelected
                                        ? AppColors.warmOrange.withValues(
                                          alpha: 0.3,
                                        )
                                        : AppColors.warmGray100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.warmOrangeDeep.withValues(
                                            alpha: 0.3,
                                          )
                                          : AppColors.warmGray300,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#$topic',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color:
                                      isSelected
                                          ? AppColors.warmOrangeDark
                                          : AppColors.warmGray700,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
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
      final currentCount =
          _mediaType == MediaType.image ? _selectedMedia.length : 0;
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

  void _showExitDialog(BuildContext context) {
    if (_textController.text.isEmpty && _selectedMedia.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warmGray500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('带走'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmGray800,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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

  void _submitMoment(BuildContext context) {
    final circleInfo = ref.read(childInfoProvider);
    final currentUser = ref.read(currentUserSyncProvider);

    _submitMomentWithUploads(context, circleInfo, currentUser);
  }

  Future<void> _submitMomentWithUploads(
    BuildContext context,
    CircleInfo circleInfo,
    User currentUser,
  ) async {
    try {
      final mediaUrls = await _uploadSelectedMedia(context, circleInfo);
      final now = DateTime.now();
      final moment = Moment(
        id: const Uuid().v4(),
        circleId: circleInfo.id,
        author: currentUser,
        content: _textController.text,
        mediaType: _mediaType,
        mediaUrls: mediaUrls,
        timestamp: now,
        contextTags: [..._selectedMyMoods, ..._selectedAtmospheres],
        isSharedToWorld: _shareToWorld,
        worldTopic: _shareToWorld ? _worldTopic : null,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(momentsProvider.notifier).addMoment(moment);

      if (context.mounted) {
        AppSnackBar.showMomentSaved(context);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发布失败：$e'),
            backgroundColor: AppColors.warmGray800,
          ),
        );
      }
    }
  }

  Future<List<String>> _uploadSelectedMedia(
    BuildContext context,
    CircleInfo circleInfo,
  ) async {
    if (_mediaType != MediaType.image || _selectedMedia.isEmpty) {
      return _selectedMedia.map((file) => file.path).toList();
    }

    final api = ApiService.instance;
    final uploadedUrls = <String>[];

    for (final file in _selectedMedia) {
      final localFile = File(file.path);
      if (!await localFile.exists()) {
        throw Exception('读取图片失败');
      }
      final bytes = await localFile.readAsBytes();
      final filename = path.basename(localFile.path);

      final uploadResponse = await api.post<Map<String, dynamic>>(
        ApiConfig.mediaUploadUrl,
        data: {
          'filename': filename,
          'contentType': 'image/jpeg',
          'size': bytes.length,
          'circleId': circleInfo.id,
        },
        fromData: (data) => data as Map<String, dynamic>,
      );

      if (!uploadResponse.success || uploadResponse.data == null) {
        throw Exception(uploadResponse.error?.message ?? '获取上传地址失败');
      }

      final uploadUrl = uploadResponse.data!['uploadUrl'] as String;
      final key = uploadResponse.data!['key'] as String;

      await api.uploadFile(
        '${ApiConfig.baseUrl}$uploadUrl',
        bytes,
        contentType: 'image/jpeg',
      );

      final completeResponse = await api.post<Map<String, dynamic>>(
        ApiConfig.mediaComplete,
        data: {'key': key},
        fromData: (data) => data as Map<String, dynamic>,
      );

      if (!completeResponse.success || completeResponse.data == null) {
        throw Exception(completeResponse.error?.message ?? '确认上传失败');
      }

      final mediaUrl = completeResponse.data!['url'] as String;
      uploadedUrls.add('${ApiConfig.baseUrl}$mediaUrl');
    }

    return uploadedUrls;
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.warmGray800,
            size: 20,
          ),
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
            icon: const Icon(
              Iconsax.search_normal,
              color: AppColors.warmGray800,
              size: 22,
            ),
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
            child:
                _isLoading
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.warmGray50,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.warmGray900,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        location.address,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
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
                                  const Icon(
                                    Icons.check,
                                    color: wechatGreen,
                                    size: 20,
                                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.warmGray800.withValues(alpha: 0.12)
                  : AppColors.warmGray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.warmGray500 : AppColors.warmGray300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              tag.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isSelected ? AppColors.warmGray800 : AppColors.warmGray700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
