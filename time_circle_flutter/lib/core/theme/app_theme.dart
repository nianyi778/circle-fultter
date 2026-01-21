import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TimeCircle 设计系统 - 色彩
/// 
/// 设计哲学：温柔、安静、克制
/// 这是一个"时间容器"，不是效率工具
class AppColors {
  AppColors._();
  
  // === 主色调 ===
  
  /// Time Beige（时间米白）- 背景主色
  /// 用途：App 全局背景
  /// 气质：像旧纸张、像晨光
  static const Color timeBeige = Color(0xFFFAF9F7);
  static const Color timeBeigeLight = Color(0xFFFCFBF9);
  static const Color timeBeigeWarm = Color(0xFFFDF9F5);
  
  /// Warm Gray（暖灰）- 文字/分割
  /// 用途：正文、辅助说明
  static const Color warmGray900 = Color(0xFF292524);
  static const Color warmGray800 = Color(0xFF44403C);
  static const Color warmGray700 = Color(0xFF57534E);
  static const Color warmGray600 = Color(0xFF78716C);
  static const Color warmGray500 = Color(0xFFA8A29E);
  static const Color warmGray400 = Color(0xFFD6D3D1);
  static const Color warmGray300 = Color(0xFFE7E5E4);
  static const Color warmGray200 = Color(0xFFF5F5F4);
  static const Color warmGray100 = Color(0xFFFAFAF9);
  
  // === 情绪辅助色（低饱和，仅点缀）===
  
  /// Calm Blue - 平静/回忆
  static const Color calmBlue = Color(0xFFD4E5F7);
  static const Color calmBlueDeep = Color(0xFF6B9AC4);
  
  /// Warm Peach - 温暖/成长
  static const Color warmPeach = Color(0xFFFEE2D5);
  static const Color warmPeachDeep = Color(0xFFE8B4A0);
  
  /// Soft Green - 安心/日常
  static const Color softGreen = Color(0xFFD8E8D8);
  static const Color softGreenDeep = Color(0xFF8CB88C);
  
  /// Muted Violet - 夜晚/思念
  static const Color mutedViolet = Color(0xFFE5DDF0);
  static const Color mutedVioletDeep = Color(0xFFA695BC);
  
  /// Orange - 声音/活力
  static const Color warmOrange = Color(0xFFFFF7ED);
  static const Color warmOrangeDeep = Color(0xFFFDBA74);
  static const Color warmOrangeDark = Color(0xFFC2410C);
  
  // === 功能色 ===
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  /// 成功/已解锁
  static const Color success = Color(0xFF86EFAC);
  static const Color successDark = Color(0xFF166534);
  
  /// 警告/草稿
  static const Color warning = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFFCA8A04);
  
  /// 危险/删除
  static const Color danger = Color(0xFFFECACA);
  static const Color dangerDark = Color(0xFFDC2626);
  
  /// 爱心/共鸣
  static const Color heart = Color(0xFFF87171);
}

/// TimeCircle 设计系统 - 间距
class AppSpacing {
  AppSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  /// 页面边距：左右 20-24
  static const double pagePadding = 20.0;
  
  /// 模块之间：至少 24
  static const double sectionGap = 24.0;
  
  /// 卡片内边距
  static const double cardPadding = 20.0;
  
  /// 卡片间距
  static const double cardGap = 16.0;
}

/// TimeCircle 设计系统 - 圆角
class AppRadius {
  AppRadius._();
  
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;
  
  /// 卡片圆角：16-24
  static const double card = 20.0;
  
  /// 按钮圆角：20+
  static const double button = 24.0;
}

/// TimeCircle 设计系统 - 阴影
/// 只用 1 层极浅阴影，用于"浮起感"
class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: AppColors.warmGray900.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// TimeCircle 设计系统 - 动效
/// 动效原则：慢一点、轻一点、永远不打断情绪
class AppDurations {
  AppDurations._();
  
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
}

/// TimeCircle 设计系统 - 曲线
class AppCurves {
  AppCurves._();
  
  /// 标准缓动
  static const Curve standard = Curves.easeOutCubic;
  
  /// 进入动画
  static const Curve enter = Curves.easeOutQuart;
  
  /// 退出动画
  static const Curve exit = Curves.easeInQuart;
  
  /// 弹性（慎用）
  static const Curve gentle = Curves.easeInOutCubic;
}

/// TimeCircle 主题
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
        iconTheme: const IconThemeData(
          color: AppColors.warmGray700,
          size: 24,
        ),
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
          side: BorderSide(
            color: AppColors.warmGray300.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warmGray800,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
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
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.warmGray300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.warmGray300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.warmGray500,
            width: 1.5,
          ),
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
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
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
        fontSize: 36,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.3,
      ),
      displayMedium: GoogleFonts.notoSerifSc(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.notoSerifSc(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.3,
      ),
      
      // Headline - 页面标题
      headlineLarge: GoogleFonts.notoSerifSc(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.notoSerifSc(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.notoSerifSc(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.4,
      ),
      
      // Title - 模块标题
      titleLarge: GoogleFonts.notoSansSc(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.5,
      ),
      titleMedium: GoogleFonts.notoSansSc(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray800,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray700,
        height: 1.5,
      ),
      
      // Body - 正文（行高偏大 1.6-1.8）
      bodyLarge: GoogleFonts.notoSansSc(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray700,
        height: 1.7,
      ),
      bodyMedium: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray700,
        height: 1.7,
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
        fontWeight: FontWeight.w500,
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
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray500,
        height: 1.4,
        letterSpacing: 0.5,
      ),
    );
  }
}
