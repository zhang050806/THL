import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [FaqTroubleshootingPage] 故障排查 FAQ 页面（11 条）。
/// 展示 THL MagCharge 无线充电站的常见故障排查问答，
/// 根据 App 语言自动切换中英文。
class FaqTroubleshootingPage extends StatelessWidget {
  const FaqTroubleshootingPage({super.key});

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
              title: l10n.troubleshooting,
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

// ==================== 中文 FAQ（11 条） ====================

/// 中文 FAQ 数据（共 11 条）。
const List<_FaqItem> _faqsZh = [
  _FaqItem(
    question: '支持哪些无线充电功率？',
    answer: '3W/5W/7.5W/10W/15W/25W',
  ),
  _FaqItem(
    question: '哪些设备可以同时无线充电？',
    answer: '2 部手机、iWatch 和耳机。',
  ),
  _FaqItem(
    question: '如何获得最佳无线充电体验？',
    answer:
        '为获得最佳效果，请使用随附的 65W 或更高功率适配器。避免使用过厚或不具磁吸功能的手机壳。如需使用保护壳，请选择 Apple MagSafe 保护壳。厚度超过 2.5 毫米的保护壳可能会降低充电效率。',
  ),
  _FaqItem(
    question: 'Android 手机的最大无线充电功率是多少？',
    answer:
        '充电器对支持 Qi2.2 25W 的设备最高支持 25W。标准 Qi2 手机最高为 15W。实际功率会因电量水平和充电策略而变化，属正常现象。',
  ),
  _FaqItem(
    question: '如何通过蓝牙同步时间？',
    answer:
        '打开手机蓝牙 → 连接 THL-MC01 → Android 用户须允许消息访问以激活时间同步。',
  ),
  _FaqItem(
    question: '如何切换 12/24 小时制？',
    answer: '屏幕亮度为 50% 时，长按灯光键 8 秒可在 12 小时制和 24 小时制之间切换。',
  ),
  _FaqItem(
    question: '如何切换摄氏度/华氏度？',
    answer: '屏幕亮度为 100% 时，长按灯光键 8 秒可在摄氏度和华氏度之间切换。',
  ),
  _FaqItem(
    question: '显示的是什么温度？',
    answer: '显示的是设备周围的环境温度，不是室外温度或手机温度。',
  ),
  _FaqItem(
    question: '如何控制夜灯？',
    answer: '点击夜灯触摸板切换灯光颜色。长按夜灯触摸板，亮度范围为 10%–100%。',
  ),
  _FaqItem(
    question: '如何调节屏幕亮度？',
    answer: '单击 LED 屏幕触摸板循环切换：100%→50%→0。',
  ),
  _FaqItem(
    question: '有线输出口可以同时使用吗？',
    answer: '可以，Type-C 和 USB-A 均支持 5V/2A 输出。',
  ),
];

// ==================== 英文 FAQ（11 条） ====================

/// 英文 FAQ 数据（共 11 条）。
const List<_FaqItem> _faqsEn = [
  _FaqItem(
    question: 'What wireless charging power does it support?',
    answer: '3W/5W/7.5W/10W/15W/25W',
  ),
  _FaqItem(
    question: 'Which devices can be charged wirelessly at the same time?',
    answer: '2 mobile phones, iWatch, and earbuds.',
  ),
  _FaqItem(
    question: 'How can I achieve the best wireless charging experience?',
    answer:
        'For the best results, use the included 65W or higher adapter. Avoid thick or non-magnetic phone cases. If you use a case, choose an Apple MagSafe case. Cases thicker than 2.5 mm may reduce charging efficiency.',
  ),
  _FaqItem(
    question: 'What is the maximum wireless charging power for Android phones?',
    answer:
        'The charger supports up to 25W for Qi2.2 25W-enabled devices. Standard Qi2 phones max at 15W. Actual power varies with battery level and charging policy, which is normal.',
  ),
  _FaqItem(
    question: 'How to sync time via Bluetooth?',
    answer:
        'Turn on phone Bluetooth → connect to THL-MC01 → Android users must allow message access to activate time sync.',
  ),
  _FaqItem(
    question: 'How to switch 12/24-hour format?',
    answer:
        'When the screen brightness is at 50%, long-press the light key for 8 seconds to switch between 12-hour and 24-hour format.',
  ),
  _FaqItem(
    question: 'How to switch °C/°F?',
    answer:
        'When the screen brightness is at 100%, long-press the light key for 8 seconds to switch between Celsius and Fahrenheit.',
  ),
  _FaqItem(
    question: 'What temperature does it show?',
    answer:
        'It shows ambient temperature around the device, not outdoor or phone temperature.',
  ),
  _FaqItem(
    question: 'How to control the night light?',
    answer:
        'Tap the night light touchpad to switch light colors.\nLong press the night light touchpad; brightness ranges from 10%–100%.',
  ),
  _FaqItem(
    question: 'How to adjust screen brightness?',
    answer:
        'Single tap the LED screen touchpad to cycle: 100%→50%→0.',
  ),
  _FaqItem(
    question: 'Can wired outputs be used simultaneously?',
    answer: 'Yes, both Type-C and USB-A support 5V/2A output.',
  ),
];
