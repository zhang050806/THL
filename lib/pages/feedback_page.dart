import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../widgets/header_widget.dart';

/// [FeedbackPage] 反馈问题页面。
/// 显示联系邮箱信息，邮箱地址蓝色高亮，支持中英文国际化。
/// 页面结构：Scaffold + SafeArea + Column[PageHeaderWidget, Expanded > 居中内容]
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  /// 联系邮箱地址，中英文共用。
  static const String _email = 'support@thl.com.cn';

  @override
  Widget build(BuildContext context) {
    // 获取当前语言的国际化实例
    final l10n = AppLocalizations.of(context);
    // 获取当前语言下的完整反馈文案
    final fullText = l10n.feedbackContent;
    // 找到邮箱在文案中的起始位置
    final emailIndex = fullText.indexOf(_email);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 页面标题栏：标题 + 返回按钮
            PageHeaderWidget(
              title: l10n.feedbackProblem,
              onBack: () => Navigator.pop(context),
            ),
            // 居中显示反馈说明文字，邮箱蓝色高亮
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: emailIndex >= 0
                      ? Text.rich(
                          // 用 RichText 将邮箱部分蓝色高亮
                          TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                            children: [
                              // 邮箱前面的文字
                              TextSpan(text: fullText.substring(0, emailIndex)),
                              // 邮箱地址 — 蓝色高亮
                              TextSpan(
                                text: _email,
                                style: const TextStyle(
                                  color: Color(0xFF4A90E2), // 蓝色高亮
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // 邮箱后面的文字
                              TextSpan(
                                  text:
                                      fullText.substring(emailIndex + _email.length)),
                            ],
                          ),
                        )
                      : Text(
                          // 兜底：邮箱不在文案中时直接显示原文
                          fullText,
                          style: const TextStyle(fontSize: 15, height: 1.6),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
