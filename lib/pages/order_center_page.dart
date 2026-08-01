import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [OrderCenterPage] 购买页面。
/// 展示 THL 产品列表和订单功能入口，支持中英文国际化。
class OrderCenterPage extends StatelessWidget {
  const OrderCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: l10n.purchase, onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // ---- 产品卡片列表 ----
                  _productCard(
                    name: l10n.thlMagCharge7in1Name,
                    price: '\$79.99',
                    features: [
                      l10n.featureMagCharge1,
                      l10n.featureMagCharge2,
                      l10n.featureMagCharge3,
                      l10n.featureMagCharge4,
                      l10n.featureMagCharge5,
                      l10n.featureMagCharge6,
                    ],
                    imageUrl:
                        'https://cdn.shopify.com/s/files/1/0746/3324/9016/files/1200.jpg?v=1782962406',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _productCard(
                    name: l10n.thl65wAdapterName,
                    price: '\$39.00',
                    features: [
                      l10n.featureAdapter1,
                      l10n.featureAdapter2,
                      l10n.featureAdapter3,
                      l10n.featureAdapter4,
                    ],
                    imageUrl:
                        'https://cdn.shopify.com/s/files/1/0746/3324/9016/files/fKlR9piKO.jpg?v=1770538159',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),

                  // ---- 订单操作入口 ----
                  _sectionTitle(l10n.orderManagement, isDark),
                  const SizedBox(height: 10),
                  _orderActionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: l10n.myOrders,
                    subtitle: l10n.viewAllOrders,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [SECTION_TITLE] 分区标题。
  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
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

  /// [PRODUCT_CARD] 产品展示卡片（左右布局）。
  /// 左侧图片 + 右侧名称/价格/特性列表。
  Widget _productCard({
    required String name,
    required String price,
    required List<String> features,
    required String imageUrl,
    required bool isDark,
  }) {
    return Container(
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左侧产品图片
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 120,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: isDark
                        ? const Color(0xFF21262D)
                        : const Color(0xFFF0F0F5),
                    child: const Icon(Icons.image_not_supported,
                        size: 32, color: Color(0xFFA0AEC0)),
                  ),
                ),
              ),
            ),
            // 右侧产品信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 产品名称
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFE6EDF3)
                            : const Color(0xFF1A1D26),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 价格
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 特性列表
                    ...features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.check_circle_outline,
                                  size: 12, color: Color(0xFF22C55E)),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: isDark
                                      ? const Color(0xFFC9D1D9)
                                      : const Color(0xFF4A5568),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  /// [ORDER_ACTION_CARD] 订单操作入口卡片。
  Widget _orderActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0),
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0),
            size: 20),
      ),
    );
  }
}
