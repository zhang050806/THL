import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';

/// [HeaderWidget] 首页顶部 Header 组件。
/// 展示系统当前日期与每日问候语。
class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

/// [HeaderWidget] 状态管理类。
/// 从系统获取当前日期，并在 App 恢复前台时自动刷新。
class _HeaderWidgetState extends State<HeaderWidget> with WidgetsBindingObserver {
  /// 当前日期时间对象，用于动态格式化（中/英文）。
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App 从后台回到前台时刷新日期。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDate();
    }
  }

  /// 更新当前时间对象并触发 UI 重建。
  void _refreshDate() {
    setState(() {
      _now = DateTime.now();
    });
  }

  /// 根据语言环境动态格式化日期字符串。
  /// 中文：2026年7月26日 周日
  /// English：Sunday, July 26, 2026
  String _formatDate(bool isEnglish) {
    // 中文星期数组
    final zhWeekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    // 英文星期数组
    final enWeekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    // 英文月份数组
    final enMonths = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    if (isEnglish) {
      return '${enWeekDays[_now.weekday - 1]}, ${enMonths[_now.month - 1]} ${_now.day}, ${_now.year}';
    } else {
      return '${_now.year}年${_now.month}月${_now.day}日 ${zhWeekDays[_now.weekday - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 获取当前语言环境，用于动态切换日期格式
    final isEnglish = AppLocalizations.of(context).isEnglish;
    final dateText = _formatDate(isEnglish);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      padding: const EdgeInsets.all(14),
      decoration: _headerDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== 第一行：日期（根据语言自动切换中/英文格式） =====
          Text(
            dateText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          // ===== 第二行：每日问候语 =====
          const SizedBox(height: 4),
          Text(
            '让我们度过美好的一天！',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Hello, Let's have a wonderful day!",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}

/// [PageHeaderWidget] 通用子页面 Header 组件。
/// 提供返回按钮、标题文字、右侧可选操作区。
class PageHeaderWidget extends StatelessWidget {
  /// [title] 页面标题
  final String title;
  /// [onBack] 返回按钮回调，为 null 时不显示返回按钮
  final VoidCallback? onBack;
  /// [actions] 右侧操作区 Widget 列表
  final List<Widget>? actions;

  const PageHeaderWidget({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _headerDecoration(isDark),
      child: Row(
        children: [
          // 返回按钮：仅当 onBack 不为 null 时显示
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios,
                      size: 16, color: Color(0xFF4A90E2)),
                  SizedBox(width: 2),
                  Text(
                    '返回',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (onBack != null) const SizedBox(width: 8),
          // 标题文字（超出省略）
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 右侧操作区
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

/// 共享的 Header 装饰样式函数。
/// 返回统一的圆角毛玻璃背景 + 自适应双色投影。
/// [isDark] 是否为暗色模式，用于调整背景色和阴影颜色。
BoxDecoration _headerDecoration(bool isDark) {
  return BoxDecoration(
    color: (isDark ? const Color(0xFF161B22) : Colors.white).withOpacity(0.92),
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    boxShadow: isDark
        ? const [
            BoxShadow(
                color: Color(0x33FFFFFF),
                blurRadius: 8,
                offset: Offset(0, -2)),
            BoxShadow(
                color: Color(0x3058A6FF),
                blurRadius: 16,
                offset: Offset(0, 8)),
          ]
        : const [
            BoxShadow(
                color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
            BoxShadow(
                color: Color(0x204A90E2),
                blurRadius: 16,
                offset: Offset(0, 8)),
          ],
  );
}
