import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [NotificationPage] 推送通知页面。
/// 当前为静态占位页面，展示空状态：铃铛图标 + "暂无通知"文案。
/// 页面框架保持 Scaffold + SafeArea + PageHeaderWidget，支持中英文切换。
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取当前语言的本地化文案
    final l10n = AppLocalizations.of(context);
    // 判断是否为暗色模式，用于适配颜色
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 背景色跟随主题
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 页面顶部 Header，标题为"推送通知"
            PageHeaderWidget(
              title: l10n.pushNotifications,
              onBack: () => Navigator.pop(context),
            ),
            // 空状态内容区域，居中展示
            Expanded(
              child: Center(
                child: Column(
                  // 内容垂直居中，占用最小空间
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 铃铛图标作为空状态视觉元素
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 72,
                      color: isDark
                          ? const Color(0xFF8B949E)
                          : const Color(0xFFA0AEC0),
                    ),
                    const SizedBox(height: 20),
                    // "暂无通知"文案（通过 l10n 支持中英文切换）
                    Text(
                      l10n.noNotifications,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
