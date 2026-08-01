import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [CreateAgentPage] 创建智能体占位页面。
/// 功能尚未实现，跳转到通用 BlankPage 展示占位内容。
class CreateAgentPage extends StatelessWidget {
  const CreateAgentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: l10n.createAgent, onBack: () => Navigator.pop(context)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction, size: 64,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0)),
                    const SizedBox(height: 16),
                    Text(l10n.comingSoon,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0))),
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
