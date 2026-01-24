// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// 念念 App 图标生成脚本
///
/// 运行方式：
/// ```bash
/// cd time_circle_flutter
/// dart run tool/generate_icon.dart
/// ```
///
/// 生成文件：
/// - assets/images/app_icon.png (1024x1024)
/// - assets/images/app_icon_foreground.png (432x432, 透明背景)

void main() {
  print('开始生成念念 App 图标...\n');

  // 生成主图标 (1024x1024，米白背景)
  generateMainIcon();

  // 生成 Android 自适应图标前景 (432x432，透明背景)
  generateAdaptiveIconForeground();

  print('\n图标生成完成！');
  print('接下来运行: dart run flutter_launcher_icons');
}

/// 颜色定义
const int warmOrange = 0xFFE8A87C; // 暖橙色
const int warmBeige = 0xFFFAF8F5; // 米白色

/// 生成主图标
void generateMainIcon() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // 填充米白背景
  img.fill(image, color: img.ColorRgba8(0xFA, 0xF8, 0xF5, 0xFF));

  // 绘制 Logo
  drawLogo(image, size, size, scale: 1.0);

  // 保存 PNG
  final pngBytes = img.encodePng(image);
  File('assets/images/app_icon.png').writeAsBytesSync(pngBytes);
  print('✓ 已生成: assets/images/app_icon.png (${size}x$size)');
}

/// 生成 Android 自适应图标前景
void generateAdaptiveIconForeground() {
  const size = 432;
  final image = img.Image(width: size, height: size);

  // 透明背景
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  // 绘制 Logo（缩放到安全区）
  drawLogo(image, size, size, scale: 0.6);

  // 保存 PNG
  final pngBytes = img.encodePng(image);
  File('assets/images/app_icon_foreground.png').writeAsBytesSync(pngBytes);
  print('✓ 已生成: assets/images/app_icon_foreground.png (${size}x$size)');
}

/// 绘制念念 Logo（心+今组合）
void drawLogo(img.Image image, int width, int height, {double scale = 1.0}) {
  final color = img.ColorRgba8(0xE8, 0xA8, 0x7C, 0xFF); // 暖橙色

  final centerX = width / 2;
  final centerY = height / 2;

  // 根据 scale 调整尺寸
  final logoHeight = height * 0.6 * scale;
  final logoWidth = width * 0.5 * scale;

  // Logo 整体偏上一点
  final offsetY = -height * 0.02;

  // ========== 心形 ==========
  final heartHeight = logoHeight * 0.55;
  final heartWidth = logoWidth * 1.0;
  final heartCenterY = centerY - logoHeight * 0.2 + offsetY;

  drawHeart(
    image,
    centerX: centerX,
    centerY: heartCenterY,
    heartWidth: heartWidth,
    heartHeight: heartHeight,
    color: color,
  );

  // ========== 今字（抽象版）==========
  final heartBottom = heartCenterY + heartHeight * 0.45;
  final jinTop = heartBottom + logoHeight * 0.03;
  final jinHeight = logoHeight * 0.42;
  final jinWidth = logoWidth * 0.6;
  final strokeWidth = (logoWidth * 0.05).round();

  // 横线
  drawRoundedRect(
    image,
    centerX: centerX,
    centerY: jinTop + strokeWidth / 2,
    rectWidth: jinWidth,
    rectHeight: strokeWidth.toDouble(),
    color: color,
  );

  // 竖线
  drawRoundedRect(
    image,
    centerX: centerX,
    centerY: jinTop + jinHeight * 0.5,
    rectWidth: strokeWidth.toDouble(),
    rectHeight: jinHeight * 0.85,
    color: color,
  );

  // 左撇
  drawRotatedRect(
    image,
    centerX: centerX - jinWidth * 0.18,
    centerY: jinTop + jinHeight * 0.55,
    rectWidth: strokeWidth.toDouble(),
    rectHeight: jinHeight * 0.5,
    angle: -0.35,
    color: color,
  );

  // 右捺
  drawRotatedRect(
    image,
    centerX: centerX + jinWidth * 0.18,
    centerY: jinTop + jinHeight * 0.55,
    rectWidth: strokeWidth.toDouble(),
    rectHeight: jinHeight * 0.5,
    angle: 0.35,
    color: color,
  );
}

