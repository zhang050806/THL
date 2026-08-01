import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';
import '../theme/theme_manager.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [GeneralSettingsPage] 通用设置页面。
/// 提供语言切换（中/英）和深色模式开关，修改即时生效并持久化。
class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeManager = context.watch<ThemeManager>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: l10n.generalSettings, onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---- 语言设置卡片 ----
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161B22)
                          : Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16)),
                      boxShadow: isDark
                          ? const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, -2)),
                              BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 16,
                                  offset: Offset(0, 8)),
                            ]
                          : const [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 8,
                                  offset: Offset(0, -2)),
                              BoxShadow(
                                  color: Color(0x204A90E2),
                                  blurRadius: 16,
                                  offset: Offset(0, 8)),
                            ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: const Icon(Icons.language,
                          color: Color(0xFF4A90E2), size: 22),
                      title: Text(l10n.language,
                          style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFFE6EDF3)
                                  : const Color(0xFF1A1D26))),
                      // 语言选择器：中文 / English 两个按钮
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _langChip(context, '中文', 'zh', isDark),
                          const SizedBox(width: 8),
                          _langChip(context, 'English', 'en', isDark),
                        ],
                      ),
                    ),
                  ),
                  // ---- 深色模式开关卡片 ----
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161B22)
                          : Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16)),
                      boxShadow: isDark
                          ? const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, -2)),
                              BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 16,
                                  offset: Offset(0, 8)),
                            ]
                          : const [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 8,
                                  offset: Offset(0, -2)),
                              BoxShadow(
                                  color: Color(0x204A90E2),
                                  blurRadius: 16,
                                  offset: Offset(0, 8)),
                            ],
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      secondary: Icon(
                          themeManager.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: const Color(0xFF4A90E2),
                          size: 22),
                      title: Text(l10n.darkMode,
                          style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFFE6EDF3)
                                  : const Color(0xFF1A1D26))),
                      value: themeManager.isDarkMode,
                      // 切换暗色模式：调用 ThemeManager.toggle() 并通知 UI 刷新
                      onChanged: (_) => themeManager.toggle(),
                      // 自定义 Switch 颜色
                      activeColor: const Color(0xFF4A90E2),
                    ),
                  ),
                  // ---- 服务条款入口 ----
                  _listItem(
                    context,
                    icon: Icons.description_outlined,
                    title: l10n.termsOfService,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsOfServicePage()),
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  // ---- 隐私政策入口 ----
                  _listItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage()),
                    ),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 单个语言选择 Chip。
  /// 当前语言高亮蓝色背景白色文字，非当前语言灰色背景。
  Widget _langChip(
      BuildContext context, String label, String code, bool isDark) {
    final current = AppLocalizationsController.languageCode;

    return GestureDetector(
      onTap: () async {
        // 已经是当前语言则不操作
        if (current == code) return;
        // 持久化语言偏好
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_language', code);
        // 更新全局语言码并触发语言切换事件
        AppLocalizationsController.languageCode = code;
        AppLocalizationsController.onLocaleChanged?.call(Locale(code));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: current == code
              ? const Color(0xFF4A90E2)
              : (isDark
                  ? const Color(0xFF21262D)
                  : const Color(0xFFF0F0F5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                current == code ? FontWeight.w600 : FontWeight.normal,
            color: current == code
                ? Colors.white
                : (isDark
                    ? const Color(0xFF8B949E)
                    : const Color(0xFFA0AEC0)),
          ),
        ),
      ),
    );
  }

  /// 通用列表项组件：图标 + 标题 + 点击跳转。
  /// 与 profile_page 中的 _listItem 样式保持一致。
  Widget _listItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: isDark
              ? const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2)),
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16,
                      offset: Offset(0, 8)),
                ]
              : const [
                  BoxShadow(
                      color: Colors.white,
                      blurRadius: 8,
                      offset: Offset(0, -2)),
                  BoxShadow(
                      color: Color(0x204A90E2),
                      blurRadius: 16,
                      offset: Offset(0, 8)),
                ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A90E2), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFE6EDF3)
                      : const Color(0xFF1A1D26),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? const Color(0xFF8B949E)
                  : const Color(0xFFA0AEC0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
