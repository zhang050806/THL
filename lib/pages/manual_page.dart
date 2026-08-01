import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';
import 'manual_content.dart';

/// [ManualPage] THL MagCharge 无线充电站说明书页面。
/// 根据 App 当前语言自动切换中 / 英文版本。
class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = _isEnglish(context);
    final l10n = AppLocalizations.of(context);
    final List<ManualPageData> pages =
        isEnglish ? ManualContent.pagesEn : ManualContent.pagesZh;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(
                title: l10n.manualTitle,
                onBack: () => Navigator.pop(context)),
            Expanded(
              // 使用 InteractiveViewer 包裹说明书内容，支持两指缩放
              child: InteractiveViewer(
                // 最小缩放比例锁定为原始大小，避免缩得过小
                minScale: 1.0,
                // 最大缩放比例，允许放大到 3 倍查看细节
                maxScale: 3.0,
                // 说明书内容列表
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final isLast = index == pages.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      child: _buildPage(pages[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 判断当前语言是否为英文。
  bool _isEnglish(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en';
  }

  /// 构建单页：全宽高清渲染，保留原始排版。
  Widget _buildPage(ManualPageData page) {
    return Image.asset(
      page.assetPath,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined,
                  size: 36, color: Color(0xFF999999)),
              SizedBox(height: 8),
              Text('图片加载失败',
                  style: TextStyle(color: Color(0xFF999999))),
            ],
          ),
        ),
      ),
    );
  }
}
