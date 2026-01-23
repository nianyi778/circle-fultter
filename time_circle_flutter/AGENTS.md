# AGENTS.md - TimeCircle Flutter 项目指南

本文件为 AI 编程代理提供项目规范和开发指南。

## 项目概述

TimeCircle（时间圈）是一个私密回忆时间胶囊应用，使用 Flutter 开发。
设计哲学：温柔、安静、克制 —— 这是一个"时间容器"，不是效率工具。

## 构建与运行命令

### 基础命令

```bash
# 获取依赖
flutter pub get

# 运行应用（调试模式）
flutter run

# 运行应用（指定设备）
flutter run -d <device_id>

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios

# 清理构建缓存
flutter clean && flutter pub get
```

### 代码分析与格式化

```bash
# 静态分析（检查代码问题）
flutter analyze

# 格式化代码
dart format lib/

# 格式化并检查（不修改）
dart format --set-exit-if-changed lib/
```

### 测试命令

```bash
# 运行所有测试
flutter test

# 运行单个测试文件
flutter test test/widget_test.dart

# 运行匹配名称的测试
flutter test --name "smoke test"

# 运行测试并生成覆盖率报告
flutter test --coverage
```

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心模块
│   ├── models/                  # 数据模型
│   ├── providers/               # Riverpod 状态管理
│   ├── router/                  # GoRouter 路由配置
│   ├── services/                # 服务层（数据库等）
│   └── theme/                   # 主题与设计系统
├── features/                    # 功能模块
│   ├── home/                    # 首页
│   ├── timeline/                # 时间轴
│   ├── letters/                 # 信件
│   ├── world/                   # 世界频道
│   ├── create/                  # 创建内容
│   └── settings/                # 设置
└── shared/                      # 共享组件
    └── widgets/                 # 通用 Widget
```

## 代码风格指南

### 导入规范

按以下顺序组织导入，各组之间空一行：

```dart
// 1. Dart SDK
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 第三方包
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. 项目内部导入（使用相对路径）
import '../../core/models/models.dart';
import '../widgets/feed_card.dart';
```

### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | UpperCamelCase | `MomentDetailView` |
| 文件名 | snake_case | `moment_detail_view.dart` |
| 变量/函数 | lowerCamelCase | `getMoments()` |
| 常量 | lowerCamelCase | `static const double cardPadding = 20.0;` |
| 私有成员 | 前缀下划线 | `_database`, `_initDatabase()` |
| Provider | lowerCamelCase + Provider 后缀 | `appRouterProvider` |

### Widget 编写规范

```dart
/// 使用文档注释说明 Widget 用途
class MomentCard extends StatelessWidget {
  // 构造函数使用 const
  const MomentCard({
    super.key,
    required this.moment,
    this.onTap,
  });

  // 属性声明在前
  final Moment moment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // build 方法实现
  }
}
```

### Riverpod 状态管理

```dart
// 使用 Provider 声明
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(...);
});

// 使用 ConsumerWidget 消费状态
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // ...
  }
}
```

### 类型注解

- 始终为公共 API 添加类型注解
- 局部变量可使用 `var` 或 `final`，但类型明确时建议显式声明
- 避免使用 `dynamic`，除非确实需要

```dart
// Good
final List<Moment> moments = [];
Future<User> getCurrentUser() async { ... }

// Avoid
var moments = [];
dynamic getCurrentUser() { ... }
```

## 设计系统

项目使用自定义设计系统，位于 `lib/core/theme/app_theme.dart`：

### 颜色

```dart
AppColors.timeBeige      // 背景主色（时间米白）
AppColors.warmGray800    // 主文字色
AppColors.warmGray600    // 辅助文字色
AppColors.calmBlue       // 平静/回忆
AppColors.warmPeach      // 温暖/成长
```

### 间距

```dart
AppSpacing.sm            // 8.0
AppSpacing.md            // 12.0
AppSpacing.lg            // 16.0
AppSpacing.pagePadding   // 20.0
AppSpacing.sectionGap    // 24.0
```

### 圆角

```dart
AppRadius.sm             // 12.0
AppRadius.md             // 16.0
AppRadius.card           // 20.0
AppRadius.button         // 24.0
```

### 动效

```dart
AppDurations.fast        // 150ms - 快速交互
AppDurations.normal      // 250ms - 标准动画
AppDurations.slow        // 400ms - 缓慢出现
AppCurves.standard       // Curves.easeOutCubic
```

## 数据库操作

使用 `DatabaseService` 单例进行数据库操作：

```dart
final db = DatabaseService();

// 获取数据
final moments = await db.getMoments();
final user = await db.getCurrentUser();

// 插入/更新
await db.insertMoment(moment);
await db.updateMoment(moment);

// 删除
await db.deleteMoment(id);
```

## 错误处理

```dart
// 使用 try-catch 处理异步错误
Future<void> saveMoment(Moment moment) async {
  try {
    await DatabaseService().insertMoment(moment);
  } catch (e) {
    // 记录错误，显示用户友好提示
    debugPrint('保存失败: $e');
    // 可使用 SnackBar 或 Dialog 通知用户
  }
}
```

## 注释规范

```dart
/// 使用三斜线文档注释描述类和公共方法
/// 
/// 可以包含多行说明和示例
class Moment {
  /// 相对时间显示（如"3 分钟前"）
  String get relativeTime { ... }
}

// 使用双斜线注释说明实现细节
// 版本 2 -> 3: 添加 comments 表缺失字段
```

## 中文支持

- 项目面向中文用户，UI 文本使用中文
- 代码注释可使用中文说明业务逻辑
- 变量名和函数名使用英文

## 常用依赖

| 包名 | 用途 |
|------|------|
| flutter_riverpod | 状态管理 |
| go_router | 路由导航 |
| sqflite | SQLite 数据库 |
| cached_network_image | 图片缓存 |
| google_fonts | 字体（Noto Sans/Serif SC） |
| flutter_animate | 动画效果 |
| image_picker | 图片选择 |
| iconsax | 图标库 |
