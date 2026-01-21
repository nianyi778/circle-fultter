# 发布页组件文档

## 概述

发布页用于创建新的「时刻」记录，支持文字、图片、视频等多种媒体类型。

**文件位置**：`lib/features/create/views/create_moment_view.dart`

## 组件结构

### 主要组件

| 组件 | 类型 | 说明 |
|------|------|------|
| `CreateMomentView` | 全屏页面 | 独立页面形式的发布页 |
| `CreateMomentModal` | 底部弹窗 | 从底部滑出的发布页（当前主入口） |
| `_LocationPickerPage` | 全屏页面 | 位置选择器（微信风格） |
| `_ContextChip` | 小组件 | 语境标签选择芯片 |
| `_MediaButton` | 小组件 | 媒体类型选择按钮 |

### 状态管理

```dart
// 文本控制器
final _textController = TextEditingController();
final _futureMessageController = TextEditingController();

// 媒体状态
final List<XFile> _selectedMedia = [];
MediaType _mediaType = MediaType.text;

// 拖拽状态
bool _isDragging = false;
bool _isOverDeleteZone = false;

// 语境标签
final Set<ContextTag> _selectedParentMoods = {};
final Set<ContextTag> _selectedChildStates = {};

// 位置
String? _locationName;

// 对未来说一句
bool _showFutureMessage = true;
```

## 核心方法

### 媒体选择

#### `_buildAssetPickerConfig(int maxAssets, {RequestType requestType})`
顶层函数，构建统一的 AssetPicker 配置。

```dart
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
```

#### `_onAlbumPressed()`
统一的相册入口逻辑：
- 已有图片 → 继续选图
- 已有视频 → 继续选视频
- 无媒体 → 弹出类型选择器

#### `_showMediaTypePicker()`
底部弹窗，让用户选择照片/视频/音频类型。

#### `_pickImages()`
选择照片，核心流程：
1. 请求相册权限 (`PhotoManager.requestPermissionExtend()`)
2. 权限拒绝 → 提示并跳转设置
3. 计算剩余可选数量 (9 - 已选)
4. 调用 `AssetPicker.pickAssets()` 打开选择器
5. 转换 Asset → XFile 并更新状态

#### `_pickVideo()`
选择视频，核心流程：
1. 请求相册权限
2. 调用 `AssetPicker.pickAssets(requestType: RequestType.video)`
3. 校验时长 <= 60 秒
4. 更新状态

### 媒体展示

#### `_buildWechatStyleMedia(BuildContext context)`
微信风格的媒体网格：
- 3 列布局，间距 4px
- 图片数量 < 9 时显示 + 按钮
- 支持 LongPressDraggable 拖拽删除

#### `_buildDeleteZone(BuildContext context)`
底部删除区域：
- 拖拽时从底部滑入
- 悬停时变红并放大
- 释放时删除对应媒体

### 表单区域

#### `_buildTextInput(BuildContext context)`
文本输入框，样式：
- 字号 14px，行高 1.6
- 透明背景，无边框
- placeholder: "这一刻，你想留下些什么？"

#### `_buildContextSection(BuildContext context)`
语境标签选择区域：
- "当时的我"：父母情绪选项
- "当时的你"：孩子状态选项

#### `_buildFutureMessageSection(BuildContext context)`
"对未来说一句"卡片：
- 暖橙色背景
- 可折叠开关
- 最多 40 字

#### `_buildBottomOptions(BuildContext context)`
底部选项区域：
- 位置选择（微信风格）

## 样式规范

### 颜色

| 用途 | 颜色 |
|------|------|
| 输入框文字 | `warmGray700` |
| 占位符 | `warmGray300` |
| 边框 | `warmGray100` 0.5px |
| 标签文字 | `warmGray300` |
| 添加按钮图标 | `warmGray300` |
| 分割线 | `warmGray100` 50% alpha |

### 字号

| 元素 | 字号 |
|------|------|
| 输入框 | 14px |
| 标签标题 | 10px |
| 位置文字 | 13px |
| 添加按钮文字 | 11px |

### 间距

| 区域 | padding |
|------|---------|
| 滚动区域 | horizontal: 20, vertical: 16 |
| 对未来说一句卡片 | 14px |
| 位置选项 | vertical: 14 |

## 依赖

```yaml
dependencies:
  wechat_assets_picker: ^10.1.0  # 相册选择器
  photo_manager: ^3.8.3          # 权限管理（通过 wechat_assets_picker 间接依赖）
  image_picker: ^1.1.2           # XFile 类型
  iconsax: ^0.0.9                # 图标
```

## 权限配置

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

### iOS (`Info.plist`)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>用于选择家庭回忆中的照片与视频</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>用于保存回忆内容到相册</string>
```

## 更新日志

| 日期 | 变更 |
|------|------|
| 2026-01-22 | 引入 wechat_assets_picker，添加权限检查 |
| 2026-01-22 | 统一相册入口，添加类型选择器 |
| 2026-01-22 | 优化样式：字号 14px，边框更淡 |
