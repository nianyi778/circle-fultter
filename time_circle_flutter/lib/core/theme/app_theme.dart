import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aura 设计系统 - 色彩
///
/// 设计哲学：温柔、安静、克制
/// 这是一个"时间容器"，不是效率工具
class AppColors {
  AppColors._();

  // === Aura 品牌色 ===

  /// Aura Primary - 拾光橙（品牌主色）
  /// 用途：品牌强调、光效、进度条
  /// 气质：温暖的灵光，像午后阳光
  static const Color primary = Color(0xFFD97706); // 更鲜明的橙色
  static const Color primaryLight = Color(0xFFFFF7ED);
  static const Color primaryMuted = Color(0xFFF59E0B); // 更亮的中间色
  static const Color primaryDark = Color(0xFFB45309);

  /// 品牌光效
  static Color get primaryGlow => primary.withValues(alpha: 0.18);
  static Color get primaryGlowStrong => primary.withValues(alpha: 0.30);

  // === 主色调 ===

  /// Time Beige（时间米白）- 背景主色
  /// 用途：App 全局背景
  /// 气质：像旧纸张、像晨光
  static const Color timeBeige = Color(0xFFF8F6F3); // 稍微加深
  static const Color timeBeigeLight = Color(0xFFFBFAF8);
  static const Color timeBeigeWarm = Color(0xFFFAF5F0);

  // === 背景层级 ===
  static const Color bg = Color(0xFFF8F6F3); // 主背景（时间米白）
  static const Color bgElevated = Color(0xFFFFFFFF); // 浮起卡片背景
  static const Color bgMuted = Color(0xFFF0EEEB); // 次级背景区域，加深

  /// Warm Gray（暖灰）- 文字/分割
  /// 用途：正文、辅助说明
  /// 10 级灰度系统，整体加深提高对比度
  static const Color warmGray900 = Color(0xFF171412); // 更深的黑
  static const Color warmGray850 = Color(0xFF231F1C);
  static const Color warmGray800 = Color(0xFF3D3835);
  static const Color warmGray700 = Color(0xFF504A46);
  static const Color warmGray600 = Color(0xFF6B6460);
  static const Color warmGray500 = Color(0xFF8A837E); // 加深
  static const Color warmGray400 = Color(0xFFB5AFAA); // 加深
  static const Color warmGray350 = Color(0xFFC7C2BD);
  static const Color warmGray300 = Color(0xFFD9D5D1); // 加深
  static const Color warmGray250 = Color(0xFFE3E0DC);
  static const Color warmGray200 = Color(0xFFEBE9E6);
  static const Color warmGray150 = Color(0xFFF2F0EE);
  static const Color warmGray100 = Color(0xFFF7F6F4);
  static const Color warmGray50 = Color(0xFFFBFAF9);

  // === 情绪辅助色（提高饱和度）===
  // 每种颜色提供 light/medium/deep 三档变体

  /// Calm Blue - 平静/回忆
  static const Color calmBlueLight = Color(0xFFDCEBFA);
  static const Color calmBlue = Color(0xFFB8D4F1);
  static const Color calmBlueDeep = Color(0xFF4A8AC9); // 更鲜明

  /// Warm Peach - 温暖/成长
  static const Color warmPeachLight = Color(0xFFFFF0E8);
  static const Color warmPeach = Color(0xFFFFD4BE);
  static const Color warmPeachDeep = Color(0xFFE86A3A); // 更鲜明

  /// Soft Green - 安心/日常
  static const Color softGreenLight = Color(0xFFDEF0DE);
  static const Color softGreen = Color(0xFFB8DCB8);
  static const Color softGreenDeep = Color(0xFF4A9A4A); // 更鲜明

  /// Muted Violet - 夜晚/思念
  static const Color mutedVioletLight = Color(0xFFE8E0F2);
  static const Color mutedViolet = Color(0xFFD0C0E5);
  static const Color mutedVioletDeep = Color(0xFF7A60A0); // 更鲜明

