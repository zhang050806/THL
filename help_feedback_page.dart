import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../widgets/header_widget.dart';
import 'manual_page.dart';
import 'faq_troubleshooting_page.dart';
import 'faq_shopping_page.dart';
import 'warranty_policy_page.dart';
import 'feedback_page.dart';

/// [HelpFeedbackPage] 帮助与反馈页面。
/// 包含说明书和反馈问题两个入口，支持中英文国际化。
class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: l10n.helpFeedback, onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  _buildSectionTitle(l10n.helpSection, isDark),
                  _card(
                    isDark: isDark,
                    child: _listItem(
                      icon: Icons.menu_book_outlined,
                      title: l10n.manualTitle,
                      isDark: isDark,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ManualPage())),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 故障排查入口
                  _card(
                    isDark: isDark,
                    child: _listItem(
                      icon: Icons.build_outlined,
                      title: l10n.troubleshooting,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const FaqTroubleshootingPage())),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 购物常见问题解答入口
                  _card(
                    isDark: isDark,
                    child: _listItem(
                      icon: Icons.help_outline,
                      title: l10n.shoppingFaq,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FaqShoppingPage())),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 保修政策入口
                  _card(
                    isDark: isDark,
                    child: _listItem(
                      icon: Icons.policy_outlined,
                      title: l10n.warrantyPolicy,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const WarrantyPolicyPage())),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n.feedbackSection, isDark),
                  _card(
                    isDark: isDark,
                    child: _listItem(
                      icon: Icons.feedback_outlined,
                      title: l10n.feedbackProblem,
                      isDark: isDark,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FeedbackPage())),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        '$title   ────────────',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF4A5568),
        ),
      ),
    );
  }

  Widget _card({required Widget child, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(
                    color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(
                    color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(
                    color: Color(0x204A90E2), blurRadius: 16, offset: Offset(0, 8)),
              ],
      ),
      child: child,
    );
  }

  Widget _listItem({
    required IconData icon,
    required String title,
    required bool isDark,
    String? subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF8B949E)
                      : const Color(0xFFA0AEC0)))
          : null,
      trailing: Icon(Icons.chevron_right,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0),
          size: 20),
      onTap: onTap,
    );
  }
}
