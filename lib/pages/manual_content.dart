/// [ManualContent] THL MagCharge 无线充电站说明书内容。
/// 支持中英双语：英文版为 PDF 高清渲染图，中文版为翻译后生成的页面图。

/// [ManualPageData] 单页说明书数据。
class ManualPageData {
  final String assetPath;
  const ManualPageData(this.assetPath);
}

class ManualContent {
  /// 英文标题。
  static const String titleEn = 'THL MagCharge Wireless Charging Station Manual';

  /// 中文标题。
  static const String titleZh = 'THL MagCharge无线充电站说明书';

  /// 英文版页面列表（PDF 原版渲染图，共 10 页）。
  static const List<ManualPageData> pagesEn = [
    ManualPageData('assets/manual_pages/page_01.png'),
    ManualPageData('assets/manual_pages/page_02.png'),
    ManualPageData('assets/manual_pages/page_03.png'),
    // page_04.png（Clock Backlight Touch Pad）和 page_05.png（Nightlight Touch Pad）已移除
    ManualPageData('assets/manual_pages/page_06.png'),
    ManualPageData('assets/manual_pages/page_07.png'),
    ManualPageData('assets/manual_pages/page_08.png'),
    ManualPageData('assets/manual_pages/page_09.png'),
    ManualPageData('assets/manual_pages/page_10.png'),
    ManualPageData('assets/manual_pages/page_11.png'),
    ManualPageData('assets/manual_pages/page_12.png'),
  ];

  /// 中文版页面列表（翻译后渲染图，共 10 页，内容合并后更紧凑）。
  static const List<ManualPageData> pagesZh = [
    ManualPageData('assets/manual_pages_zh/page_01.png'),
    ManualPageData('assets/manual_pages_zh/page_02.png'),
    ManualPageData('assets/manual_pages_zh/page_03.png'),
    // page_04.png（时钟背光触控板）和 page_05.png（夜灯触控板）已移除
    ManualPageData('assets/manual_pages_zh/page_06.png'),
    ManualPageData('assets/manual_pages_zh/page_07.png'),
    ManualPageData('assets/manual_pages_zh/page_08.png'),
    ManualPageData('assets/manual_pages_zh/page_09.png'),
    ManualPageData('assets/manual_pages_zh/page_10.png'),
  ];
}
