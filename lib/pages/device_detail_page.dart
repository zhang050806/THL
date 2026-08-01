import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';
import '../services/bluetooth_service.dart';
import 'light_control_page.dart';
import 'alarm_page.dart';

/// [DeviceDetailPage] 设备详情页。
/// 展示设备基本信息（名称/状态/序列号/固件版本），
/// 并提供闹钟、灯光调节、解除绑定等功能入口。
/// 在线状态通过蓝牙连接状态实时更新；序列号与固件版本在蓝牙连接后自动读取。
class DeviceDetailPage extends StatefulWidget {
  /// [name] 设备名称
  final String name;
  /// [address] 蓝牙 MAC 地址，用于读取设备信息与监控连接状态
  final String? address;

  const DeviceDetailPage({
    super.key,
    required this.name,
    this.address,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

/// [DeviceDetailPage] 状态管理类。
/// 允许在详情页直接编辑设备名称；监听蓝牙连接状态实时更新在线状态、序列号和固件版本。
class _DeviceDetailPageState extends State<DeviceDetailPage> {
  /// 设备名称输入控制器（预填充传入的名称）
  late TextEditingController _nameController;

  /// 当前显示的名称（保存后更新）
  late String _displayName;

  /// 名称是否已修改（与当前显示名称不同）
  bool get _hasChanged => _nameController.text.trim() != _displayName;

  /// 蓝牙连接状态 — 基于 BluetoothService 实时更新
  bool _isBluetoothConnected = false;

  /// 设备序列号（蓝牙连接后读取）
  String _serialNumber = '--';

  /// 固件版本（蓝牙连接后读取）
  String _firmwareVersion = '--';

  /// 蓝牙连接状态监听
  StreamSubscription<BluetoothConnectionState>? _bluetoothStateSub;

  @override
  void initState() {
    super.initState();
    _displayName = widget.name;
    _nameController = TextEditingController(text: widget.name);

    // 检查当前蓝牙连接状态
    _isBluetoothConnected = BluetoothService.isConnected;
    if (_isBluetoothConnected) {
      _fetchDeviceInfo();
    }

    // 监听蓝牙连接状态变化
    _bluetoothStateSub = BluetoothService.connectionStateStream.listen((state) {
      if (!mounted) return;
      final connected = state == BluetoothConnectionState.connected;
      if (connected != _isBluetoothConnected) {
        setState(() {
          _isBluetoothConnected = connected;
          if (!connected) {
            _serialNumber = '--';
            _firmwareVersion = '--';
          }
        });
        if (connected) _fetchDeviceInfo();
      }
    });
  }

  /// 通过蓝牙读取设备序列号与固件版本。
  Future<void> _fetchDeviceInfo() async {
    final addr = widget.address;
    if (addr == null || addr.isEmpty) return;

    final sn = await BluetoothService.readSerialNumber(addr);
    final fw = await BluetoothService.readFirmwareVersion(addr);

    if (mounted) {
      setState(() {
        if (sn != null && sn.isNotEmpty) _serialNumber = sn;
        if (fw != null && fw.isNotEmpty) _firmwareVersion = fw;
      });
    }
  }

  @override
  void dispose() {
    _bluetoothStateSub?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOnline = _isBluetoothConnected;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PageHeaderWidget(title: _displayName, onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 设备信息卡片
                  _buildInfoCard(isOnline, l10n, isDark),
                  const SizedBox(height: 12),
                  // 功能入口列表
                  _buildFunctionList(context, l10n, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设备基本信息卡片。
  /// 包含可编辑名称、在线状态球、序列号、固件版本。
  Widget _buildInfoCard(bool isOnline, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Color(0x204A90E2), blurRadius: 16, offset: Offset(0, 8)),
              ],
      ),
      child: Column(
        children: [
          _buildEditableNameRow(l10n, isDark),
          _infoDivider(isDark),
          _infoRow(l10n.onlineStatus, '', trailing: _statusBadge(isOnline, l10n, isDark), isDark: isDark),
          _infoDivider(isDark),
          _infoRow(l10n.serialNumber, _serialNumber, isDark: isDark),
          _infoDivider(isDark),
          _infoRow(l10n.firmwareVersion, _firmwareVersion, isDark: isDark),
        ],
      ),
    );
  }

  /// 可编辑的设备名称行。
  /// 右侧有保存按钮（蓝色圆形勾号），仅在名称变更后高亮可点击。
  Widget _buildEditableNameRow(AppLocalizations l10n, bool isDark) {
    final changed = _hasChanged;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.deviceName,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 名称文本输入框（右对齐、无边框）
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26)),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: l10n.enterDeviceName,
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0)),
                  ),
                  onChanged: (_) => setState(() {}), // 触发 UI 刷新以更新保存按钮状态
                ),
              ),
              const SizedBox(width: 8),
              // 保存按钮：名称未修改时灰色不可点，修改后蓝色可点
              GestureDetector(
                onTap: changed
                    ? () {
                        setState(() {
                          _displayName = _nameController.text.trim();
                        });
                      }
                    : null,
                child: Tooltip(
                  message: l10n.save,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: changed
                          ? const Color(0xFF4A90E2)
                          : (isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0)),
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 通用信息行。
  /// [label] 左侧标签文字
  /// [value] 右侧值文字（如果 [trailing] 非空则忽略 value）
  /// [trailing] 可选的自定义右侧 Widget
  Widget _infoRow(String label, String value, {Widget? trailing, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0)),
          ),
          trailing ??
              Text(
                value,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26)),
              ),
        ],
      ),
    );
  }

  /// 信息行之间的分割线。
  Widget _infoDivider(bool isDark) {
    return Divider(height: 1,
        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF0F0F5));
  }

  /// 在线状态标志球 + 文案。
  /// 在线为绿色圆点，离线为灰色圆点。
  Widget _statusBadge(bool isOnline, AppLocalizations l10n, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOnline ? l10n.online : l10n.offline,
          style: TextStyle(
            fontSize: 14,
            color: isOnline ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0)),
          ),
        ),
      ],
    );
  }

  /// 构建功能入口列表。
  /// 包含：闹钟、灯光调节、解除绑定。已删除共享设备入口。
  Widget _buildFunctionList(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: isDark
            ? const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
              ]
            : const [
                BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(0, -2)),
                BoxShadow(color: Color(0x204A90E2), blurRadius: 16, offset: Offset(0, 8)),
              ],
      ),
      child: Column(
        children: [
          // 闹钟入口：点击跳转到 AlarmPage
          _funcItem(
              Icons.alarm,
              l10n.scheduledOnOff,
              // 跳转到闹钟设置页面
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AlarmPage())),
              isDark: isDark),
          _funcDivider(isDark),
          // 灯光调节入口
          _funcItem(
              Icons.lightbulb_outline,
              l10n.lightControl,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LightControlPage())), isDark: isDark),
          _funcDivider(isDark),
          // 解除绑定使用红色文字突出警告
          _funcItem(Icons.link_off, l10n.unbind,
              () => _showUnbindDialog(context, l10n),
              textColor: Colors.red, isDark: isDark),
        ],
      ),
    );
  }

  /// 单个功能入口列表项。
  /// [icon] 功能图标
  /// [title] 功能名称
  /// [onTap] 点击回调
  /// [textColor] 文字颜色（默认黑色，解除绑定场景用红色）
  Widget _funcItem(IconData icon, String title, VoidCallback onTap,
      {Color textColor = const Color(0xFF1A1D26), required bool isDark}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
      title: Text(title, style: TextStyle(fontSize: 14,
          color: textColor == const Color(0xFF1A1D26)
              ? (isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26))
              : textColor)),
      trailing: Icon(Icons.chevron_right,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0), size: 20),
      onTap: onTap,
    );
  }

  /// 功能项之间的分割线。
  Widget _funcDivider(bool isDark) {
    return Divider(
        height: 1, indent: 16, endIndent: 16,
        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF0F0F5));
  }

  /// 显示解除绑定确认对话框。
  /// 确认后返回特殊字符串 '__UNBIND__' 通知上层页面移除设备。
  void _showUnbindDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unbind),
        content: Text(l10n.unbindConfirm),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 返回特殊标记，供上层 profile_page 识别并移除设备
              Navigator.pop(context, '__UNBIND__');
            },
            child: Text(l10n.unbindConfirmBtn,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
