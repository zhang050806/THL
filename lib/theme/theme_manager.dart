import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ThemeManager] 全局主题管理器。
/// 基于 ChangeNotifier 实现，用于控制亮色/暗色主题模式的切换，
/// 并在切换时自动持久化用户偏好到 SharedPreferences。
class ThemeManager extends ChangeNotifier {
  /// 当前是否为暗色模式
  bool _isDarkMode = false;

  /// 获取当前暗色模式状态。
  bool get isDarkMode => _isDarkMode;

  /// 返回 Flutter 的 ThemeMode 枚举值。
  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// 构造函数：从 SharedPreferences 异步加载已保存的主题偏好。
  ThemeManager() {
    _loadTheme();
  }

  /// 从 SharedPreferences 加载主题偏好键 `is_dark_mode`。
  /// 加载完成后调用 notifyListeners() 刷新 UI。
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    notifyListeners(); // 通知 Consumer 重建
  }

  /// 切换暗色模式状态，并持久化到 SharedPreferences。
  Future<void> toggle() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners(); // 通知所有监听者刷新 UI
  }
}
