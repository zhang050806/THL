import 'dart:async';
import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';

/// [ConnectPage] 蓝牙连接页面。
///
/// 模拟手机系统蓝牙设置的交互体验：
/// - 读取已配对设备、扫描附近 BLE 设备、合并历史设备
/// - 每个设备右侧显示连接状态（已连接/未连接）
/// - 进入页面自动连接上次设备
/// - 点击已连接设备断开，点击未连接设备发起连接
class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> with WidgetsBindingObserver {
  // ==================== 蓝牙状态 ====================
  bool _bluetoothEnabled = false;
  bool _isScanning = false;

  // 扫描超时定时器（15 秒后自动停止）
  Timer? _scanTimeoutTimer;
  static const int _scanTimeoutSeconds = 15;

  // 是否超时后展示提示
  bool _scanTimedOut = false;

  // ==================== 服务器配置状态 ====================
  /// 服务器地址输入控制器。
  final TextEditingController _serverUrlController = TextEditingController();

  /// WebSocket URL 格式正则：ws:// 或 wss:// 开头。
  static final RegExp _wsUrlRegex = RegExp(r'^wss?://\S+:\d+/\S*$');

  /// 当前输入的服务器地址是否合法。
  bool _isServerUrlValid = false;

  // ==================== 设备数据 ====================
  /// 合并后的设备列表（已配对 + 扫描发现 + 历史记录），按 MAC 去重。
  /// key: MAC 地址, value: { name, address, rssi, isPaired, fromHistory }
  final Map<String, Map<String, dynamic>> _allDevices = {};

  /// 当前已连接设备的 MAC 地址。
  String? _connectedAddress;

  /// 是否正在执行连接操作（用于防重复点击）。
  String? _connectingAddress;

  /// 自动连接的目标 MAC 地址（用于扫描回调中匹配）。
  String? _autoConnectTarget;

  static const int _maxAutoConnectRetries = 3;

  // ==================== 订阅 ====================
  StreamSubscription<Map<String, dynamic>>? _deviceEventsSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;

  // ==================== 生命周期 ====================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBluetooth();
    _serverUrlController.addListener(_onServerUrlChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimeoutTimer?.cancel();
    _deviceEventsSub?.cancel();
    _connStateSub?.cancel();
    _serverUrlController.removeListener(_onServerUrlChanged);
    _serverUrlController.dispose();
    // 退出页面时立即停止扫描
    BluetoothService.stopScan();
    super.dispose();
  }

  void _onServerUrlChanged() {
    final valid = _wsUrlRegex.hasMatch(_serverUrlController.text);
    if (valid != _isServerUrlValid) {
      setState(() => _isServerUrlValid = valid);
    }
  }

