#!/usr/bin/env python3
"""
Aura Logo Generator - 全新设计

风格：极简抽象几何
配色：冷暖对比（橙 + 蓝/紫）
参考：Apple 系简洁风格

生成 3 个方案供选择：
  A. 双弧光环 - 两条对向弧线，橙+蓝渐变
  B. 日落分割 - 圆形一半橙一半蓝，中间渐变过渡
  C. 光点轨迹 - 一条优雅曲线 + 端点发光

使用方法：
    python scripts/generate_logo.py
"""

from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import math
import os

# ============ 配置常量 ============

SIZE = 1024
CENTER = SIZE // 2

# 冷暖对比配色
WARM_ORANGE = (255, 149, 0)  # Apple Orange
WARM_DEEP = (255, 94, 58)  # Apple Red-Orange
COOL_BLUE = (0, 122, 255)  # Apple Blue
COOL_PURPLE = (175, 82, 222)  # Apple Purple
COOL_TEAL = (90, 200, 250)  # Apple Teal

WHITE = (255, 255, 255)
NEAR_WHITE = (250, 250, 252)


def create_canvas():
    """创建白色画布"""
    return Image.new("RGBA", (SIZE, SIZE), (*NEAR_WHITE, 255))


def draw_smooth_arc(
    draw, center, radius, start_angle, end_angle, width, color_start, color_end
):
    """绘制渐变弧线"""
    cx, cy = center
    steps = 200

    for i in range(steps):
        t = i / steps
        angle = math.radians(start_angle + (end_angle - start_angle) * t)
        next_t = (i + 1) / steps
        next_angle = math.radians(start_angle + (end_angle - start_angle) * next_t)

        # 渐变颜色
        r = int(color_start[0] * (1 - t) + color_end[0] * t)
        g = int(color_start[1] * (1 - t) + color_end[1] * t)
        b = int(color_start[2] * (1 - t) + color_end[2] * t)

        x1 = cx + radius * math.cos(angle)
        y1 = cy + radius * math.sin(angle)
        x2 = cx + radius * math.cos(next_angle)
        y2 = cy + radius * math.sin(next_angle)

        draw.line([(x1, y1), (x2, y2)], fill=(r, g, b, 255), width=width)


def design_a_dual_arcs():
    """
    方案 A: 双弧光环
    两条对向弧线，形成呼应的动态感
    上弧：橙→红渐变
    下弧：蓝→紫渐变
    """
    canvas = create_canvas()

    # 主图层
    main = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(main)

    radius = int(SIZE * 0.35)
    arc_width = int(SIZE * 0.08)

    # 上弧（暖色，从右上到左上）
    draw_smooth_arc(
        draw,
        (CENTER, CENTER),
        radius,
        -160,
        -20,  # 上方弧线
        arc_width,
        WARM_ORANGE,
        WARM_DEEP,
    )

    # 下弧（冷色，从左下到右下）
    draw_smooth_arc(
        draw,
        (CENTER, CENTER),
        radius,
        20,
        160,  # 下方弧线
        arc_width,
        COOL_BLUE,
        COOL_PURPLE,
    )

    # 端点发光效果
    glow = main.filter(ImageFilter.GaussianBlur(radius=20))
    glow = Image.blend(Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0)), glow, 0.5)

    canvas = Image.alpha_composite(canvas, glow)
    canvas = Image.alpha_composite(canvas, main)

    return canvas


