import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// 蓝牙连接状态枚举。
enum BluetoothConnectionState { disconnected, connecting, connected }

/// [BluetoothService] 蓝牙设备搜索与连接服务。
/// 通过 MethodChannel / EventChannel 与 Android 原生层通信，
/// 实现 BLE 设备扫描、已配对设备读取、连接管理和前台服务保活。
class BluetoothService {
  /// MethodChannel：向原生层发送蓝牙操作指令
  static const MethodChannel _methodChannel =
      MethodChannel('com.xiaozhi/bluetooth');

  /// EventChannel：接收原生层推送的蓝牙事件（设备发现 / 扫描完成 / 连接变化）
  static const EventChannel _eventChannel =
      EventChannel('com.xiaozhi/bluetooth_events');

  /// 蓝牙事件流，上层 UI 通过监听此流获取实时设备列表。
  static Stream<Map<String, dynamic>>? _eventStream;

  /// SharedPreferences 中存储上次连接设备 MAC 地址的 Key。
  static const String _keyLastConnected = 'last_connected_device';

  // ==================== 连接状态管理 ====================

  /// 当前已连接设备的 MAC 地址，未连接时为 null。
  static String? _connectedAddress;

  /// 连接状态流控制器。
  static final StreamController<BluetoothConnectionState>
      _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();

  /// 连接状态广播流，上层 UI 通过监听此流获取实时连接状态变化。
  static Stream<BluetoothConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// 当前是否已连接蓝牙设备。
  static bool get isConnected => _connectedAddress != null;

  /// 当前已连接设备的 MAC 地址。
  static String? get connectedAddress => _connectedAddress;

  /// 初始化事件流监听，只应调用一次。
  static void init() {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((data) => Map<String, dynamic>.from(data as Map))
        .asBroadcastStream();
    // 同时也监听原生蓝牙事件中的连接/断开通知
    _eventStream?.listen(_onBluetoothEvent);
  }

  /// 处理原生层蓝牙事件（连接/断开）。
  static void _onBluetoothEvent(Map<String, dynamic> data) {
    final event = data['event'] as String?;
    if (event == 'device_connected') {
      _connectedAddress = data['address'] as String?;
      _connectionStateController.add(BluetoothConnectionState.connected);
    } else if (event == 'device_disconnected') {
      _connectedAddress = null;
      _connectionStateController.add(BluetoothConnectionState.disconnected);
    }
  }

  /// 获取蓝牙事件广播流（已过滤：仅保留 THL 前缀设备）。
  static Stream<Map<String, dynamic>> get deviceEvents {
    init();
    return _eventStream!.where((data) {
      final event = data['event'] as String?;
      // 非设备发现事件（scan_finished / 连接状态变更）直接放行
      if (event != 'device_found') return true;
      // 只保留名称以 THL 开头（忽略大小写）的设备
      final name = data['name'] as String? ?? '';
      return name.toUpperCase().startsWith('THL');
    });
  }

  /// 检查设备是否支持蓝牙硬件。
  static Future<bool> isBluetoothAvailable() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isBluetoothAvailable') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// 检查蓝牙是否已开启。
  static Future<bool> isBluetoothEnabled() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isBluetoothEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// 尝试静默开启蓝牙（可能因权限问题失败）。
  static Future<bool> enableBluetooth() async {
    try {
      return await _methodChannel.invokeMethod<bool>('enableBluetooth') ?? false;
    } catch (_) {
      return false;
    }
  }

  // ==================== 已配对设备 ====================