  /// Orange - 声音/活力/年度信
  static const Color warmOrangeLight = Color(0xFFFFF5EB);
  static const Color warmOrange = Color(0xFFFFE8D4);
  static const Color warmOrangeDeep = Color(0xFFF59E0B); // 更鲜明
  static const Color warmOrangeDark = Color(0xFFB45309);

  // === 功能色 ===
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  /// 成功/已解锁
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color success = Color(0xFF6EE7B7);
  static const Color successDark = Color(0xFF059669); // 更鲜明

  /// 警告/草稿
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warning = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFD97706); // 更鲜明

  /// 危险/删除
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color danger = Color(0xFFFCA5A5);
  static const Color dangerDark = Color(0xFFDC2626);

  /// 爱心/共鸣
  static const Color heartLight = Color(0xFFFEE2E2);
  static const Color heart = Color(0xFFEF4444); // 更鲜明
  static const Color heartDark = Color(0xFFB91C1C);
}

/// Aura 设计系统 - 间距
class AppSpacing {
  AppSpacing._();

  // 基础间距（8px 基数）
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0; // 默认基础间距
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  /// 页面水平边距
  static const double pagePadding = 20.0;
  static const double pageH = 20.0;

  /// 页面顶部边距
  static const double pageTop = 16.0;

  /// 模块之间：32px（增大）
  static const double sectionGap = 32.0;

  /// 卡片内边距
  static const double cardPadding = 20.0;

  /// 卡片间距：24px（增大）
  static const double cardGap = 24.0;
}

/// Aura 设计系统 - 圆角
class AppRadius {
  AppRadius._();

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;

  /// 卡片圆角：24px（增大）
  static const double card = 24.0;

  /// 按钮圆角
  static const double button = 20.0;

  /// 标签圆角
  static const double chip = 16.0;

  /// 输入框圆角
  static const double input = 12.0;

  /// 头像圆角
  static const double avatar = 999.0;
}

/// Aura 设计系统 - 阴影
/// 使用多层柔和阴影，模拟纸张质感
class AppShadows {
  AppShadows._();

  /// 极浅阴影（微浮起感）
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// 柔和阴影（卡片）
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.03),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// 纸张质感阴影
  static List<BoxShadow> get paper => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.02),
      blurRadius: 1,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.02),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// 浮层阴影（Modal、Drawer）
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.04),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  /// 底部导航栏阴影
  static List<BoxShadow> get navigation => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, -2),
    ),
  ];
}

/// Aura 设计系统 - 动效
/// 动效原则：慢一点、轻一点、永远不打断情绪
class AppDurations {
  AppDurations._();

  /// 瞬间 - 100ms
  static const Duration instant = Duration(milliseconds: 100);

  /// 快速交互 - 150ms
  static const Duration fast = Duration(milliseconds: 150);

  /// 标准动画 - 250ms
  static const Duration normal = Duration(milliseconds: 250);

  /// 页面切换 - 300ms
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// 缓慢出现 - 400ms
  static const Duration slow = Duration(milliseconds: 400);

  /// 封存等仪式动画 - 600ms
  static const Duration ceremony = Duration(milliseconds: 600);

  /// 页面入场 - 800ms
  static const Duration entrance = Duration(milliseconds: 800);

  /// 呼吸循环 - 2000ms
  static const Duration breathing = Duration(milliseconds: 2000);
}

/// Aura 设计系统 - 曲线
class AppCurves {
  AppCurves._();

  /// 标准缓动
  static const Curve standard = Curves.easeOutCubic;

  /// 进入动画（更柔和的开始）
  static const Curve enter = Cubic(0.0, 0.0, 0.2, 1.0);

  /// 退出动画
  static const Curve exit = Cubic(0.4, 0.0, 1.0, 1.0);

  /// 呼吸曲线（用于循环动画）
  static const Curve breathing = Cubic(0.4, 0.0, 0.6, 1.0);

  /// 柔和弹性曲线（非常克制的弹跳）
  static const Curve gentle = Cubic(0.34, 1.56, 0.64, 1.0);

  /// 缓入缓出
  static const Curve smooth = Curves.easeInOutCubic;
}

/// Aura 设计系统 - 字体样式
/// 提供语义化的字体层级
class AppTypography {
  AppTypography._();

