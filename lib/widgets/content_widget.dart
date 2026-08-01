import 'dart:math';
import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../pages/create_agent_page.dart';

/// [ContentWidget] 首页核心内容组件。
/// 展示语音助手互动区：用户语音输入 + AI 笑脸动画 + 创建智能体入口。
class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          // ---- AI 笑脸动画区 ----
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF161B22)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFF58A6FF).withOpacity(0.15)
                      : const Color(0xFF4A90E2).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(120, 120),
                // 自定义画笔绘制动态笑脸（动画由 Timer 控制 rebuild）
                painter: _SmileyPainter(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---- 创建智能体入口 ----
          const SizedBox(height: 8),
          Text(
            l10n.tapToCreateAgent,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateAgentPage(),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome, size: 24),
              label: Text(
                l10n.createAgent,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// [_SmileyPainter] AI 笑脸自定义画笔。
/// 绘制一个眨眼的圆形笑脸，作为语音助手的形象表示。
class _SmileyPainter extends CustomPainter {
  /// 随机数生成器：用于随机控制眨眼效果
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF4A90E2);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. 绘制圆形脸部轮廓
    canvas.drawCircle(center, radius, paint);

    // 2. 绘制眼睛：两段弧线（模拟眯眼笑）
    final eyeRadius = radius * 0.12;
    const eyeGap = 8.0;
    _drawArc(canvas, Offset(center.dx - 20, center.dy - 10), eyeRadius,
        pi * 1.1, pi * 1.9, paint); // 左眼弧线
    _drawArc(canvas, Offset(center.dx + 20, center.dy - 10), eyeRadius,
        pi * 1.1, pi * 1.9, paint); // 右眼弧线

    // 3. 绘制嘴巴：上翘弧线（微笑）
    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF4A90E2);
    _drawArc(
        canvas,
        Offset(center.dx, center.dy + 14),
        16,
        pi * 0.15,
        pi * 0.85,
        mouthPaint);
  }

  /// 绘制弧线的辅助方法。
  /// [center] 圆心位置
  /// [radius] 弧线半径
  /// [startAngle] 起始角（弧度）
  /// [endAngle] 结束角（弧度）
  void _drawArc(Canvas canvas, Offset center, double radius,
      double startAngle, double endAngle, Paint paint) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, endAngle - startAngle, false, paint);
  }

  /// 不应重绘：笑脸不需要频繁刷新（静态绘制）。
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
