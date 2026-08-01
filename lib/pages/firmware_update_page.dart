import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

// ============================================================
// 固件检查更新页面（静态展示）
// ============================================================

/// [FirmwareUpdatePage] 固件检查更新页面。
///
/// 纯静态页面，无任何网络请求与交互。
/// 展示内容：图标 + 产品名与版本号 + 「已是最新版本」提示。
class FirmwareUpdatePage extends StatelessWidget {
  const FirmwareUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 页面顶部标题栏
            PageHeaderWidget(
                title: l10n.firmwareUpdate,
                onBack: () => Navigator.pop(context)),
            // 主体内容：垂直居中
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 检查更新图标（大号，蓝色）
                    const Icon(
                      Icons.system_update,
                      size: 64,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 20),
                    // 产品名 + 版本号
                    Text(
                      'THLxiaozhi 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFE6EDF3)
                            : const Color(0xFF1A1D26),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 已是最新版本提示（灰色小字）
                    Text(
                      l10n.alreadyLatestVersion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
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
