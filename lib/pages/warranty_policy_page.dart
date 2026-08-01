import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [WarrantyPolicyPage] 保修政策页面。
/// 展示退货、损坏、换货、退款等保修政策，根据 App 语言自动切换中英文。
class WarrantyPolicyPage extends StatelessWidget {
  const WarrantyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 获取当前语言的政策板块数据
    final List<_PolicySection> sections =
        l10n.isEnglish ? _sectionsEn : _sectionsZh;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 页面标题栏
            PageHeaderWidget(
              title: l10n.warrantyPolicy,
              onBack: () => Navigator.pop(context),
            ),
            // 政策板块列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return _buildSectionCard(sections[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个政策板块卡片，包含板块标题和正文内容。
  Widget _buildSectionCard(_PolicySection section, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
                    color: Color(0x204A90E2),
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 板块标题
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFE6EDF3)
                        : const Color(0xFF1A1D26),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 板块正文
          Text(
            section.body,
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              color: isDark
                  ? const Color(0xFFC9D1D9)
                  : const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}

/// 政策板块数据模型。
class _PolicySection {
  final String title; // 板块标题
  final String body;  // 板块正文

  const _PolicySection({required this.title, required this.body});
}

/// 中文保修政策板块（共 6 个板块）。
const List<_PolicySection> _sectionsZh = [
  _PolicySection(
    title: '退货',
    body: '我们提供 30 天退货政策，即您可在收到商品后 30 天内申请退货。退货商品须保持与收货时相同的状态，未经穿戴或使用，附有标签及原包装，同时需提供收据或购买凭证。如需发起退货，请联系 support@thl.com.cn。请注意，退货需寄送至以下地址：[INSERT RETURN ADDRESS]。若退货申请获批，我们将向您发送退货运输标签及寄送说明。未经申请直接寄回的商品将不予受理。如有任何退货问题，可随时联系 support@thl.com.cn。',
  ),
  _PolicySection(
    title: '损坏与问题',
    body: '请在收到订单后立即检查，如发现商品有缺陷、损坏或收到错误商品，请立即联系我们，以便我们评估问题并妥善处理。',
  ),
  _PolicySection(
    title: '例外 / 不可退货商品',
    body: '部分商品不可退货，包括易腐商品（如食品、鲜花或植物）、定制产品（如特殊订单或个性化商品）以及个人护理用品（如美容产品）。此外，危险品、易燃液体或气体也不接受退货。如有关于特定商品的疑问，请联系我们。很抱歉，特价商品和礼品卡不予退货。',
  ),
  _PolicySection(
    title: '换货',
    body: '获取所需商品的最快方式是退回现有商品，退货获批后再另行购买新商品。',
  ),
  _PolicySection(
    title: '欧盟 14 天冷静期',
    body: '尽管有上述规定，若商品发往欧盟地区，您有权在 14 天内以任何理由无条件取消或退回订单。同样，退货商品须保持收货时状态，未经穿戴或使用，附有标签及原包装，并需提供收据或购买凭证。',
  ),
  _PolicySection(
    title: '退款',
    body: '收到并检查退货后，我们将通知您退款是否获批。若获批，退款将在 10 个工作日内自动退回原支付方式。请注意，银行或信用卡公司处理退款可能需要一定时间。若退款获批超过 15 个工作日仍未到账，请联系 support@thl.com.cn。',
  ),
];

/// 英文保修政策板块（共 6 个板块）。
const List<_PolicySection> _sectionsEn = [
  _PolicySection(
    title: 'Returns',
    body: 'We have a 30-day return policy, which means you have 30 days after receiving your item to request a return. To be eligible for a return, your item must be in the same condition that you received it, unworn or unused, with tags, and in its original packaging. You\'ll also need the receipt or proof of purchase. To start a return, you can contact us at support@thl.com.cn. Please note that returns will need to be sent to the following address: [INSERT RETURN ADDRESS]. If your return is accepted, we\'ll send you a return shipping label, as well as instructions on how and where to send your package. Items sent back to us without first requesting a return will not be accepted. You can always contact us for any return question at support@thl.com.cn.',
  ),
  _PolicySection(
    title: 'Damages and issues',
    body: 'Please inspect your order upon reception and contact us immediately if the item is defective, damaged or if you receive the wrong item, so that we can evaluate the issue and make it right.',
  ),
  _PolicySection(
    title: 'Exceptions / non-returnable items',
    body: 'Certain types of items cannot be returned, like perishable goods (such as food, flowers, or plants), custom products (such as special orders or personalized items), and personal care goods (such as beauty products). We also do not accept returns for hazardous materials, flammable liquids, or gases. Please get in touch if you have questions or concerns about your specific item. Unfortunately, we cannot accept returns on sale items or gift cards.',
  ),
  _PolicySection(
    title: 'Exchanges',
    body: 'The fastest way to ensure you get what you want is to return the item you have, and once the return is accepted, make a separate purchase for the new item.',
  ),
  _PolicySection(
    title: 'European Union 14 day cooling off period',
    body: 'Notwithstanding the above, if the merchandise is being shipped into the European Union, you have the right to cancel or return your order within 14 days, for any reason and without a justification. As above, your item must be in the same condition that you received it, unworn or unused, with tags, and in its original packaging. You\'ll also need the receipt or proof of purchase.',
  ),
  _PolicySection(
    title: 'Refunds',
    body: 'We will notify you once we\'ve received and inspected your return, and let you know if the refund was approved or not. If approved, you\'ll be automatically refunded on your original payment method within 10 business days. Please remember it can take some time for your bank or credit card company to process and post the refund too. If more than 15 business days have passed since we\'ve approved your return, please contact us at support@thl.com.cn.',
  ),
];