  /// Hero - 首页时间数字（超大）
  static TextStyle hero(BuildContext context) => GoogleFonts.notoSerifSc(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    letterSpacing: -1,
    height: 1.1,
    color: AppColors.warmGray800,
  );

  /// Title - 页面标题、时间叙事
  static TextStyle title(BuildContext context) => GoogleFonts.notoSerifSc(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.warmGray700,
  );

  /// Subtitle - 卡片标题、Section 标题
  static TextStyle subtitle(BuildContext context) => GoogleFonts.notoSansSc(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.warmGray700,
  );

  /// Body - 正文内容
  static TextStyle body(BuildContext context) => GoogleFonts.notoSansSc(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.75,
    color: AppColors.warmGray600,
  );

  /// BodySerif - 详情页正文（衬线字体）
  static TextStyle bodySerif(BuildContext context) => GoogleFonts.notoSerifSc(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.85,
    color: AppColors.warmGray700,
  );

  /// Caption - 辅助说明、时间戳
  static TextStyle caption(BuildContext context) => GoogleFonts.notoSansSc(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.warmGray500,
  );

  /// Micro - 极小标签
  static TextStyle micro(BuildContext context) => GoogleFonts.notoSansSc(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.4,
    color: AppColors.warmGray500,
  );
}

/// Aura 主题
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 色彩方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.warmGray800,
        brightness: Brightness.light,
        surface: AppColors.timeBeige,
        onSurface: AppColors.warmGray800,
      ),

      // 背景色
      scaffoldBackgroundColor: AppColors.timeBeige,

      // 文字主题
      textTheme: _buildTextTheme(),

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.warmGray800,
        ),
        iconTheme: const IconThemeData(color: AppColors.warmGray700, size: 24),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.warmGray800,
        unselectedItemColor: AppColors.warmGray500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warmGray800,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.notoSansSc(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.warmGray700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.notoSansSc(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.warmGray300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.warmGray300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.warmGray400, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.notoSansSc(
          color: AppColors.warmGray400,
          fontSize: 16,
        ),
      ),

      // 分隔线主题
      dividerTheme: DividerThemeData(
        color: AppColors.warmGray200,
        thickness: 1,
        space: 1,
      ),

      // 芯片主题
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.warmGray100,
        labelStyle: GoogleFonts.notoSansSc(
          fontSize: 12,
          color: AppColors.warmGray600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // 底部弹出框主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.warmGray300,
        dragHandleSize: Size(40, 4),
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.warmGray800,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    // 标题使用 Noto Serif SC - 稳重、有呼吸感
    // 正文使用 Noto Sans SC - 清晰、舒适

    return TextTheme(
      // Display - 超大标题
      displayLarge: GoogleFonts.notoSerifSc(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        color: AppColors.warmGray800,
        height: 1.1,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.notoSerifSc(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray800,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.notoSerifSc(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray800,
        height: 1.3,
      ),

      // Headline - 页面标题
      headlineLarge: GoogleFonts.notoSerifSc(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.notoSerifSc(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray800,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.notoSerifSc(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray700,
        height: 1.4,
      ),

      // Title - 模块标题
      titleLarge: GoogleFonts.notoSansSc(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.warmGray800,
        height: 1.5,
      ),
      titleMedium: GoogleFonts.notoSansSc(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.warmGray800,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.warmGray700,
        height: 1.5,
      ),

      // Body - 正文（行高偏大 1.7-1.85）
      bodyLarge: GoogleFonts.notoSansSc(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray700,
        height: 1.75,
        letterSpacing: 0.3,
      ),
      bodyMedium: GoogleFonts.notoSansSc(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray600,
        height: 1.7,
        letterSpacing: 0.2,
      ),
      bodySmall: GoogleFonts.notoSansSc(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray600,
        height: 1.6,
      ),

      // Label - 按钮、标签
      labelLarge: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.warmGray800,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.notoSansSc(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray600,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.notoSansSc(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray500,
        height: 1.4,
        letterSpacing: 0.3,
      ),
    );
  }
}
