# TimeCircle - AI Coding Instructions

## 🚨 核心原则：先沟通，再动手

> **任何操作前，必须先与用户确认方案，获得明确同意后才能执行代码修改。**

---

## 🚨 开发工作流程（必须遵守）

### 阶段 0：沟通确认（每次任务必经）
- **收到任何需求后，先理解、再提问、最后确认**
- 输出以下内容供用户确认：
  1. 📋 **我的理解**：用自己的话复述需求
  2. ❓ **待确认问题**：列出不清楚的点
  3. 📐 **初步方案**：简述技术思路（不超过 3 句话）
  4. ⚠️ **影响范围**：会改动哪些文件/模块
- **⛔ 禁止在用户确认前执行任何代码修改**
- 用户回复「可以」「OK」「开始吧」等明确同意后，才进入下一阶段

### 阶段 1：需求文档
- 确认完毕后，将需求文档写入 `prd/YYYY_MM_DD_功能ID_需求名.md`
- 需求不清楚的地方，必须标注 `[待确认]`

### 阶段 2：技术方案
- 技术实现方案写入 `docs/YYYY_MM_DD_功能ID_技术方案.md`
- 方案需包含：
  - 需求背景
  - 技术方案（含代码结构说明）
  - 影响范围（改动文件列表）
  - **测试用例**（必须详细，供用户手动验收）
- **复杂改动需再次与用户确认方案**

### 阶段 3：代码实现
- 架构遵循最佳实践，注重性能
- **禁止引入 bug**，代码必须完美
- 涉及以下变更时，必须同步更新 `codebase/xxx.md`：
  - 架构变化
  - 目录结构变动
  - 公共组件/函数新增或修改

### 阶段 4：验证阶段
- 代码写完后 **必须运行 `flutter analyze`** 确保无错误
- 尝试编译确保无运行时问题
- 完善测试用例

### 阶段 5：验收阶段
- 将测试用例提供给用户
- 用户手动测试
- **必须等待用户明确回复「验收通过」才算完成**
- 验收通过后，更新相关文档闭环

### ⚠️ 禁止行为清单
- ❌ 收到需求后直接开始写代码
- ❌ 假设用户意图，不确认就执行
- ❌ 大规模改动前不说明影响范围
- ❌ 跳过沟通阶段直接进入实现

### 📁 文档命名规范（三文档关联）

使用 **统一功能 ID** 关联三类文档：

| 目录 | 命名格式 | 示例 |
|------|----------|------|
| `prd/` | `YYYY_MM_DD_功能ID_需求名.md` | `2026_01_21_letter_edit_信件编辑页.md` |
| `docs/` | `YYYY_MM_DD_功能ID_技术方案.md` | `2026_01_21_letter_edit_技术方案.md` |
| `codebase/` | `功能ID_模块说明.md` | `letter_edit_公共组件.md` |

**功能 ID 命名规则**：
- 使用小写英文 + 下划线
- 简短易识别（如 `letter_edit`, `moment_detail`, `home_memory`）
- 同一功能的三个文档使用 **相同的功能 ID**

**文档头部关联声明**（每个文档开头添加）：
```markdown
---
功能ID: letter_edit
需求文档: prd/2026_01_21_letter_edit_信件编辑页.md
技术方案: docs/2026_01_21_letter_edit_技术方案.md
代码文档: codebase/letter_edit_公共组件.md
---
```

**目录结构**：
```
prd/              # 需求文档（产品视角）
docs/             # 技术方案 + 设计规范（开发视角）
codebase/         # 架构/公共组件/函数文档（代码视角，持续更新）
```

---

## 项目概述

TimeCircle（家庭回忆时间胶囊）是一个 Flutter 应用，用于记录家庭成长回忆。这是一个 **情感体验产品**，不是效率工具。

设计规范详见 [docs/time_circle_设计规范_home_首页设计（设计基准稿）.md](../docs/time_circle_设计规范_home_首页设计（设计基准稿）.md)
web版本代码详见 [Circle](../Circle)

## 架构模式

