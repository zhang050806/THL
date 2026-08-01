/// 闹钟 BLE 通信服务。
///
/// 基于蓝牙 BLE GATT 与设备端 MCU 交换闹钟数据，
/// 实现文档定义的 0xAA 帧协议和 5 条专属闹钟指令。
///
/// 帧格式：| 0xAA | 指令码 | 数据长度 | 数据内容 | 校验和 | 0xBB |
///         | 1B   | 1B     | 1B       | N 字节   | 1B     | 1B   |
///
/// 校验和 = (指令码 + 数据长度 + 数据内容各字节) 累加取低 8 位。

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/alarm_model.dart';

// ============================================================
//  协议常量
// ============================================================

/// 帧头
const int frameHeader = 0xAA;

/// 帧尾
const int frameTail = 0xBB;

/// 设备最大闹钟数量
const int maxAlarmCount = 20;

/// 闹钟指令码
class AlarmCmd {
  static const int addModify = 0x10; // 新增/修改闹钟
  static const int delete = 0x11; // 删除指定闹钟
  static const int reportAll = 0x12; // 设备上报全量闹钟列表
  static const int requestSync = 0x13; // App 请求同步设备当前闹钟
  static const int result = 0x14; // 设备回复执行结果

  /// 状态码含义
  static String resultMessage(int code) {
    switch (code) {
      case 0x00:
        return '操作成功';
      case 0x01:
        return '设备存储空间已满';
      case 0x02:
        return '参数非法';
      default:
        return '未知状态: 0x${code.toRadixString(16)}';
    }
  }

  /// 状态码是否表示成功。
  static bool isSuccess(int code) => code == 0x00;
}

/// 闹钟同步结果。
class AlarmSyncResult {
  final bool success;
  final List<AlarmModel> alarms;
  final String? error;

  const AlarmSyncResult({
    required this.success,
    this.alarms = const [],
    this.error,
  });
}

/// 闹钟操作结果。
class AlarmOpResult {
  final bool success;
  final int statusCode;
  final String message;

  const AlarmOpResult({
    required this.success,
    required this.statusCode,
    required this.message,
  });
}

// ============================================================
//  闹钟 BLE 服务
// ============================================================

/// [AlarmBleService] 闹钟专用 BLE 通信服务。
///
/// 通过 MethodChannel 与 Android/iOS 原生层通信，
/// 原生层负责 BLE GATT 读写，Dart 层负责协议帧的打包/解包。
///
/// 使用方式：
///   1. 通过 [isDeviceConnected] / [connectDevice] 管理 BLE 连接
///   2. 调用 [syncAlarms] 同步设备闹钟列表
///   3. 调用 [sendAlarm] / [deleteAlarm] 操作单条闹钟
class AlarmBleService {
  AlarmBleService._();
  static final AlarmBleService instance = AlarmBleService._();

  static const MethodChannel _channel =
      MethodChannel('com.xiaozhi/alarm_ble');

  // ========================
  //  连接管理
  // ========================

