---
功能ID: asset_picker
需求文档: prd/2026_01_22_asset_picker_选图上限与样式.md
技术方案: docs/2026_01_22_asset_picker_技术方案.md
代码文档: codebase/asset_picker_公共组件.md
---

# 选图上限与样式 - 技术方案

## 需求背景
系统相册选择器无法在选择阶段强制限制图片数量，体验不符合微信式选择逻辑。

## 技术方案
- 引入 `wechat_assets_picker` 替换图片选择入口。
- 通过 `maxAssets` 强制限制 9 张。
- 统一图片/视频入口为“相册”按钮，按当前已选类型进入对应选择器；未选择时弹出类型选择。
- 主题色调整为 TimeCircle 低饱和色系（主色取 `AppColors.softGreenDeep`）。
- 视频选择改为 `AssetPicker`，保持 1 个 + 时长 1 分钟限制。

## 代码结构说明
- `CreateMomentView` 与 `CreateMomentModal` 的 `_pickImages()` 改为调用 `AssetPicker.pickAssets`。
- `_pickVideo()` 改为使用 `AssetPicker` 并在选取后校验时长 <= 1 分钟。
- 新增统一的 `AssetPickerConfig` 构建方法，避免配置分散。

## 影响范围
- pubspec 依赖：新增 `wechat_assets_picker`。
- 权限配置：Android Manifest + iOS Info.plist 增加相册权限说明。
- 代码文件：
  - lib/features/create/views/create_moment_view.dart
  - android/app/src/main/AndroidManifest.xml
  - ios/Runner/Info.plist
  - pubspec.yaml

## 测试用例
1. **选择阶段硬限制**
   - 打开选择器，勾选 9 张后继续点击其他图片，应无法继续勾选。
2. **确认回传数量**
   - 选择 9 张并确认，预览区显示 9 张。
3. **不足上限**
   - 选择 3 张并确认，预览区显示 3 张，且仍有“+”按钮。
4. **视频不受影响**
   - 视频选择仍可打开系统选择器，并限制为 1 个、时长不超过 1 分钟。
5. **权限提示**
   - 首次打开选择器时，系统弹出相册权限请求。
