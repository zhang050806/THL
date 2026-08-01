/// 闹钟数据模型 — 严格按文档方案的 6 字节二进制结构定义。
/// 与设备端 MCU 通过 BLE 交换的闹钟数据格式保持一致。

// ============================================================
//  闹钟触发动作枚举
// ============================================================

/// 闹钟触发时设备执行的动作类型。
enum AlarmAction {
  /// RGB 氛围灯亮起
  rgbLight(0x01),

  /// 启动无线充快充
  wirelessFastCharge(0x02),

  /// 蜂鸣提醒
  buzzer(0x03),

  /// 组合动作（灯光 + 快充 + 蜂鸣）
  combo(0x04);

  final int code;
  const AlarmAction(this.code);

  /// 从协议字节解析动作类型。
  factory AlarmAction.fromCode(int code) {
    for (final v in AlarmAction.values) {
      if (v.code == code) return v;
    }
    return AlarmAction.buzzer; // 未知时默认蜂鸣
  }

  /// 动作的中文名称。
  String get nameZh {
    switch (this) {
      case AlarmAction.rgbLight:
        return 'RGB 氛围灯';
      case AlarmAction.wirelessFastCharge:
        return '无线充快充';
      case AlarmAction.buzzer:
        return '蜂鸣提醒';
      case AlarmAction.combo:
        return '组合动作';
    }
  }

  /// 动作的英文名称。
  String get nameEn {
    switch (this) {
      case AlarmAction.rgbLight:
        return 'RGB Light';
      case AlarmAction.wirelessFastCharge:
        return 'Fast Charge';
      case AlarmAction.buzzer:
        return 'Buzzer';
      case AlarmAction.combo:
        return 'Combo';
    }
  }
}

// ============================================================
//  闹钟数据模型
// ============================================================

/// 单条闹钟的完整数据模型。
///
/// 对应文档定义的 6 字节结构：
/// | 闹钟ID (1B) | 状态 (1B) | 小时 (1B) | 分钟 (1B) | 重复掩码 (1B) | 触发动作 (1B) |
///
/// - [alarmId]: 0~19，设备最多支持 20 组闹钟
/// - [enabled]: true=开启, false=关闭
/// - [hour]: 0~23
/// - [minute]: 0~59
/// - [repeatMask]: 位掩码，bit0(LSB)=周一, bit1=周二, ..., bit6=周日
///   例：工作日(周一到周五) = 0b00011111 = 0x1F
/// - [action]: 触发动作类型，见 [AlarmAction]
class AlarmModel {
  /// 闹钟ID（0~19）
  int alarmId;

  /// 是否启用
  bool enabled;

  /// 小时（0~23）
  int hour;

  /// 分钟（0~59）
  int minute;

  /// 重复掩码（bit0=周一, bit1=周二, ..., bit6=周日）
  /// 例：工作日 0x1F，周末 0x60，每天 0x7F，单次 0x00
  int repeatMask;

  /// 触发动作
  AlarmAction action;

  AlarmModel({
    required this.alarmId,
    this.enabled = true,
    required this.hour,
    required this.minute,
    this.repeatMask = 0x00,
    this.action = AlarmAction.buzzer,
  });

  // ========================
  //  计算属性
  // ========================

  /// 格式化时间为 HH:MM 字符串。
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 是否为单次闹钟（不重复）。
  bool get isOnce => repeatMask == 0x00;

  /// 是否为每天重复。
  bool get isEveryDay => repeatMask == 0x7F;

  /// 是否为仅工作日（周一至周五）。
  bool get isWeekday => repeatMask == 0x1F;

  /// 获取当前闹钟在哪些星期几生效（1=周一, ..., 7=周日）。
  List<int> get activeDays {
    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if ((repeatMask >> i) & 1 == 1) {
        days.add(i + 1);
      }
    }
    return days;
  }

  // ========================
  //  二进制序列化（BLE 通信）
  // ========================

  /// 序列化为 6 字节数据（不含帧头尾和校验）。
  List<int> toBytes() {
    return [
      alarmId & 0xFF,
      enabled ? 0x01 : 0x00,
      hour & 0xFF,
      minute & 0xFF,
      repeatMask & 0xFF,
      action.code & 0xFF,
    ];
  }

  /// 从 6 字节数据反序列化。
  factory AlarmModel.fromBytes(List<int> bytes) {
    if (bytes.length < 6) {
      throw ArgumentError('闹钟数据至少需要 6 字节，实际收到 ${bytes.length} 字节');
    }
    return AlarmModel(
      alarmId: bytes[0],
      enabled: bytes[1] == 0x01,
      hour: bytes[2],
      minute: bytes[3],
      repeatMask: bytes[4],
      action: AlarmAction.fromCode(bytes[5]),
    );
  }

  // ========================
  //  JSON 序列化（本地缓存）
  // ========================

  /// 序列化为 JSON Map，用于 SharedPreferences 本地缓存。
  Map<String, dynamic> toJson() => {
        'alarmId': alarmId,
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'repeatMask': repeatMask,
        'action': action.code,
      };

  /// 从 JSON Map 反序列化。
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      alarmId: json['alarmId'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      repeatMask: json['repeatMask'] as int? ?? 0x00,
      action: AlarmAction.fromCode(json['action'] as int? ?? 0x03),
    );
  }

  // ========================
  //  重复规则辅助
  // ========================

  /// 星期几短名称（1=周一, 7=周日），中文。
  static String dayShortZh(int day) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${names[day - 1]}';
  }

  /// 星期几短名称，英文。
  static String dayShortEn(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[day - 1];
  }

  /// 星期几完整名称，中文。
  static String dayFullZh(int day) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[day - 1];
  }

  /// 星期几完整名称，英文。
  static String dayFullEn(int day) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return names[day - 1];
  }

  @override
  String toString() =>
      'AlarmModel(id=$alarmId, ${enabled ? "ON" : "OFF"} $formattedTime, '
      'mask=0x${repeatMask.toRadixString(16).padLeft(2, '0')}, '
      'action=${action.name})';
}