  /// 当前是否已连接到设备 BLE GATT。
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// 连接状态变化流。
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  /// 连接到指定设备（MAC 地址）的 BLE GATT 服务。
  Future<bool> connectDevice(String address) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'connectAlarmDevice',
        {'address': address},
      );
      _isConnected = result ?? false;
      _connectionController.add(_isConnected);
      return _isConnected;
    } catch (_) {
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }

  /// 断开 BLE 连接。
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnectAlarmDevice');
    } catch (_) {}
    _isConnected = false;
    _connectionController.add(false);
  }

  /// 检查设备是否已连接。
  Future<bool> isDeviceConnected() async {
    try {
      _isConnected =
          await _channel.invokeMethod<bool>('isAlarmDeviceConnected') ?? false;
      return _isConnected;
    } catch (_) {
      return false;
    }
  }

  // ========================
  //  帧打包 / 解包
  // ========================

  /// 计算校验和：(指令码 + 数据长度 + 数据内容各字节) 累加取低 8 位。
  static int _calcChecksum(int cmd, int len, List<int> data) {
    int sum = cmd + len;
    for (final b in data) {
      sum += b;
    }
    return sum & 0xFF;
  }

  /// 打包一帧完整数据。
  static Uint8List packFrame(int cmd, List<int> data) {
    final len = data.length;
    final checksum = _calcChecksum(cmd, len, data);
    return Uint8List.fromList([
      frameHeader,
      cmd,
      len,
      ...data,
      checksum,
      frameTail,
    ]);
  }

  /// 校验并解包一帧，返回 (指令码, 数据)。
  /// 校验失败返回 null。
  static (int, List<int>)? unpackFrame(List<int> raw) {
    if (raw.length < 6) return null;
    if (raw[0] != frameHeader || raw.last != frameTail) return null;

    final cmd = raw[1];
    final len = raw[2];
    if (raw.length != 6 + len) return null; // header+cmd+len + data + cs+tail

    final data = raw.sublist(3, 3 + len);
    final expectedCs = _calcChecksum(cmd, len, data);
    final actualCs = raw[3 + len];
    if (expectedCs != actualCs) return null;

    return (cmd, data);
  }

  // ========================
  //  核心操作：发送原始帧
  // ========================

  /// 发送一帧数据并等待设备回复。
  /// 超时时间 1000ms，最多自动重试 2 次。
  Future<AlarmOpResult> _sendFrameWithAck(
    int cmd,
    List<int> data, {
    int timeoutMs = 1000,
    int maxRetries = 2,
  }) async {
    if (!_isConnected) {
      return const AlarmOpResult(
        success: false,
        statusCode: -1,
        message: '设备未连接',
      );
    }

    final frame = packFrame(cmd, data);

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final result = await _channel
            .invokeMethod<Map>('sendAlarmFrame', {
              'data': frame,
              'timeoutMs': timeoutMs,
            })
            .timeout(Duration(milliseconds: timeoutMs + 200));

        if (result != null) {
          final statusCode = result['statusCode'] as int? ?? -1;
          return AlarmOpResult(
            success: AlarmCmd.isSuccess(statusCode),
            statusCode: statusCode,
            message: AlarmCmd.resultMessage(statusCode),
          );
        }
      } on TimeoutException {
        if (attempt < maxRetries) continue;
      } catch (_) {
        if (attempt < maxRetries) continue;
      }
    }

    return const AlarmOpResult(
      success: false,
      statusCode: -1,
      message: '设备暂时无响应，请检查蓝牙连接',
    );
  }

  // ========================
  //  闹钟同步
  // ========================

  /// 从设备同步全量闹钟列表。
  ///
  /// 流程：
  ///   1. 发送 0x13 请求同步
  ///   2. 等待设备回复 0x12（全量闹钟列表）
  ///   3. 解析返回闹钟列表
  Future<AlarmSyncResult> syncAlarms() async {
    if (!_isConnected) {
      return const AlarmSyncResult(
        success: false,
        error: '设备未连接',
      );
    }

    try {
      // 发送同步请求 (0x13, 空数据)
      final requestFrame = packFrame(AlarmCmd.requestSync, []);

      final result = await _channel
          .invokeMethod<Map>('requestAlarmSync', {
            'data': requestFrame,
            'timeoutMs': 3000,
          })
          .timeout(const Duration(milliseconds: 3500));

      if (result == null || result['data'] == null) {
        return const AlarmSyncResult(
          success: false,
          error: '设备无响应',
        );
      }

      // 解析 0x12 回复：每 6 字节一条闹钟
      final rawData = List<int>.from(result['data'] as List);
      final alarms = <AlarmModel>[];
      for (int i = 0; i + 6 <= rawData.length; i += 6) {
        try {
          alarms.add(AlarmModel.fromBytes(rawData.sublist(i, i + 6)));
        } catch (_) {}
      }

      return AlarmSyncResult(success: true, alarms: alarms);
    } on TimeoutException {
      return const AlarmSyncResult(
        success: false,
        error: '同步超时，设备无响应',
      );
    } catch (e) {
      return AlarmSyncResult(
        success: false,
        error: '同步失败: $e',
      );
    }
  }

  // ========================
  //  闹钟增/改
  // ========================

  /// 新增或修改一条闹钟到设备（指令 0x10）。
  ///
  /// 传入的 [alarm] 包含完整 6 字节数据。
  /// 返回操作结果。
  Future<AlarmOpResult> sendAlarm(AlarmModel alarm) async {
    return _sendFrameWithAck(AlarmCmd.addModify, alarm.toBytes());
  }

  // ========================
  //  闹钟删除
  // ========================

  /// 删除指定 ID 的闹钟（指令 0x11）。
  Future<AlarmOpResult> deleteAlarm(int alarmId) async {
    return _sendFrameWithAck(AlarmCmd.delete, [alarmId & 0xFF]);
  }

  // ========================
  //  时间同步（RTC 校准）
  // ========================

  /// 将手机系统时间下发给设备 RTC 校准。
  /// 建议在首次蓝牙配对成功后调用。
  ///
  /// 注：时间同步使用现有灯光/时间调节指令，不在此服务中实现。
  /// 如需扩展，可添加专用的时间同步指令。
}