def design_b_sunset_split():
    """
    方案 B: 日落分割
    圆形，左半橙色渐变，右半蓝色渐变
    中间有柔和的过渡
    """
    canvas = create_canvas()

    radius = int(SIZE * 0.38)

    # 创建渐变圆
    pixels = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)

    for y in range(SIZE):
        for x in range(SIZE):
            dx = x - CENTER
            dy = y - CENTER
            dist = math.sqrt(dx * dx + dy * dy)

            if dist <= radius:
                # 计算水平位置比例 (-1 到 1)
                h_ratio = dx / radius

                # 从左（橙）到右（蓝）的渐变
                # 使用 smoothstep 让过渡更柔和
                t = (h_ratio + 1) / 2  # 0 到 1
                t = t * t * (3 - 2 * t)  # smoothstep

                # 垂直渐变（上亮下深）
                v_ratio = (dy / radius + 1) / 2

                # 左侧暖色
                warm_r = int(
                    WARM_ORANGE[0] * (1 - v_ratio * 0.3) + WARM_DEEP[0] * v_ratio * 0.3
                )
                warm_g = int(
                    WARM_ORANGE[1] * (1 - v_ratio * 0.3) + WARM_DEEP[1] * v_ratio * 0.3
                )
                warm_b = int(
                    WARM_ORANGE[2] * (1 - v_ratio * 0.3) + WARM_DEEP[2] * v_ratio * 0.3
                )

                # 右侧冷色
                cool_r = int(
                    COOL_TEAL[0] * (1 - v_ratio * 0.5) + COOL_BLUE[0] * v_ratio * 0.5
                )
                cool_g = int(
                    COOL_TEAL[1] * (1 - v_ratio * 0.5) + COOL_BLUE[1] * v_ratio * 0.5
                )
                cool_b = int(
                    COOL_TEAL[2] * (1 - v_ratio * 0.5) + COOL_BLUE[2] * v_ratio * 0.5
                )

                # 混合
                r = int(warm_r * (1 - t) + cool_r * t)
                g = int(warm_g * (1 - t) + cool_g * t)
                b = int(warm_b * (1 - t) + cool_b * t)

                # 边缘抗锯齿
                if dist > radius - 2:
                    alpha = int(255 * (radius - dist) / 2)
                else:
                    alpha = 255

                pixels[y, x] = [r, g, b, max(0, min(255, alpha))]

    circle = Image.fromarray(pixels, "RGBA")

    # 添加微妙的内阴影
    shadow_mask = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_mask)
    shadow_draw.ellipse(
        [CENTER - radius, CENTER - radius, CENTER + radius, CENTER + radius],
        outline=(0, 0, 0, 30),
        width=8,
    )
    shadow_mask = shadow_mask.filter(ImageFilter.GaussianBlur(radius=10))

    canvas = Image.alpha_composite(canvas, circle)
    canvas = Image.alpha_composite(canvas, shadow_mask)

    return canvas


def design_c_light_trace():
    """
    方案 C: 光点轨迹
    一条优雅的 S 曲线，从橙色渐变到蓝色
    两端有发光的圆点
    极简但有动态感
    """
    canvas = create_canvas()

    # 曲线图层
    curve = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(curve)

    # S 曲线参数
    amplitude = SIZE * 0.25
    line_width = int(SIZE * 0.045)

    # 绘制渐变 S 曲线
    points = []
    steps = 300

    for i in range(steps + 1):
        t = i / steps
        # S 曲线公式
        x = CENTER - amplitude + (amplitude * 2) * t
        y = CENTER + amplitude * 0.6 * math.sin(t * math.pi * 1.5 - math.pi * 0.25)
        points.append((x, y, t))

    # 绘制曲线（分段渐变）
    for i in range(len(points) - 1):
        x1, y1, t1 = points[i]
        x2, y2, t2 = points[i + 1]

        # 颜色渐变：橙 → 紫 → 蓝
        if t1 < 0.5:
            local_t = t1 * 2
            r = int(WARM_ORANGE[0] * (1 - local_t) + COOL_PURPLE[0] * local_t)
            g = int(WARM_ORANGE[1] * (1 - local_t) + COOL_PURPLE[1] * local_t)
            b = int(WARM_ORANGE[2] * (1 - local_t) + COOL_PURPLE[2] * local_t)
        else:
            local_t = (t1 - 0.5) * 2
            r = int(COOL_PURPLE[0] * (1 - local_t) + COOL_BLUE[0] * local_t)
            g = int(COOL_PURPLE[1] * (1 - local_t) + COOL_BLUE[1] * local_t)
            b = int(COOL_PURPLE[2] * (1 - local_t) + COOL_BLUE[2] * local_t)

        draw.line([(x1, y1), (x2, y2)], fill=(r, g, b, 255), width=line_width)

    # 圆角端点（用圆形覆盖）
    start_x, start_y, _ = points[0]
    end_x, end_y, _ = points[-1]
    dot_r = line_width // 2

    draw.ellipse(
        [start_x - dot_r, start_y - dot_r, start_x + dot_r, start_y + dot_r],
        fill=(*WARM_ORANGE, 255),
    )
    draw.ellipse(
        [end_x - dot_r, end_y - dot_r, end_x + dot_r, end_y + dot_r],
        fill=(*COOL_BLUE, 255),
    )

    # 端点发光
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)

    glow_r = int(SIZE * 0.08)

    # 橙色发光
    for i in range(glow_r, 0, -2):
        alpha = int(60 * (1 - i / glow_r))
        glow_draw.ellipse(
            [start_x - i, start_y - i, start_x + i, start_y + i],
            fill=(*WARM_ORANGE, alpha),
        )

    # 蓝色发光
    for i in range(glow_r, 0, -2):
        alpha = int(60 * (1 - i / glow_r))
        glow_draw.ellipse(
            [end_x - i, end_y - i, end_x + i, end_y + i], fill=(*COOL_BLUE, alpha)
        )

    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=15))

    # 曲线发光
    curve_glow = curve.filter(ImageFilter.GaussianBlur(radius=25))
    curve_glow = Image.blend(
        Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0)), curve_glow, 0.4
    )

    canvas = Image.alpha_composite(canvas, curve_glow)
    canvas = Image.alpha_composite(canvas, glow_layer)
    canvas = Image.alpha_composite(canvas, curve)

    return canvas


