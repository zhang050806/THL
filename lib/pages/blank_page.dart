import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [BlankPage] 通用空白占位页面。
/// 用于尚未实现的功能入口，显示页面标题和一个居中的待办图标。
class BlankPage extends StatelessWidget {
  /// [title] 页面标题（显示在 Header 和居中文本中）
  final String title;

  const BlankPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: title, onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction,
                        size: 64,
                        color: isDark
                            ? const Color(0xFF8B949E)
                            : const Color(0xFFA0AEC0)),
                    const SizedBox(height: 16),
                    Text(
                      l10n.comingSoon,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF8B949E)
                            : const Color(0xFFA0AEC0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF8B949E)
                            : const Color(0xFFA0AEC0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