  /// 应用生命周期回调：切后台时立即停止扫描。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isScanning) {
      _stopScan();
    }
  }

  // ==================== 初始化 ====================

  Future<void> _initBluetooth() async {
    // 1. 检查蓝牙状态
    final enabled = await BluetoothService.isBluetoothEnabled();
    if (!mounted) return;
    setState(() {
      _bluetoothEnabled = enabled;
    });

    // 2. 订阅连接状态变化
    _connStateSub = BluetoothService.connectionStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state == BluetoothConnectionState.disconnected) {
          _connectedAddress = null;
          _connectingAddress = null;
        } else if (state == BluetoothConnectionState.connected) {
          _connectedAddress = BluetoothService.connectedAddress;
          _connectingAddress = null;
        }
      });
    });

    // 3. 加载历史设备（StorageService 中持久化的设备列表）
    await _loadHistoryDevices();

    // 4. 加载系统已配对设备
    await _loadPairedDevices();

    // App 启动阶段不自动扫描，用户需点击搜索按钮手动触发
  }

  // ==================== 设备加载 ====================

  /// 从 StorageService 加载已连接过的历史设备。
  Future<void> _loadHistoryDevices() async {
    final devices = await StorageService.instance.getDeviceList();
    if (!mounted) return;
    for (final d in devices) {
      final addr = d['address'] as String? ?? '';
      if (addr.isEmpty) continue;
      if (!_allDevices.containsKey(addr)) {
        _allDevices[addr] = {
          'name': d['name'] as String? ?? addr,
          'address': addr,
          'rssi': null,
          'isPaired': false,
          'fromHistory': true,
        };
      }
    }
    if (mounted) setState(() {});
  }

  /// 读取系统已配对的蓝牙设备。
  Future<void> _loadPairedDevices() async {
    final paired = await BluetoothService.getPairedDevices();
    if (!mounted) return;
    for (final d in paired) {
      final addr = d['address'] as String? ?? '';
      if (addr.isEmpty) continue;
      if (_allDevices.containsKey(addr)) {
        _allDevices[addr]!['isPaired'] = true;
        // 已配对设备名称优先
        final n = d['name'] as String?;
        if (n != null && n.isNotEmpty) {
          _allDevices[addr]!['name'] = n;
        }
      } else {
        _allDevices[addr] = {
          'name': d['name'] as String? ?? addr,
          'address': addr,
          'rssi': null,
          'isPaired': true,
          'fromHistory': false,
        };
      }
    }
    if (mounted) setState(() {});
  }

  // ==================== 蓝牙扫描 ====================

  /// 开始 BLE 扫描（用户点击搜索按钮触发）。
  /// 使用 15 秒超时自动停止，防止持续耗电。
  void _startScan() {
    _deviceEventsSub?.cancel();
    _scanTimeoutTimer?.cancel();
    _scanTimedOut = false;
    _allDevices.removeWhere((_, v) => !v['isPaired'] && !v['fromHistory']);
    setState(() => _isScanning = true);

    // 订阅设备发现事件
    _deviceEventsSub = BluetoothService.deviceEvents.listen(
      _onDeviceEvent,
      onError: (_) {
        if (mounted) setState(() => _isScanning = false);
      },
    );

    // 启动扫描
    BluetoothService.startScan().then((started) {
      if (!started && mounted) {
        setState(() => _isScanning = false);
      }
    });

    // 15 秒超时自动停止
    _scanTimeoutTimer = Timer(Duration(seconds: _scanTimeoutSeconds), () {
      if (!mounted) return;
      _stopScan();
      setState(() => _scanTimedOut = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).connectScanTimeoutSnackbar),
          backgroundColor: const Color(0xFFF59E0B),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    // 设置自动连接目标
    _setupAutoConnect();
  }

  /// 处理设备发现事件。
  void _onDeviceEvent(Map<String, dynamic> data) {
    if (!mounted) return;

    // 扫描完成
    if (data['event'] == 'scan_finished') {
      setState(() => _isScanning = false);
      return;
    }

    // 新发现的设备
    final name = data['name'] as String? ?? '';
    final address = data['address'] as String? ?? '';
    final rssi = data['rssi'] as int? ?? -100;

    if (address.isEmpty) return;

    // 解析设备名称：如果原生层返回了 MAC 地址兜底值，尝试从已配对/历史设备中查找真实名称
    String resolvedName = name;
    if (name.isEmpty || _looksLikeMacAddress(name)) {
      final pairedName = _allDevices[address]?['name'] as String?;
      if (pairedName != null && pairedName.isNotEmpty && !_looksLikeMacAddress(pairedName)) {
        resolvedName = pairedName;
      }
    }

    // THL 设备过滤：仅保留名称以 THL 开头的设备（忽略大小写）
    if (!resolvedName.toUpperCase().startsWith('THL')) return;

    // 合并到设备列表
    if (_allDevices.containsKey(address)) {
      _allDevices[address]!['rssi'] = rssi;
      if (resolvedName.isNotEmpty) _allDevices[address]!['name'] = resolvedName;
    } else {
      _allDevices[address] = {
        'name': resolvedName.isNotEmpty ? resolvedName : address,
        'address': address,
        'rssi': rssi,
        'isPaired': false,
        'fromHistory': false,
      };
    }
    setState(() {});

    // 自动连接：检测到目标设备
    if (_autoConnectTarget != null && address == _autoConnectTarget) {
      _performAutoConnect(address, _allDevices[address]!['name'] as String);
    }
  }

  /// 判断字符串是否形如 MAC 地址（如 "DC:F0:90:62:F3:38"）。
  bool _looksLikeMacAddress(String s) {
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$').hasMatch(s);
  }

  /// 停止扫描。
  void _stopScan() {
    _scanTimeoutTimer?.cancel();
    _deviceEventsSub?.cancel();
    BluetoothService.stopScan();
    setState(() => _isScanning = false);
  }

  // ==================== 自动连接 ====================

  /// 设置自动连接：读取上次连接设备地址，若在已加载设备中则立即尝试连接，
  /// 否则标记为目标地址等待扫描发现。
  Future<void> _setupAutoConnect() async {
    final lastAddr = await BluetoothService.getLastConnectedAddress();
    if (lastAddr == null || lastAddr.isEmpty) return;

    // 检查是否已在设备列表中（已配对/历史）
    if (_allDevices.containsKey(lastAddr)) {
      _performAutoConnect(
        lastAddr,
        _allDevices[lastAddr]!['name'] as String? ?? lastAddr,
      );
    } else {
      // 标记为目标，等待扫描发现
      _autoConnectTarget = lastAddr;
    }
  }

  /// 静默连接指定设备，失败自动重试（最多 3 次，间隔递增）。
  Future<void> _performAutoConnect(String address, String name) async {
    _autoConnectTarget = null; // 防止重复触发
    _connectingAddress = address;

    for (int i = 0; i < _maxAutoConnectRetries; i++) {
      final success = await BluetoothService.connectDevice(
        address,
        name: name,
        silent: true,
      );
      if (success) {
        if (mounted) setState(() {});
        return;
      }
      // 静默重试，间隔递增
      if (i < _maxAutoConnectRetries - 1) {
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    }
    _connectingAddress = null;
    if (mounted) setState(() {});
  }

  // ==================== 连接操作 ====================

  /// 点击设备：已连接则断开，未连接则连接。
  Future<void> _toggleConnection(String address, String name) async {
    if (_connectingAddress == address) return; // 防重复点击

    if (_connectedAddress == address) {
      // 已连接 → 断开
      await BluetoothService.disconnectDevice(address);
      if (mounted) setState(() {});
    } else {
      // 未连接 → 连接
      setState(() => _connectingAddress = address);
      final success = await BluetoothService.connectDevice(
        address,
        name: name,
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).connectFailed(name),
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _connectingAddress = null);
      }
    }
  }

  // ==================== 蓝牙开关 ====================

  Future<void> _enableBluetooth() async {
    final success = await BluetoothService.enableBluetooth();
    if (mounted) {
      setState(() => _bluetoothEnabled = success);
      // 开启蓝牙后不自动扫描，由用户手动触发
    }
  }

  // ==================== 辅助方法 ====================

  /// 设备列表排序：已连接最前 → 已配对 → 有信号强度 → 历史设备。
  List<MapEntry<String, Map<String, dynamic>>> get _sortedDevices {
    final entries = _allDevices.entries.toList();
    entries.sort((a, b) {
      // 1. 已连接排最前
      final aConn = a.key == _connectedAddress;
      final bConn = b.key == _connectedAddress;
      if (aConn != bConn) return aConn ? -1 : 1;
      // 2. 已配对优先
      final aPaired = a.value['isPaired'] == true;
      final bPaired = b.value['isPaired'] == true;
      if (aPaired != bPaired) return aPaired ? -1 : 1;
      // 3. 有 RSSI（扫描到）优先于纯历史
      final aRssi = a.value['rssi'] != null;
      final bRssi = b.value['rssi'] != null;
      if (aRssi != bRssi) return aRssi ? -1 : 1;
      // 4. RSSI 降序
      if (aRssi && bRssi) {
        return (b.value['rssi'] as int).compareTo(a.value['rssi'] as int);
      }
      return 0;
    });
    return entries;
  }

  /// 根据信号强度返回颜色。
  Color _rssiColor(int rssi) {
    final pct = ((rssi + 100) / 70 * 100).clamp(0, 100).toInt();
    if (pct > 60) return const Color(0xFF22C55E);
    if (pct > 30) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBluetoothCard(l10n, isDark),
            const SizedBox(height: 16),
            _buildServerConfigCard(l10n, isDark),
          ],
        ),
      ),
    );
  }

  /// 蓝牙设备卡片：圆角深色卡片，包含头部、内容区和底部教程链接。
  Widget _buildBluetoothCard(AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(l10n, isDark),
          _buildCardContent(l10n, isDark),
          _buildTutorialLink(l10n),
        ],
      ),
    );
  }

  /// 卡片头部：蓝色蓝牙图标 + "蓝牙设备"标题（左），搜索按钮（右）。
  Widget _buildCardHeader(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      child: Row(
        children: [
          // 蓝色蓝牙图标容器
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bluetooth,
              color: Color(0xFF3B82F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          // 标题
          Text(
            l10n.connectBluetoothDevices,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
            ),
          ),
          const Spacer(),
          // 搜索/停止按钮
          _buildSearchButton(l10n),
        ],
      ),
    );
  }

  /// 卡片头部右侧：搜索/停止按钮。
  Widget _buildSearchButton(AppLocalizations l10n) {
    if (_isScanning) {
      // 扫描中 → 停止按钮
      return GestureDetector(
        onTap: _stopScan,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.connectStopScan,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    // 空闲 → 搜索按钮
    return GestureDetector(
      onTap: _startScan,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, size: 16, color: Color(0xFF3B82F6)),
          const SizedBox(width: 4),
          Text(
            l10n.connectSearchDevice,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 卡片内容区：根据蓝牙和设备状态显示不同内容。
  Widget _buildCardContent(AppLocalizations l10n, bool isDark) {
    // 蓝牙未开启
    if (!_bluetoothEnabled) {
      return _buildBluetoothOffState(l10n, isDark);
    }

    // 扫描中且无设备
    if (_isScanning && _allDevices.isEmpty) {
      return _buildScanningState(l10n);
    }

    // 扫描超时仍无设备
    if (_scanTimedOut && _allDevices.isEmpty) {
      return _buildScanTimeoutState(l10n);
    }

    // 始终无设备（未曾扫描过）
    if (_allDevices.isEmpty) {
      return _buildNoDeviceHint(l10n);
    }

    // 有设备 → 设备列表
    return _buildDeviceListContent(l10n, isDark);
  }

  /// 蓝牙未开启状态。
  Widget _buildBluetoothOffState(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 48,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.connectBluetoothOff,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _enableBluetooth,
            icon: const Icon(Icons.bluetooth, size: 18),
            label: Text(l10n.connectEnableBluetooth),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 扫描中状态。
  Widget _buildScanningState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.connectScanning,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }

  /// 无设备提示（初始状态，用户尚未扫描）。
  Widget _buildNoDeviceHint(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bluetooth_searching,
            color: Color(0xFF8B949E),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.connectTapToSearch,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }

  /// 扫描超时状态：15 秒未发现设备。
  Widget _buildScanTimeoutState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.signal_wifi_statusbar_connected_no_internet_4,
            color: Color(0xFFF59E0B),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.connectNoThlDevice,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFE6EDF3)),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.connectScanTimeoutHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }

  /// 设备列表内容（卡片内）。
  Widget _buildDeviceListContent(AppLocalizations l10n, bool isDark) {
    final devices = _sortedDevices;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: devices.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 48,
        endIndent: 12,
        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF0F0F5),
      ),
      itemBuilder: (context, index) {
        final entry = devices[index];
        return _buildDeviceRow(entry.key, entry.value, l10n, isDark);
      },
    );
  }

  /// 设备列表行：左侧图标+名称+MAC，右侧连接状态。
  Widget _buildDeviceRow(
    String address,
    Map<String, dynamic> device,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final name = device['name'] as String? ?? address;
    final rssi = device['rssi'] as int?;
    final isPaired = device['isPaired'] == true;
    final isConnecting = _connectingAddress == address;
    final isConnected = _connectedAddress == address;

    // 连接状态文字和颜色
    String statusText;
    Color statusColor;
    if (isConnecting) {
      statusText = l10n.connecting;
      statusColor = const Color(0xFFF59E0B);
    } else if (isConnected) {
      statusText = l10n.connected;
      statusColor = const Color(0xFF22C55E);
    } else {
      statusText = l10n.connectNotConnected;
      statusColor = isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0);
    }

    return InkWell(
      onTap: isConnecting ? null : () => _toggleConnection(address, name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // 左侧：设备图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isConnected
                    ? const Color(0xFF22C55E).withOpacity(0.12)
                    : const Color(0xFF3B82F6).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: isConnected ? const Color(0xFF22C55E) : const Color(0xFF3B82F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            // 中间：设备名称 + 副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFFA0AEC0),
                        ),
                      ),
                      if (isPaired) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            l10n.connectPaired,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (rssi != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.signal_cellular_alt, size: 10, color: _rssiColor(rssi)),
                        const SizedBox(width: 2),
                        Text(
                          '${rssi}dBm',
                          style: TextStyle(fontSize: 9, color: _rssiColor(rssi)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 右侧：连接状态
            if (isConnecting)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFF59E0B),
                ),
              )
            else
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 卡片底部：使用教程链接（靠右对齐）。
  Widget _buildTutorialLink(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2A2D35), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: 打开使用教程页面
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.connectTutorial,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.help_outline, size: 16, color: Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 服务器配置卡片 ====================

  /// 服务器配置卡片：AI 服务器地址输入 + 连接按钮。
  Widget _buildServerConfigCard(AppLocalizations l10n, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题行：紫色 AI 图标 + "AI服务器配置"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.connectAiServerConfig,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ),
          // 副标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.connectAiServerHint,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF9CA3AF),
              ),
            ),
          ),
          // 地址输入框 + 连接按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF30363D) : const Color(0xFFD1D5DB),
                      ),
                    ),
                    child: TextField(
                      controller: _serverUrlController,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF1A1D26),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        hintText: 'ws://192.168.1.100:8000/xiaozhi/v1/',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF9CA3AF),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isServerUrlValid
                        ? () {
                            // TODO: 连接服务器逻辑
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isServerUrlValid ? primaryColor : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.connectBtn,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
