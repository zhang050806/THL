// Flutter Widget 冒烟测试 — 验证主组件能否正常渲染
import 'package:flutter_test/flutter_test.dart';

import 'package:xiaozhi_app/main.dart';
import 'package:xiaozhi_app/theme/theme_manager.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async { // 冒烟测试：验证主组件能否正常构建渲染
    await tester.pumpWidget(XiaozhiApp(themeManager: ThemeManager()));
    await tester.pump();
  });
}