/// 绘制心形
void drawHeart(
  img.Image image, {
  required double centerX,
  required double centerY,
  required double heartWidth,
  required double heartHeight,
  required img.Color color,
}) {
  // 使用参数方程绘制心形
  // x = 16 * sin^3(t)
  // y = 13 * cos(t) - 5 * cos(2t) - 2 * cos(3t) - cos(4t)

  final points = <List<double>>[];

  for (double t = 0; t <= 2 * math.pi; t += 0.01) {
    final x = 16 * math.pow(math.sin(t), 3);
    final y =
        -(13 * math.cos(t) -
            5 * math.cos(2 * t) -
            2 * math.cos(3 * t) -
            math.cos(4 * t));

    // 缩放到目标尺寸
    final scaledX = centerX + x * heartWidth / 32;
    final scaledY = centerY + y * heartHeight / 32;

    points.add([scaledX, scaledY]);
  }

  // 填充心形（使用扫描线算法）
  fillPolygon(image, points, color);
}

/// 填充多边形
void fillPolygon(img.Image image, List<List<double>> points, img.Color color) {
  if (points.isEmpty) return;

  // 找到边界
  double minY = double.infinity;
  double maxY = double.negativeInfinity;

  for (final point in points) {
    if (point[1] < minY) minY = point[1];
    if (point[1] > maxY) maxY = point[1];
  }

  // 扫描每一行
  for (int y = minY.floor(); y <= maxY.ceil(); y++) {
    if (y < 0 || y >= image.height) continue;

    // 找到与这一行相交的所有点
    final intersections = <double>[];

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];

      final y1 = p1[1];
      final y2 = p2[1];

      if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) {
        final x = p1[0] + (y - y1) / (y2 - y1) * (p2[0] - p1[0]);
        intersections.add(x);
      }
    }

    intersections.sort();

    // 填充交点之间的区域
    for (int i = 0; i < intersections.length - 1; i += 2) {
      final x1 = intersections[i].round();
      final x2 = intersections[i + 1].round();

      for (int x = x1; x <= x2; x++) {
        if (x >= 0 && x < image.width) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
}

/// 绘制圆角矩形
void drawRoundedRect(
  img.Image image, {
  required double centerX,
  required double centerY,
  required double rectWidth,
  required double rectHeight,
  required img.Color color,
}) {
  final left = (centerX - rectWidth / 2).round();
  final top = (centerY - rectHeight / 2).round();
  final right = (centerX + rectWidth / 2).round();
  final bottom = (centerY + rectHeight / 2).round();
  final radius = (math.min(rectWidth, rectHeight) / 2).round();

  for (int y = top; y <= bottom; y++) {
    for (int x = left; x <= right; x++) {
      if (x < 0 || x >= image.width || y < 0 || y >= image.height) continue;

      // 检查是否在圆角矩形内
      bool inside = false;

      // 中间矩形区域
      if (x >= left + radius && x <= right - radius) {
        inside = true;
      } else if (y >= top + radius && y <= bottom - radius) {
        inside = true;
      } else {
        // 检查四个角的圆形区域
        final corners = [
          [left + radius, top + radius],
          [right - radius, top + radius],
          [left + radius, bottom - radius],
          [right - radius, bottom - radius],
        ];

        for (final corner in corners) {
          final dx = x - corner[0];
          final dy = y - corner[1];
          if (dx * dx + dy * dy <= radius * radius) {
            inside = true;
            break;
          }
        }
      }

      if (inside) {
        image.setPixel(x, y, color);
      }
    }
  }
}

/// 绘制旋转的矩形
void drawRotatedRect(
  img.Image image, {
  required double centerX,
  required double centerY,
  required double rectWidth,
  required double rectHeight,
  required double angle,
  required img.Color color,
}) {
  final cos = math.cos(angle);
  final sin = math.sin(angle);

  // 计算需要检查的区域
  final maxDim = math.max(rectWidth, rectHeight);
  final checkRadius = (maxDim * 0.8).round();

  for (int dy = -checkRadius; dy <= checkRadius; dy++) {
    for (int dx = -checkRadius; dx <= checkRadius; dx++) {
      // 将点旋转回矩形坐标系
      final rotatedX = dx * cos + dy * sin;
      final rotatedY = -dx * sin + dy * cos;

      // 检查是否在矩形内
      if (rotatedX.abs() <= rectWidth / 2 && rotatedY.abs() <= rectHeight / 2) {
        final x = (centerX + dx).round();
        final y = (centerY + dy).round();

        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
}
