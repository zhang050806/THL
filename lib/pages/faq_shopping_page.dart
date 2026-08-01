import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [FaqShoppingPage] 购物常见问题解答页面（7 条）。
/// 展示配送、支付、订单、保修等常见 FAQ，
/// 根据 App 语言自动切换中英文。
class FaqShoppingPage extends StatelessWidget {
  const FaqShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 根据当前语言选择 FAQ 数据
    final List<_FaqItem> faqs = l10n.isEnglish ? _faqsEn : _faqsZh;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 页面标题栏
            PageHeaderWidget(
              title: l10n.shoppingFaq,
              onBack: () => Navigator.pop(context),
            ),
            // FAQ 列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return _buildFaqCard(faq, isDark, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单条 FAQ 卡片：序号圆标 + 问题（加粗） + 答案（正文）。
  Widget _buildFaqCard(_FaqItem faq, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -2)),
                BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: Offset(0, -2)),
                BoxShadow(
                    color: Color(0x204A90E2),
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 序号圆标 + 问题标题
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 序号圆标
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 问题文字（加粗）
              Expanded(
                child: Text(
                  faq.question,
                  style: TextStyle(
                    fontSize: 17,
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
          // 答案文字（正文）
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: isDark
                    ? const Color(0xFFC9D1D9)
                    : const Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 数据模型 ====================

/// FAQ 条目数据模型。
class _FaqItem {
  final String question; // 问题
  final String answer;   // 答案

  const _FaqItem({required this.question, required this.answer});
}

// ==================== 中文 FAQ（7 条） ====================

/// 中文 FAQ 数据（共 7 条）。
const List<_FaqItem> _faqsZh = [
  _FaqItem(
    question: '配送到哪些地区？',
    answer:
        '目前配送至以下国家：\n'
        '- 北美：美国（阿拉斯加、夏威夷等偏远地区除外；波多黎各、关岛等海外地址除外；APO/FPO 军事地址除外。）\n'
        '- 欧洲：奥地利、比利时、保加利亚、捷克、丹麦（法罗群岛、格陵兰除外）、芬兰、法国（海外领土和省份除外）、德国、希腊、匈牙利、爱尔兰、意大利（利维尼奥和坎皮奥内除外）、荷兰（海外领土除外）、挪威、波兰、葡萄牙、罗马尼亚、西班牙（休达/梅利利亚、加那利群岛除外）、瑞典、土耳其、英国（英属印度洋领地、英属维尔京群岛等除外）。\n'
        '- 中东：阿联酋、沙特阿拉伯、卡塔尔',
  ),
  _FaqItem(
    question: '支持哪些支付方式？',
    answer:
        '目前支持 PayPal、信用卡和 Klarna 分期付款。请注意，结账时显示的价格和货币为最终价格，已包含所有费用。THL 不收取任何额外交易费用。但如果您使用国际信用卡或借记卡，由于汇率波动，账单显示金额可能有所不同。此外，您的银行或发卡机构可能收取外币兑换费用，从而影响购物总成本。如需了解与支付相关的任何费用，建议直接联系您的银行或发卡机构。',
  ),
  _FaqItem(
    question: '何时能收到订单？',
    answer:
        '通常您会在购买页面看到预计发货信息。配送时间取决于您所在地区的可选配送方式。订单发货后，配送时间为 3-7 个工作日。',
  ),
  _FaqItem(
    question: '如何追踪订单？',
    answer:
        '请在 thl.com.cn 上访问"我的订单"页面，选择要追踪的订单并点击"查看订单"。',
  ),
  _FaqItem(
    question: 'THL 产品的保修政策是什么？',
    answer:
        'THL 官网（thl.com.cn）购买的设备的官方保修政策如下：\n'
        '欧盟商店：设备 12 个月，配件 12 个月。',
  ),
  _FaqItem(
    question: '价格是否含税？',
    answer: '是的，价格已含税。',
  ),
  _FaqItem(
    question: '退货和退款流程是怎样的？',
    answer: '请联系 support@thl.com.cn 获取直接支持。',
  ),
];

// ==================== 英文 FAQ（7 条） ====================

/// 英文 FAQ 数据（共 7 条）。
const List<_FaqItem> _faqsEn = [
  _FaqItem(
    question: 'Where does the product ship to?',
    answer:
        'Currently, we ship to the following countries:\n'
        '- North America: United States (Except for remote areas such as Alaska and Hawaii; overseas addresses such as Puerto Rico and Guam; APO/FPO military addresses.)\n'
        '- Europe: Austria, Belgium, Bulgaria, Czech Republic, Denmark (Except for the Faroe Islands, Greenland), Finland, France (Except for the Overseas territories and departments), Germany, Greece, Hungary, Ireland, Italy (Except for the Livigno and Campione d\'Italia), Netherlands (Except for the Overseas territories), Norway, Poland, Portugal, Romania, Spain (Except for the Ceuta/Melilla, Canary Islands), Sweden, Turkey, and the United Kingdom (Except for the British Indian Ocean Territory, British Virgin Islands, etc.).\n'
        '- Middle East: United Arab Emirates, Saudi Arabia, Qatar',
  ),
  _FaqItem(
    question: 'What payment methods do we accept?',
    answer:
        'We currently accept payments through PayPal, Credit Cards, and Klarna installments. Please note that the prices and currencies displayed during checkout are final and inclusive of all charges. THL does not impose any additional transaction fees. However, if you are using an international credit or debit card, the price shown on your card statement may differ due to fluctuating exchange rates. Additionally, your bank or card issuer may apply foreign conversion charges and fees, which could impact the total cost of your purchase. For more information about any fees associated with your payment, we recommend contacting your bank or card issuer directly.',
  ),
  _FaqItem(
    question: 'When will I receive my order?',
    answer:
        'Normally, you will get estimated dispatch info on the purchase page. Shipping times depend on the shipping method available in your region. Once your order has been dispatched, the shipping time is 3-7 business days.',
  ),
  _FaqItem(
    question: 'How do I track my order?',
    answer:
        'To track your order, visit the "My orders" page on thl.com.cn. Select the order you want to track and click on "View Order."',
  ),
  _FaqItem(
    question: 'What is the warranty policy for THL products?',
    answer:
        'The official warranty policy for the THL devices bought from our official website (thl.com.cn) is as follows:\n'
        'EU Store: Device 12 months, Accessory 12 months.',
  ),
  _FaqItem(
    question: 'Is tax included in the price?',
    answer: 'Yes, tax is included in the price.',
  ),
  _FaqItem(
    question: 'What\'s the process for Returns & Refunds?',
    answer: 'Please contact support@thl.com.cn for direct support.',
  ),
];
