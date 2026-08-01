import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../widgets/header_widget.dart';

/// [AboutPage] 关于 THL 页面。
/// 展示 THL Global 品牌介绍、核心理念与三大支柱，支持中英文国际化。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: l10n.aboutThlHeading, onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---- 品牌介绍标题 ----
                  Text(
                    l10n.aboutThlHeading,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFE6EDF3)
                          : const Color(0xFF1A1D26),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ---- 品牌介绍正文 ----
                  Text(
                    l10n.aboutThlIntro,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.8,
                      color: isDark
                          ? const Color(0xFFC9D1D9)
                          : const Color(0xFF4A5568),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ---- 核心理念 ----
                  _sectionTitle(l10n.ourCorePhilosophy, isDark),
                  Text(
                    l10n.techJoyLife,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF58A6FF)
                          : const Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.techJoyLifeDesc,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.8,
                      color: isDark
                          ? const Color(0xFFC9D1D9)
                          : const Color(0xFF4A5568),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- 三大支柱 ----
                  _pillarCard(
                    icon: Icons.auto_awesome,
                    title: l10n.techEmpowers,
                    body: l10n.techEmpowersBody,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _pillarCard(
                    icon: Icons.favorite_border,
                    title: l10n.joyInDetails,
                    body: l10n.joyInDetailsBody,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _pillarCard(
                    icon: Icons.public,
                    title: l10n.forEveryLife,
                    body: l10n.forEveryLifeBody,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),

                  // 底部间距
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [SECTION_TITLE] 分区标题组件。
  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF4A5568),
        ),
      ),
    );
  }

  /// [PILLAR_CARD] 三大支柱卡片组件。
  /// 左侧图标 + 右侧标题和正文。
  Widget _pillarCard({
    required IconData icon,
    required String title,
    required String body,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
          ),
          const SizedBox(width: 14),
          // 右侧文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE6EDF3)
                        : const Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: isDark
                        ? const Color(0xFF8B949E)
                        : const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
