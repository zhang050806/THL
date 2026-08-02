import 'dart:async';
import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';

/// [ConnectSection] 连接分区组件。
///
/// 从 connect_page 抽取，可直接嵌入任意父页面（如 profile_page）。
/// 包含蓝牙设备搜索卡片 + AI 服务器配置卡片 + 使用教程入口。
class ConnectSection extends StatefulWidget {
  const ConnectSection({super.key});

  @override
  State<ConnectSection> createState() => _ConnectSectionState();
}

class _ConnectSectionState extends State<ConnectSection>
    with WidgetsBindingObserver {
  // ==================== 蓝牙状态 ====================
  bool _bluetoothEnabled = false;
  bool _isScanning = false;

  // 扫描超时定时器（15 秒后自动停止）
  Timer? _scanTimeoutTimer;
  static const int _scanTimeoutSeconds = 15;

  // 是否超时后展示提示
  bool _scanTimedOut = false;

  // ==================== 服务器配置状态 ====================
  final TextEditingController _serverUrlController = TextEditingController();
  static final RegExp _wsUrlRegex = RegExp(r'^wss?://\S+:\d+/\S*$');
  bool _isServerUrlValid = false;

  // ==================== 设备数据 ====================
  final Map<String, Map<String, dynamic>> _allDevices = {};
  String? _connectedAddress;
  String? _connectingAddress;
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
    BluetoothService.stopScan();
    super.dispose();
  }

  void _onServerUrlChanged() {
    final valid = _wsUrlRegex.hasMatch(_serverUrlController.text);
    if (valid != _isServerUrlValid) {
      setState(() => _isServerUrlValid = valid);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isScanning) {
      _stopScan();
    }
  }

  // ==================== 初始化 ====================

  Future<void> _initBluetooth() async {
    final enabled = await BluetoothService.isBluetoothEnabled();
    if (!mounted) return;
    setState(() {
      _bluetoothEnabled = enabled;
    });

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

    await _loadHistoryDevices();
    await _loadPairedDevices();
  }

  // ==================== 设备加载 ====================

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

  Future<void> _loadPairedDevices() async {
    final paired = await BluetoothService.getPairedDevices();
    if (!mounted) return;
    for (final d in paired) {
      final addr = d['address'] as String? ?? '';
      if (addr.isEmpty) continue;
      if (_allDevices.containsKey(addr)) {
        _allDevices[addr]!['isPaired'] = true;
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

  void _startScan() {
    _deviceEventsSub?.cancel();
    _scanTimeoutTimer?.cancel();
    _scanTimedOut = false;
    _allDevices.removeWhere((_, v) => !v['isPaired'] && !v['fromHistory']);
    setState(() => _isScanning = true);

    _deviceEventsSub = BluetoothService.deviceEvents.listen(
      _onDeviceEvent,
      onError: (_) {
        if (mounted) setState(() => _isScanning = false);
      },
    );

    BluetoothService.startScan().then((started) {
      if (!started && mounted) {
        setState(() => _isScanning = false);
      }
    });

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

    _setupAutoConnect();
  }

  void _onDeviceEvent(Map<String, dynamic> data) {
    if (!mounted) return;

    if (data['event'] == 'scan_finished') {
      setState(() => _isScanning = false);
      return;
    }

    final name = data['name'] as String? ?? '';
    final address = data['address'] as String? ?? '';
    final rssi = data['rssi'] as int? ?? -100;
    if (address.isEmpty) return;

    String resolvedName = name;
    if (name.isEmpty || _looksLikeMacAddress(name)) {
      final pairedName = _allDevices[address]?['name'] as String?;
      if (pairedName != null &&
          pairedName.isNotEmpty &&
          !_looksLikeMacAddress(pairedName)) {
        resolvedName = pairedName;
      }
    }

    if (!resolvedName.toUpperCase().startsWith('THL')) return;

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

    if (_autoConnectTarget != null && address == _autoConnectTarget) {
      _performAutoConnect(address, _allDevices[address]!['name'] as String);
    }
  }

  bool _looksLikeMacAddress(String s) {
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$').hasMatch(s);
  }

  void _stopScan() {
    _scanTimeoutTimer?.cancel();
    _deviceEventsSub?.cancel();
    BluetoothService.stopScan();
    setState(() => _isScanning = false);
  }

  // ==================== 自动连接 ====================

  Future<void> _setupAutoConnect() async {
    final lastAddr = await BluetoothService.getLastConnectedAddress();
    if (lastAddr == null || lastAddr.isEmpty) return;

    if (_allDevices.containsKey(lastAddr)) {
      _performAutoConnect(
        lastAddr,
        _allDevices[lastAddr]!['name'] as String? ?? lastAddr,
      );
    } else {
      _autoConnectTarget = lastAddr;
    }
  }

  Future<void> _performAutoConnect(String address, String name) async {
    _autoConnectTarget = null;
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
      if (i < _maxAutoConnectRetries - 1) {
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    }
    _connectingAddress = null;
    if (mounted) setState(() {});
  }

  // ==================== 连接操作 ====================

  Future<void> _toggleConnection(String address, String name) async {
    if (_connectingAddress == address) return;

    if (_connectedAddress == address) {
      await BluetoothService.disconnectDevice(address);
      if (mounted) setState(() {});
    } else {
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
    }
  }

  // ==================== 辅助方法 ====================

  List<MapEntry<String, Map<String, dynamic>>> get _sortedDevices {
    final entries = _allDevices.entries.toList();
    entries.sort((a, b) {
      final aConn = a.key == _connectedAddress;
      final bConn = b.key == _connectedAddress;
      if (aConn != bConn) return aConn ? -1 : 1;
      final aPaired = a.value['isPaired'] == true;
      final bPaired = b.value['isPaired'] == true;
      if (aPaired != bPaired) return aPaired ? -1 : 1;
      final aRssi = a.value['rssi'] != null;
      final bRssi = b.value['rssi'] != null;
      if (aRssi != bRssi) return aRssi ? -1 : 1;
      if (aRssi && bRssi) {
        return (b.value['rssi'] as int).compareTo(a.value['rssi'] as int);
      }
      return 0;
    });
    return entries;
  }

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBluetoothCard(l10n, isDark),
        const SizedBox(height: 16),
        _buildServerConfigCard(l10n, isDark),
      ],
    );
  }

  /// 蓝牙设备卡片。
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

  /// 卡片头部：蓝牙图标 + 标题 + 搜索按钮。
  Widget _buildCardHeader(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      child: Row(
        children: [
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
          Text(
            l10n.connectBluetoothDevices,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1A1D26),
            ),
          ),
          const Spacer(),
          _buildSearchButton(l10n),
        ],
      ),
    );
  }

  /// 搜索/停止按钮。
  Widget _buildSearchButton(AppLocalizations l10n) {
    if (_isScanning) {
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

  /// 卡片内容区：根据状态显示不同内容。
  Widget _buildCardContent(AppLocalizations l10n, bool isDark) {
    if (!_bluetoothEnabled) {
      return _buildBluetoothOffState(l10n, isDark);
    }
    if (_isScanning && _allDevices.isEmpty) {
      return _buildScanningState(l10n);
    }
    if (_scanTimedOut && _allDevices.isEmpty) {
      return _buildScanTimeoutState(l10n);
    }
    if (_allDevices.isEmpty) {
      return _buildNoDeviceHint(l10n);
    }
    return _buildDeviceListContent(l10n, isDark);
  }

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
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFE6EDF3)),
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
                color: isConnected
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF3B82F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFE6EDF3)
                          : const Color(0xFF1A1D26),
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
                          color: isDark
                              ? const Color(0xFF8B949E)
                              : const Color(0xFFA0AEC0),
                        ),
                      ),
                      if (isPaired) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
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
                        Icon(Icons.signal_cellular_alt,
                            size: 10, color: _rssiColor(rssi)),
                        const SizedBox(width: 2),
                        Text(
                          '${rssi}dBm',
                          style:
                              TextStyle(fontSize: 9, color: _rssiColor(rssi)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
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

  /// 卡片底部：使用教程链接。
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
                const Icon(Icons.help_outline,
                    size: 16, color: Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 服务器配置卡片 ====================

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
                    color: isDark
                        ? const Color(0xFFE6EDF3)
                        : const Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF0D1117) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF30363D)
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    child: TextField(
                      controller: _serverUrlController,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFC9D1D9)
                            : const Color(0xFF1A1D26),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 11),
                        hintText: 'ws://192.168.1.100:8000/xiaozhi/v1/',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF8B949E)
                              : const Color(0xFF9CA3AF),
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