  /// 读取手机系统已配对的蓝牙设备列表。
  /// 返回 List<Map>，每个 Map 包含 'name' (String) 和 'address' (String)。
  /// 原生层需实现 'getPairedDevices' MethodChannel 调用。
  static Future<List<Map<String, dynamic>>> getPairedDevices() async {
    try {
      final result = await _methodChannel.invokeMethod('getPairedDevices');
      if (result is List) {
        return result
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ==================== BLE 扫描 ====================

  /// THL 设备专属 Service UUID（128-bit），用于 BLE 扫描过滤。
  static const String thlServiceUuid = '0000FFE0-0000-1000-8000-00805F9B34FB';

  /// BLE 扫描超时秒数。
  static const int scanTimeoutSeconds = 15;

  /// 扫描完成广播流控制器（用于通知超时/完成）。
  static final StreamController<String> _scanFinishController =
      StreamController<String>.broadcast();

  /// 扫描完成事件流。
  static Stream<String> get scanFinishStream => _scanFinishController.stream;

  /// 开始 BLE 扫描附近的蓝牙设备。
  /// 发现的设备会通过 [deviceEvents] 流实时推送。
  /// 原生层需实现 BLE 扫描逻辑（BluetoothLeScanner.startScan）。
  static Future<bool> startScan() async {
    try {
      return await _methodChannel.invokeMethod<bool>('startScan') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 带 UUID 过滤的 BLE 扫描：仅发现广播指定 Service UUID 的设备。
  /// [serviceUuids] 可选 UUID 列表，传入后原生层应用 ScanFilter。
  /// [timeoutSeconds] 超时秒数，超时后自动调用 stopScan 并推送 scan_finished。
  static Future<bool> startScanWithFilter({
    List<String>? serviceUuids,
    int timeoutSeconds = scanTimeoutSeconds,
  }) async {
    try {
      final uuids = serviceUuids ?? const [thlServiceUuid];
      final args = <String, dynamic>{
        'serviceUuids': uuids,
      };
      final result =
          await _methodChannel.invokeMethod<bool>('startScanWithFilter', args) ??
              false;

      if (result) {
        // 启动超时定时器，防止持续耗电
        Timer(Duration(seconds: timeoutSeconds), () {
          stopScan();
          _scanFinishController.add('timeout');
        });
      }

      return result;
    } catch (e) {
      return false;
    }
  }

  /// 停止扫描。
  static Future<bool> stopScan() async {
    try {
      return await _methodChannel.invokeMethod<bool>('stopScan') ?? false;
    } catch (_) {
      return false;
    }
  }

  // ==================== 轻量定向连接探测 ====================

  /// 对指定设备进行轻量定向连接探测（不做完整连接握手）。
  /// 用于后台保活：每 3 分钟对已配对设备做一次快速可达性检测。
  /// [address] 目标设备 MAC 地址。
  /// 返回 true 表示设备可达，false 表示不可达或探测失败。
  static Future<bool> pingDevice(String address) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'pingDevice',
        {'address': address},
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 对已配对设备列表进行批量轻量可达性探测。
  /// [addresses] 目标设备 MAC 地址列表。
  /// 返回可达设备的 MAC 地址列表。
  static Future<List<String>> pingDevices(List<String> addresses) async {
    final reachable = <String>[];
    for (final addr in addresses) {
      final ok = await pingDevice(addr);
      if (ok) reachable.add(addr);
    }
    return reachable;
  }

  /// 对指定设备启动心跳保活：定期 ping 以维持连接。
  /// [address] 目标设备 MAC 地址。
  /// [intervalSeconds] ping 间隔秒数，默认 180 秒（3 分钟）。
  /// 返回一个 [Timer] 对象，调用方可通过 cancel() 停止保活。
  static Timer startHeartbeat(
    String address, {
    int intervalSeconds = 180,
    void Function(bool alive)? onPingResult,
  }) {
    return Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      final alive = await pingDevice(address);
      onPingResult?.call(alive);
      if (!alive) {
        // 设备不可达，可选触发重连逻辑
        _connectionStateController.add(BluetoothConnectionState.disconnected);
      }
    });
  }

  // ==================== 设备连接 ====================

  /// 连接到指定 MAC 地址的蓝牙设备。
  /// [name] 可选设备名称，连接成功后自动写入 StorageService 设备列表
  /// 并记录为上次连接设备。
  /// [silent] 为 true 时静默连接，失败不触发 disconnected 状态广播。
  static Future<bool> connectDevice(String address, {String? name, bool silent = false}) async {
    try {
      _connectionStateController.add(BluetoothConnectionState.connecting);
      final result = await _methodChannel.invokeMethod<bool>(
            'connectDevice',
            {'address': address},
          ) ??
          false;
      if (result) {
        _connectedAddress = address;
        _connectionStateController.add(BluetoothConnectionState.connected);

        // 记录上次连接的设备地址
        await _setLastConnectedAddress(address);

        // 连接成功后，将设备信息写入 StorageService 持久化设备列表
        if (name != null && name.isNotEmpty) {
          await StorageService.instance.addDevice({
            'name': name,
            'address': address,
            'status': '在线',
            'id': 'DEV-${DateTime.now().millisecondsSinceEpoch}',
          });
        }
      } else {
        if (!silent) {
          _connectedAddress = null;
          _connectionStateController.add(BluetoothConnectionState.disconnected);
        }
      }
      return result;
    } catch (_) {
      if (!silent) {
        _connectedAddress = null;
        _connectionStateController.add(BluetoothConnectionState.disconnected);
      }
      return false;
    }
  }

  /// 断开指定地址设备的蓝牙连接。
  static Future<void> disconnectDevice(String address) async {
    try {
      await _methodChannel.invokeMethod('disconnectDevice', {'address': address});
    } catch (_) {
      // 降级：调用无参 disconnect
      await _methodChannel.invokeMethod('disconnect');
    }
    _connectedAddress = null;
    _connectionStateController.add(BluetoothConnectionState.disconnected);
  }

  /// 断开当前蓝牙连接。
  static Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } catch (_) {}
    _connectedAddress = null;
    _connectionStateController.add(BluetoothConnectionState.disconnected);
  }

  // ==================== 上次连接设备 ====================

  /// 获取上次连接成功的设备 MAC 地址。
  static Future<String?> getLastConnectedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastConnected);
    } catch (_) {
      return null;
    }
  }

  /// 记录上次连接成功的设备 MAC 地址（内部使用）。
  static Future<void> _setLastConnectedAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastConnected, address);
    } catch (_) {}
  }

  /// 清除上次连接记录。
  static Future<void> clearLastConnectedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastConnected);
    } catch (_) {}
  }

  // ==================== 前台服务保活 ====================

  /// 启动前台 Service 进行蓝牙保活。
  /// 通过 MethodChannel 通知原生层启动带通知的前台 Service，
  /// 防止 App 在后台时蓝牙连接被系统杀死。
  /// 原生层需实现 'startForegroundService' MethodChannel 调用。
  static Future<void> startForegroundService() async {
    try {
      await _methodChannel.invokeMethod('startForegroundService');
    } catch (_) {}
  }

  /// 停止前台 Service。
  /// 原生层需实现 'stopForegroundService' MethodChannel 调用。
  static Future<void> stopForegroundService() async {
    try {
      await _methodChannel.invokeMethod('stopForegroundService');
    } catch (_) {}
  }

  // ==================== 设备信息读取 ====================

  /// 通过蓝牙读取设备序列号。
  /// 返回序列号字符串，读取失败返回 null。
  static Future<String?> readSerialNumber(String address) async {
    try {
      return await _methodChannel.invokeMethod<String>(
        'readSerialNumber',
        {'address': address},
      );
    } catch (_) {
      return null;
    }
  }

  /// 通过蓝牙读取设备固件版本。
  /// 返回固件版本字符串，读取失败返回 null。
  static Future<String?> readFirmwareVersion(String address) async {
    try {
      return await _methodChannel.invokeMethod<String>(
        'readFirmwareVersion',
        {'address': address},
      );
    } catch (_) {
      return null;
    }
  }
}
