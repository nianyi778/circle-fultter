import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/database_service.dart';

/// 设置键名常量
class SettingsKeys {
  static const String annualLetterReminder = 'annual_letter_reminder';
  static const String faceBlurEnabled = 'face_blur_enabled';
  static const String defaultVisibility = 'default_visibility';
  static const String timeLockDuration = 'time_lock_duration';
}

/// 可见性选项
enum ContentVisibility {
  private('private', '仅自己', '只有自己可以看到'),
  circle('circle', '圈子', '圈子内的成员可以看到'),
  world('world', '世界', '所有人都可以看到');

  final String value;
  final String label;
  final String description;

  const ContentVisibility(this.value, this.label, this.description);

  static ContentVisibility fromValue(String value) {
    return ContentVisibility.values.firstWhere(
      (v) => v.value == value,
      orElse: () => ContentVisibility.private,
    );
  }
}

/// 时间锁选项
class TimeLockOption {
  final int days;
  final String label;
  final String description;

  const TimeLockOption(this.days, this.label, this.description);

  static const List<TimeLockOption> options = [
    TimeLockOption(30, '30天', '一个月后可以打开'),
    TimeLockOption(90, '90天', '三个月后可以打开'),
    TimeLockOption(180, '半年', '半年后可以打开'),
    TimeLockOption(365, '一年', '一年后可以打开'),
    TimeLockOption(730, '两年', '两年后可以打开'),
    TimeLockOption(1825, '五年', '五年后可以打开'),
    TimeLockOption(3650, '十年', '十年后可以打开'),
  ];

  static TimeLockOption fromDays(int days) {
    return options.firstWhere(
      (o) => o.days == days,
      orElse: () => options[3], // 默认一年
    );
  }
}

/// 设置状态
class SettingsState {
  final bool annualLetterReminder;
  final bool faceBlurEnabled;
  final ContentVisibility defaultVisibility;
  final int timeLockDuration;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.annualLetterReminder = true,
    this.faceBlurEnabled = true,
    this.defaultVisibility = ContentVisibility.private,
    this.timeLockDuration = 365,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    bool? annualLetterReminder,
    bool? faceBlurEnabled,
    ContentVisibility? defaultVisibility,
    int? timeLockDuration,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      annualLetterReminder: annualLetterReminder ?? this.annualLetterReminder,
      faceBlurEnabled: faceBlurEnabled ?? this.faceBlurEnabled,
      defaultVisibility: defaultVisibility ?? this.defaultVisibility,
      timeLockDuration: timeLockDuration ?? this.timeLockDuration,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 设置 StateNotifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final DatabaseService _db;

  SettingsNotifier(this._db) : super(const SettingsState(isLoading: true)) {
    _loadSettings();
  }

  /// 加载所有设置
  Future<void> _loadSettings() async {
    try {
      final annualLetterReminder = await _db.getBoolSetting(
        SettingsKeys.annualLetterReminder,
        defaultValue: true,
      );
      final faceBlurEnabled = await _db.getBoolSetting(
        SettingsKeys.faceBlurEnabled,
        defaultValue: true,
      );
      final defaultVisibilityValue = await _db.getSettingWithDefault(
        SettingsKeys.defaultVisibility,
        'private',
      );
      final timeLockDuration = await _db.getIntSetting(
        SettingsKeys.timeLockDuration,
        defaultValue: 365,
      );

      state = SettingsState(
        annualLetterReminder: annualLetterReminder,
        faceBlurEnabled: faceBlurEnabled,
        defaultVisibility: ContentVisibility.fromValue(defaultVisibilityValue),
        timeLockDuration: timeLockDuration,
        isLoading: false,
      );
    } catch (e) {
      state = SettingsState(isLoading: false, error: '加载设置失败: $e');
    }
  }

  /// 刷新设置
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadSettings();
  }

  /// 设置年度信提醒
  Future<void> setAnnualLetterReminder(bool value) async {
    try {
      await _db.saveBoolSetting(SettingsKeys.annualLetterReminder, value);
      state = state.copyWith(annualLetterReminder: value);
    } catch (e) {
      state = state.copyWith(error: '保存失败: $e');
    }
  }

  /// 设置面部模糊
  Future<void> setFaceBlurEnabled(bool value) async {
    try {
      await _db.saveBoolSetting(SettingsKeys.faceBlurEnabled, value);
      state = state.copyWith(faceBlurEnabled: value);
    } catch (e) {
      state = state.copyWith(error: '保存失败: $e');
    }
  }

  /// 设置默认可见性
  Future<void> setDefaultVisibility(ContentVisibility value) async {
    try {
      await _db.saveSetting(SettingsKeys.defaultVisibility, value.value);
      state = state.copyWith(defaultVisibility: value);
    } catch (e) {
      state = state.copyWith(error: '保存失败: $e');
    }
  }

  /// 设置时间锁时长
  Future<void> setTimeLockDuration(int days) async {
    try {
      await _db.saveIntSetting(SettingsKeys.timeLockDuration, days);
      state = state.copyWith(timeLockDuration: days);
    } catch (e) {
      state = state.copyWith(error: '保存失败: $e');
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 设置 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final db = ref.watch(databaseServiceProvider);
    return SettingsNotifier(db);
  },
);

/// 便捷访问器
final annualLetterReminderProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).annualLetterReminder;
});

final faceBlurEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).faceBlurEnabled;
});

final defaultVisibilityProvider = Provider<ContentVisibility>((ref) {
  return ref.watch(settingsProvider).defaultVisibility;
});

final timeLockDurationProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).timeLockDuration;
});
