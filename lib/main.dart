import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'i18n/app_localizations.dart';
import 'theme/theme_manager.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/splash_page.dart';

/// [main] 应用入口函数。
/// 初始化本地存储与主题管理器，读取用户语言偏好后启动 App。
Future<void> main() async {
  // 确保 Flutter 引擎初始化完成后再执行异步操作
  WidgetsFlutterBinding.ensureInitialized();
  // 读取保存的语言偏好，默认简体中文
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('app_language');
  // 修复：general_settings_page 保存的是语言码 'zh'/'en'，这里应比对 'en' 而非 'English'
  // 首次安装（saved==null）时默认中文；saved=='en' 时恢复为英文；其他情况回退中文
  AppLocalizationsController.languageCode = saved == 'en' ? 'en' : 'zh';
  // 创建主题管理器（构造函数内会异步加载已保存的主题设置）
  final themeManager = ThemeManager();

  runApp(XiaozhiApp(themeManager: themeManager));
}

/// [XiaozhiApp] 应用根 Widget。
/// 负责全局配置：主题、多语言、Material 样式。
class XiaozhiApp extends StatefulWidget {
  /// [themeManager] 全局主题管理器实例，控制亮色/暗色模式切换。
  final ThemeManager themeManager;
  const XiaozhiApp({super.key, required this.themeManager});

  @override
  State<XiaozhiApp> createState() => _XiaozhiAppState();
}

/// [XiaozhiApp] 的状态管理类。
/// 监听语言切换事件，动态重建 MaterialApp 以刷新 UI 文案。
class _XiaozhiAppState extends State<XiaozhiApp> {
  /// 当前语言 Locale，默认取全局语言码。
  Locale _locale = Locale(AppLocalizationsController.languageCode);

  @override
  void initState() {
    super.initState();
    // 注册语言切换回调：当用户在其他页面切换语言时，同步刷新 App
    AppLocalizationsController.onLocaleChanged = (locale) {
      if (mounted) setState(() => _locale = locale);
    };
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.themeManager,
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            title: '小智',
            debugShowCheckedModeBanner: false, // 隐藏调试标签
            locale: _locale,
            supportedLocales: const [Locale('zh'), Locale('en')], // 支持中英双语
            localizationsDelegates: const [
              // 自定义国际化代理
              AppLocalizationsDelegate(),
              // Material 组件国际化
              GlobalMaterialLocalizations.delegate,
              // Widget 组件国际化
              GlobalWidgetsLocalizations.delegate,
              // Cupertino 组件国际化
              GlobalCupertinoLocalizations.delegate,
            ],
            // ---- 亮色主题配置 ----
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFF4A90E2),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4A90E2),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF2F7FD),
              useMaterial3: true,
              fontFamily: 'PingFang SC',
            ),
            // ---- 暗色主题配置 ----
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF4A90E2),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4A90E2),
                primaryContainer: Color(0xFF1A3A5C),
                surface: Color(0xFF1E1E2A),
                onSurface: Color(0xFFE0E0E0),
                onSurfaceVariant: Color(0xFFA0AEC0),
                surfaceContainerHighest: Color(0xFF2A2A3A),
                outline: Color(0xFF2A2A3A),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              useMaterial3: true,
              fontFamily: 'PingFang SC',
            ),
            themeMode: themeManager.themeMode, // 由 ThemeManager 控制当前模式
            home: const SplashPage(), // 开屏动画作为启动首页
          );
        },
      ),
    );
  }
}

/// [MainScreen] 应用主界面（带底部导航栏的根页面）。
/// 包含「首页」「连接」「我的」三个 Tab。
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// [MainScreen] 状态管理类。
/// 维护当前选中的 Tab 索引并渲染对应页面。
class _MainScreenState extends State<MainScreen> {
  /// 当前选中的导航栏索引：0=首页, 1=我的
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const selectedColor = Color(0xFF4A90E2);
    const unselectedColor = Color(0xFFA0AEC0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 底部 Tab 对应的两个主页面
    final List<Widget> pages = [
      HomePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ClipRRect(
        // 统一圆角裁剪，使内层页面与导航栏圆角一致
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: _buildNavBar(l10n, selectedColor, unselectedColor, isDark),
    );
  }

  /// 构建底部导航栏。
  /// 采用毛玻璃效果（BackdropFilter），两个导航项均分空间。
  Widget _buildNavBar(
      AppLocalizations l10n, Color selected, Color unselected, bool isDark) {
    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF161B22) : Colors.white).withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        // 根据亮暗模式使用不同阴影
        boxShadow: isDark
            ? const [
                BoxShadow(color: Color(0x33FFFFFF), blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Color(0x3058A6FF), blurRadius: 16, offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Color(0x204A90E2), blurRadius: 16, offset: Offset(0, 8)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 毛玻璃模糊半径
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.cloud_outlined, Icons.cloud, l10n.navHome, selected, unselected),
              _navItem(1, Icons.settings_outlined, Icons.settings, l10n.navProfile, selected, unselected),
            ],
          ),
        ),
      ),
    );
  }

  /// 单个导航项。
  /// [index] 对应 Tab 索引，选中时切换图标并高亮颜色。
  /// [icon] 未选中状态下显示的图标。
  /// [activeIcon] 选中状态下显示的图标。
  /// [label] 导航项文案。
  Widget _navItem(int index, IconData icon, IconData activeIcon, String label,
      Color selected, Color unselected) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque, // 确保空白区域也能接收点击
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部颜色指示条，选中时显示并有动画
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 24 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? selected : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 8),
            Icon(isSelected ? activeIcon : icon,
                size: 22, color: isSelected ? selected : unselected),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? selected : unselected)),
          ],
        ),
      ),
    );
  }
}
