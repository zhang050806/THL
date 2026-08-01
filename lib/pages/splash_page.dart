import 'package:flutter/material.dart';
import '../main.dart';

/// [SplashPage] 开屏动画页面。
/// App 启动时显示 2 秒的 THL Logo 缩放动画，然后自动跳转主页。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// 动画控制器：控制缩放动画的播放。
  late final AnimationController _controller;

  /// 缩放动画：从 0.3 倍放大到 1.0 倍，带弹性回弹感。
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 动画时长 2000ms，视觉上从小变大的弹性动画
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 使用 CurvedAnimation 叠加 easeOutBack 缓动曲线，产生弹性回弹效果
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // 动画完成后直接跳转 MainScreen，不再额外停留
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });

    // 立即启动动画，无延迟
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 纯白背景
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: const Text(
            'THL',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              // 深灰色字体，比纯黑稍柔和
              color: Color(0xFF2D2D2D),
              // 字母间距，让三个字母呼吸感更好
              letterSpacing: 4.0,
            ),
          ),
        ),
      ),
    );
  }
}
