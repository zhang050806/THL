import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/content_widget.dart';
import '../i18n/app_localizations.dart';

/// [HomePage] 首页。
/// 从上到下排列：HeaderWidget → ContentWidget 内容区。
/// 是最主要的用户交互页面。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderWidget(),
            // 内容区：灵活缩放，占据剩余空间并内部滚动
            Expanded(child: ContentWidget()),
          ],
        ),
      ),
    );
  }
}
