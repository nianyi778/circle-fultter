import 'package:shared_preferences/shared_preferences.dart';

/// 设置 Repository
///
/// 处理本地设置的存储，使用 SharedPreferences。
/// 不需要同步到服务器的纯本地设置。
class SettingsRepository {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _firstLaunchKey = 'first_launch';
  static const String _lastSelectedCircleKey = 'last_selected_circle_id';
  static const String _mediaAutoPlayKey = 'media_auto_play';
  static const String _mediaQualityKey = 'media_quality';

  SharedPreferences? _prefs;

  /// 初始化 SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 确保已初始化
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ============== 主题设置 ==============

  /// 获取主题模式 (system, light, dark)
  Future<String> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_themeKey) ?? 'system';
  }

  /// 设置主题模式
  Future<void> setThemeMode(String mode) async {
    final prefs = await _getPrefs();
    await prefs.setString(_themeKey, mode);
  }

  // ============== 语言设置 ==============

  /// 获取语言设置
  Future<String?> getLocale() async {
    final prefs = await _getPrefs();
    return prefs.getString(_localeKey);
  }

  /// 设置语言
  Future<void> setLocale(String locale) async {
    final prefs = await _getPrefs();
    await prefs.setString(_localeKey, locale);
  }

  // ============== 通知设置 ==============

  /// 获取通知开关状态
  Future<bool> isNotificationsEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  /// 设置通知开关
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_notificationsKey, enabled);
  }

  // ============== 首次启动 ==============

  /// 是否首次启动
  Future<bool> isFirstLaunch() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// 标记已完成首次启动
  Future<void> setFirstLaunchComplete() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_firstLaunchKey, false);
  }

  // ============== 圈子选择 ==============

  /// 获取上次选择的圈子 ID
  Future<String?> getLastSelectedCircleId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastSelectedCircleKey);
  }

  /// 设置上次选择的圈子 ID
  Future<void> setLastSelectedCircleId(String circleId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastSelectedCircleKey, circleId);
  }

  // ============== 媒体设置 ==============

  /// 获取媒体自动播放设置
  Future<bool> isMediaAutoPlayEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_mediaAutoPlayKey) ?? true;
  }

  /// 设置媒体自动播放
  Future<void> setMediaAutoPlayEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_mediaAutoPlayKey, enabled);
  }

  /// 获取媒体质量设置 (auto, high, medium, low)
  Future<String> getMediaQuality() async {
    final prefs = await _getPrefs();
    return prefs.getString(_mediaQualityKey) ?? 'auto';
  }

  /// 设置媒体质量
  Future<void> setMediaQuality(String quality) async {
    final prefs = await _getPrefs();
    await prefs.setString(_mediaQualityKey, quality);
  }

  // ============== 应用设置 ==============

  static const String _annualLetterReminderKey = 'annual_letter_reminder';
  static const String _faceBlurEnabledKey = 'face_blur_enabled';
  static const String _defaultVisibilityKey = 'default_visibility';
  static const String _timeLockDurationKey = 'time_lock_duration';
  static const String _lastBackupTimeKey = 'last_backup_time';

  /// 获取年度信提醒开关
  Future<bool> isAnnualLetterReminderEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_annualLetterReminderKey) ?? true;
  }

  /// 设置年度信提醒开关
  Future<void> setAnnualLetterReminderEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_annualLetterReminderKey, enabled);
  }

  /// 获取面部模糊开关
  Future<bool> isFaceBlurEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_faceBlurEnabledKey) ?? true;
  }

  /// 设置面部模糊开关
  Future<void> setFaceBlurEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_faceBlurEnabledKey, enabled);
  }

  /// 获取默认可见性
  Future<String> getDefaultVisibility() async {
    final prefs = await _getPrefs();
    return prefs.getString(_defaultVisibilityKey) ?? 'private';
  }

  /// 设置默认可见性
  Future<void> setDefaultVisibility(String visibility) async {
    final prefs = await _getPrefs();
    await prefs.setString(_defaultVisibilityKey, visibility);
  }

  /// 获取时间锁时长（天数）
  Future<int> getTimeLockDuration() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_timeLockDurationKey) ?? 365;
  }

  /// 设置时间锁时长（天数）
  Future<void> setTimeLockDuration(int days) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_timeLockDurationKey, days);
  }

  /// 获取上次备份时间
  Future<String?> getLastBackupTime() async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastBackupTimeKey);
  }

  /// 设置上次备份时间
  Future<void> setLastBackupTime(String time) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastBackupTimeKey, time);
  }

  // ============== 清除所有设置 ==============

  /// 清除所有设置（用于退出登录）
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