```
lib/
├── core/              # 核心层：theme, models, providers, router
├── features/          # 功能模块：home, timeline, letters, world, create, settings
│   └── {feature}/
│       ├── views/     # 页面视图
│       └── widgets/   # 功能私有组件
├── shared/widgets/    # 跨功能共享组件
└── main.dart
```

### 关键架构决策

1. **状态管理**: `flutter_riverpod` - 所有 Provider 定义在 `lib/core/providers/app_providers.dart`
2. **路由**: `go_router` + `ShellRoute` - 主 Tab 页面共享 `MainScaffold`，详情页独立无底部导航
3. **组件复用**: 详情页共享组件位于 `lib/shared/widgets/`（MediaViewer, DetailActionBar, ContextTagsView 等）

## 设计系统（必读）

### 色彩（AppColors）
```dart
timeBeige: #FAF9F7      // 全局背景（像旧纸张）
warmGray900-100         // 文字灰度系列
calmBlue, warmPeach, softGreen, mutedViolet  // 情绪辅助色（低饱和，仅点缀）
```

### 动效（AppDurations）
```dart
fast: 150ms      // 快速交互
normal: 250ms    // 标准动画
slow: 400ms      // 缓慢出现
ceremony: 600ms  // 仪式动画（如封存）
```

**严禁**: 弹跳、抖动、强反馈动画。永远 **慢一点、轻一点、不打断情绪**。

### 反设计清单（严禁）
- ❌ 高饱和色 / 强对比
- ❌ 工具感 UI（表格 / 强边框）
- ❌ 信息密度过高
- ❌ 红点轰炸

## 代码约定

### 动画使用
```dart
// ✅ 正确: 在普通 Widget 上使用 flutter_animate
Widget().animate().fadeIn(duration: 400.ms)

// ❌ 错误: 在 Sliver 上直接调用 animate()
SliverToBoxAdapter(...).animate()  // 会报错

// ✅ Sliver 中的动画应用在 child 上
SliverToBoxAdapter(
  child: Widget().animate().fadeIn(),
)
```

### Provider 命名
```dart
// 简单状态
final xxxProvider = Provider<Type>((ref) => ...);
// 可变状态
final xxxProvider = StateNotifierProvider<XxxNotifier, Type>((ref) => ...);
// 按 ID 查询
final xxxByIdProvider = Provider.family<Type?, String>((ref, id) => ...);
```

### 路由跳转
```dart
context.push('/moment/${moment.id}');  // 详情页
context.go('/timeline');                // Tab 页切换
```

## 常用命令

```bash
cd time_circle_flutter
flutter analyze         # 代码检查（每次必须运行）
flutter test            # 运行测试
flutter run -d emulator-5554  # 运行到 Android 模拟器
flutter run -d macos    # macOS 桌面（需先配置网络权限）
```

### 代码质量检查清单
- [ ] `flutter analyze` 无错误、无警告
- [ ] 编译通过，无运行时异常
- [ ] 新增代码有对应测试用例
- [ ] 公共组件/函数已更新 `codebase/` 文档
- [ ] 技术方案已写入 `docs/YYYY_MM_DD_xxx.md`

### macOS 网络权限
如需在 macOS 上加载网络图片/字体，确保 `macos/Runner/DebugProfile.entitlements` 包含：
```xml
<key>com.apple.security.network.client</key>
<true/>
```

## 模型结构

| 模型 | 用途 | 关键字段 |
|------|------|----------|
| `Moment` | 时刻/记录 | mediaType, contextTags, futureMessage |
| `Letter` | 年度信/随记 | status (draft/sealed/opened), type |
| `User` | 用户 | role (dad/mom/grandpa/grandma) |
| `ContextTag` | 语境标签 | type (parentMood/childState), emoji |

## 共享组件（优先复用）

- `MediaViewer`: 图片/视频/音频统一展示
- `ContextTagsView`: 语境标签展示
- `FutureMessageCard`: "对未来说一句"卡片
- `DetailActionBar`: 底部操作栏（共鸣/收藏/更多）
- `DetailAppBar`: 详情页统一导航栏
