import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/app_localizations.dart';
import '../theme/theme_manager.dart';
import 'about_page.dart';
import 'firmware_update_page.dart';
import 'help_feedback_page.dart';
import 'notification_page.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

/// 通用设置页：每项独立卡片布局。
class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeManager = Provider.of<ThemeManager>(context);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26);
    final arrowColor = isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.generalSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // 语言
          _settingCard(
            icon: Icons.language,
            title: l10n.language,
            cardColor: cardColor,
            isDark: isDark,
            trailing: _languageToggle(l10n),
          ),
          // 深色模式
          _settingCard(
            icon: themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: l10n.darkMode,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Switch(
              value: themeManager.isDarkMode,
              activeColor: const Color(0xFF4A90E2),
              onChanged: (_) => themeManager.toggle(),
            ),
          ),
          // 帮助与反馈
          _settingCard(
            icon: Icons.help_outline,
            title: l10n.helpFeedback,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Icon(Icons.chevron_right, color: arrowColor, size: 20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpFeedbackPage()),
            ),
          ),
          // 服务条款
          _settingCard(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Icon(Icons.chevron_right, color: arrowColor, size: 20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
            ),
          ),
          // 隐私政策
          _settingCard(
            icon: Icons.shield_outlined,
            title: l10n.privacyPolicy,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Icon(Icons.chevron_right, color: arrowColor, size: 20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          // 推送通知
          _settingCard(
            icon: Icons.notifications_outlined,
            title: l10n.pushNotifications,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Icon(Icons.chevron_right, color: arrowColor, size: 20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
          // 检查更新
          _settingCard(
            icon: Icons.system_update_outlined,
            title: l10n.firmwareUpdate,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Icon(Icons.chevron_right, color: arrowColor, size: 20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FirmwareUpdatePage()),
            ),
          ),
          // 关于THL
          _settingCard(
            icon: Icons.info_outline,
            title: l10n.aboutThl,
            cardColor: cardColor,
            isDark: isDark,
            trailing: Icon(Icons.chevron_right, color: arrowColor, size: 20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),
        ],
      ),
    );
  }

  /// 独立卡片容器：[图标, 12px间距, 文字, Spacer, 右侧控件/箭头]
  Widget _settingCard({
    required IconData icon,
    required String title,
    required Color cardColor,
    required bool isDark,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final textColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Color(0x204A90E2), blurRadius: 16, offset: Offset(0, 8)),
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4A90E2), size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              const Spacer(),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  /// 语言切换按钮组：中文 | English
  Widget _languageToggle(AppLocalizations l10n) {
    final isEnglish = l10n.isEnglish;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _langChip('中文', !isEnglish, () {
          if (isEnglish) _switchLanguage('zh');
        }),
        const SizedBox(width: 4),
        _langChip('English', isEnglish, () {
          if (!isEnglish) _switchLanguage('en');
        }),
      ],
    );
  }

  Widget _langChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A90E2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? null
              : Border.all(color: const Color(0xFFA0AEC0), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFFA0AEC0),
          ),
        ),
      ),
    );
  }

  Future<void> _switchLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
    AppLocalizationsController.setLocale(code);
  }
}
