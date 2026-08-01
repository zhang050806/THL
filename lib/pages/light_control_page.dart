import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

/// [LightControlPage] 灯光调节页面（重写版）。
/// 包含两个独立灯光区域：
/// - 时钟灯光：iOS 风格纵向滑块，底部=关闭(0%)，顶部=最亮(100%)
///   - 拖动时实时显示当前百分比
///   - 松手时按吸附规则动画滑动到目标位置（200ms 缓动）
/// - 底座灯光：4 档预设（白光 / 黄光 / 黄白混合 / 关闭）
class LightControlPage extends StatefulWidget {
  const LightControlPage({super.key});

  @override
  State<LightControlPage> createState() => _LightControlPageState();
}

/// [LightControlPage] 状态管理类。
/// 维护时钟灯光亮度值和底座灯光档位，使用 setState 更新 UI。
/// 使用 AnimationController 实现松手后吸附动画。
class _LightControlPageState extends State<LightControlPage>
    with TickerProviderStateMixin {
  /// 时钟灯光亮度值：0.0（关闭）~ 1.0（最亮）
  double _clockBrightness = 0.0;

  /// 底座灯光档位索引：
  /// 0 = 白光, 1 = 黄光, 2 = 黄白混合, 3 = 关闭
  int _baseLightIndex = 3;

  /// 吸附动画控制器，用于松手后平滑过渡到吸附位置
  late AnimationController _snapController;

  /// 上一次吸附动画的监听回调引用，用于在新建动画前移除旧监听
  VoidCallback? _snapListener;

  /// 检查是否有任何灯光处于开启状态。
  bool get _anyLightOn => _clockBrightness > 0 || _baseLightIndex != 3;

  @override
  void initState() {
    super.initState();
    // 初始化吸附动画控制器，200ms 缓动
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  // =========================
  //  吸附规则
  // =========================
  /// 根据吸附规则计算松手后的目标亮度值：
  /// - 0~25%（含25）：吸附到 0%（关闭）
  /// - 25~50%（含50）：吸附到 50%
  /// - 50~75%（不含50，即 >50 且 ≤75）：吸附到 50%
  /// - 75~100%：吸附到 100%（最亮）
  double _snapTarget(double value) {
    if (value <= 0.25) return 0.0;
    if (value <= 0.75) return 0.5;
    return 1.0;
  }

  /// 用户松手时触发：计算吸附目标位置，使用 AnimationController
  /// 驱动 _clockBrightness 从当前值平滑动画到目标值（200ms easeOut）。
  void _onDragEnd(double value) {
    final target = _snapTarget(value);
    // 如果已经非常接近目标位置，无需动画
    if ((target - _clockBrightness).abs() < 0.001) return;

    final startValue = _clockBrightness;

    // 移除上一次的监听回调（避免旧监听残留导致值跳变）
    if (_snapListener != null) {
      _snapController.removeListener(_snapListener!);
    }

    // 动画监听：根据动画进度插值更新亮度值
    _snapListener = () {
      setState(() {
        _clockBrightness =
            startValue + (target - startValue) * _snapController.value;
      });
    };

    _snapController
      ..reset()
      ..addListener(_snapListener!);
    _snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏（带返回按钮）
            PageHeaderWidget(
              title: l10n.lightControl,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),
                  // ===== 灯光状态展示卡片 =====
                  _buildStatusCard(l10n),
                  const SizedBox(height: 24),
                  // ===== 时钟灯光 + 底座灯光：左右并排布局 =====
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 左侧：时钟灯光卡片（iOS 风格纵向滑块）
                        Expanded(
                          flex: 1,
                          child: _buildClockLightCard(l10n),
                        ),
                        const SizedBox(width: 12),
                        // 右侧：底座灯光卡片
                        Expanded(
                          flex: 1,
                          child: _buildBaseLightCard(l10n),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  //  灯光状态展示卡片
  // =========================
  /// 顶部展示卡片：灯泡图标 + 当前状态文字。
  /// 有灯光开启时使用暖色渐变，关闭时使用灰色渐变。
  Widget _buildStatusCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // 根据是否有灯光开启决定渐变颜色
          colors: _anyLightOn
              ? [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)]
              : [Theme.of(context).colorScheme.outline, const Color(0xFFCBD5E1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 灯泡图标：开启状态实心，关闭状态轮廓
          Icon(
            _anyLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
            size: 56,
            color: _anyLightOn
                ? const Color(0xFFFFB300)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          // 状态文字
          Text(
            _anyLightOn ? l10n.lightOn : l10n.lightOff,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _anyLightOn
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          // 副标题
          Text(
            _anyLightOn ? l10n.currentBrightness : '',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  //  时钟灯光卡片 — iOS 风格纵向滑块 + 吸附动画
  // =========================
  /// 时钟灯光纵向滑块：
  /// - RotatedBox + Slider 实现纵向滑动（iOS 风格）
  /// - 拖动时实时显示当前百分比
  /// - 松手后按吸附规则动画滑动到目标位置
  /// - 底部=关闭(0%)，顶部=最亮(100%)
  Widget _buildClockLightCard(AppLocalizations l10n) {
    // 当前实时百分比（拖动过程中也会更新）
    final percent = (_clockBrightness * 100).round();

    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          // 卡片标题
          _sectionTitle(l10n.clockLight),
          const SizedBox(height: 16),
          // 当前百分比显示（拖动过程中实时更新）
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: _clockBrightness > 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          // 纵向滑块区域：顶部标签「亮」、中间滑块、底部标签「暗」
          SizedBox(
            height: 210, // 给滑块和标签足够的纵向空间
            child: Column(
              children: [
                // 顶部标签：亮 / Bright（对应滑块顶端 100%）
                Text(
                  l10n.brightLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                // ===== 纵向滑块（RotatedBox + Slider）=====
                // quarterTurns: 3 = 逆时针 90°，使得视觉上底部=0%、顶部=100%
                Expanded(
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: _clockBrightness,
                        onChanged: (v) {
                          // 拖动过程中实时更新亮度值
                          setState(() => _clockBrightness = v);
                        },
                        // 松手时触发吸附动画
                        onChangeEnd: _onDragEnd,
                        min: 0,
                        max: 1,
                        // 蓝色轨道 + 滑块，与 App 主题一致
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(context).colorScheme.outline,
                        // 滑块拇指颜色
                        thumbColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 底部标签：暗 / Dim（对应滑块底端 0%）
                Text(
                  l10n.darkLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  //  底座灯光卡片 — 4 档预设选择
  // =========================
  /// 底座灯光 4 档预设：白光 / 黄光 / 黄白混合 / 关闭。
  /// 四个圆角按钮纵向排列（从上到下），选中态高亮显示，适配较窄的右侧卡片宽度。
  Widget _buildBaseLightCard(AppLocalizations l10n) {
    // 预设档位数据：颜色、图标颜色、标签文案
    final presets = [
      _BaseLightPreset(
        color: const Color(0xFFF5F7FA),
        dotColor: const Color(0xFFFFFFFF),
        borderColor: Theme.of(context).colorScheme.outline,
        label: l10n.whiteLight,
      ),
      _BaseLightPreset(
        color: const Color(0xFFFFF8E1),
        dotColor: const Color(0xFFFFB300),
        borderColor: const Color(0xFFFFE082),
        label: l10n.yellowLight,
      ),
      _BaseLightPreset(
        color: const Color(0xFFFDF8EE),
        dotColor: const Color(0xFFFFC107),
        borderColor: const Color(0xFFFFE082),
        label: l10n.mixedLight,
      ),
      _BaseLightPreset(
        color: const Color(0xFFF5F5F5),
        dotColor: Theme.of(context).colorScheme.onSurfaceVariant,
        borderColor: Theme.of(context).colorScheme.outline,
        label: l10n.baseLightOff,
      ),
    ];

    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          _sectionTitle(l10n.baseLight),
          const SizedBox(height: 16),
          // 4 个档位纵向排列（从上到下：白光 / 黄光 / 黄白混合 / 关闭）
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(presets.length, (i) {
              final preset = presets[i];
              final isSelected = _baseLightIndex == i;
              return Padding(
                // 档位之间留上下间距
                padding: EdgeInsets.only(
                  top: i == 0 ? 0 : 6,
                  bottom: i == presets.length - 1 ? 0 : 6,
                ),
                child: _buildPresetButton(
                  preset: preset,
                  isSelected: isSelected,
                  onTap: () => setState(() => _baseLightIndex = i),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 单个底座灯光档位按钮。
  /// 选中时显示蓝色边框和浅蓝背景，未选中为浅灰背景。
  Widget _buildPresetButton({
    required _BaseLightPreset preset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          // 选中态：浅蓝背景 + 蓝色边框；未选中：浅灰背景
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 颜色圆点指示器
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: preset.dotColor,
                shape: BoxShape.circle,
                // 圆点加边框，使白色圆点在浅色背景中可见
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                // 圆点加阴影增强立体感
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 档位标签文字
            Text(
              preset.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  //  公共 UI 组件
  // =========================

  /// 白色卡片容器（与现有 App 风格一致）。
  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 区域标题：粗体深色小标题。
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

// =========================
//  数据模型
// =========================

/// [_BaseLightPreset] 底座灯光档位数据模型。
/// 包含卡片背景色、圆点颜色、边框颜色和标签文案。
class _BaseLightPreset {
  /// [color] 卡片默认背景色
  final Color color;
  /// [dotColor] 圆点指示器颜色
  final Color dotColor;
  /// [borderColor] 卡片默认边框颜色
  final Color borderColor;
  /// [label] 档位标签文案（已国际化）
  final String label;

  const _BaseLightPreset({
    required this.color,
    required this.dotColor,
    required this.borderColor,
    required this.label,
  });
}
