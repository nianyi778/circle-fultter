# 修复 CreateMomentModal 布局问题

## 问题描述
点击 + 号弹出创建页时，显示大片红色区域（Flutter 渲染错误）。

## 问题原因
`CreateMomentModal` 的 `build` 方法返回裸 `Stack`，没有 `Scaffold` 包装，且通过 `opaque: false` 的路由推入，导致：
1. 布局上下文不完整
2. 底层页面透出
3. 渲染计算错误

## 修复方案
**方案 B**: 底部弹出 + 半透明遮罩

## 修改文件
`lib/features/create/views/create_moment_view.dart`

## 具体修改

### 定位代码（约第 1345-1400 行）

**将：**
```dart
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
```

**改为：**
```dart
@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
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
```

## 关键改动

| 改动点 | 说明 |
|--------|------|
| 添加 `Scaffold` 包装 | 提供正确的布局上下文 |
| `backgroundColor: Colors.black.withValues(alpha: 0.5)` | 半透明黑色遮罩 |
| 添加 `GestureDetector` | 点击遮罩区域弹出退出确认 |
| 使用 `Align(alignment: Alignment.bottomCenter)` | 确保卡片从底部弹出 |
| 高度改为 `0.92` | 稍微增加，留出顶部状态栏空间 |
| 动画放在 `Container` 上 | 只有卡片有滑入动画，遮罩直接显示 |
| `slideY begin: 0.3` | 从更远处滑入，效果更明显 |

## 验证步骤
1. 运行 `flutter analyze` 确保无错误
2. 运行 `flutter run` 测试
3. 点击 + 号，确认：
   - 显示半透明黑色遮罩
   - 白色卡片从底部滑入
   - 点击遮罩区域弹出退出确认
   - 无红色错误区域