def create_rounded_rect_mask(width, height, radius):
    """创建圆角矩形蒙版"""
    mask = Image.new("L", (width, height), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (width - 1, height - 1)], radius=radius, fill=255)
    return mask


def save_logo(logo, name, output_dir):
    """保存 logo 及其变体"""
    # 主图标
    path = os.path.join(output_dir, f"{name}.png")
    logo.save(path, "PNG")

    # iOS 圆角版
    corner_radius = int(SIZE * 0.2237)
    mask = create_rounded_rect_mask(SIZE, SIZE, corner_radius)
    rounded = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    rounded.paste(logo, (0, 0), mask)
    rounded.save(os.path.join(output_dir, f"{name}_rounded.png"), "PNG")

    # Android 圆形版
    circle_mask = Image.new("L", (SIZE, SIZE), 0)
    circle_draw = ImageDraw.Draw(circle_mask)
    circle_draw.ellipse([0, 0, SIZE - 1, SIZE - 1], fill=255)
    circle = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    circle.paste(logo, (0, 0), circle_mask)
    circle.save(os.path.join(output_dir, f"{name}_circle.png"), "PNG")

    return path


def main():
    """生成所有设计方案"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    output_dir = os.path.join(project_dir, "assets", "icon")

    os.makedirs(output_dir, exist_ok=True)

    print("=" * 50)
    print("  Aura Logo Generator - 全新设计")
    print("  风格：极简抽象 + 冷暖对比 + Apple 风")
    print("=" * 50)

    # 方案 A
    print("\n[A] 双弧光环 - 生成中...")
    logo_a = design_a_dual_arcs()
    path_a = save_logo(logo_a, "design_a_dual_arcs", output_dir)
    print(f"    保存到: {path_a}")

    # 方案 B
    print("\n[B] 日落分割 - 生成中...")
    logo_b = design_b_sunset_split()
    path_b = save_logo(logo_b, "design_b_sunset", output_dir)
    print(f"    保存到: {path_b}")

    # 方案 C
    print("\n[C] 光点轨迹 - 生成中...")
    logo_c = design_c_light_trace()
    path_c = save_logo(logo_c, "design_c_trace", output_dir)
    print(f"    保存到: {path_c}")

    print("\n" + "=" * 50)
    print("  所有方案已生成！请查看 assets/icon/ 目录")
    print("  选择你喜欢的方案后告诉我编号 (A/B/C)")
    print("=" * 50)


if __name__ == "__main__":
    main()
