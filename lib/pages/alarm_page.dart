import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/alarm_ble_service.dart';
import '../widgets/header_widget.dart';
import '../i18n/app_localizations.dart';

// ============================================================
//  闹钟页面主体
// ============================================================

/// [AlarmPage] 多闹钟管理页面。
///
/// 按照闹钟方案文档实现：
/// - 闹钟数据按 6 字节结构存储（ID/状态/时/分/重复掩码/动作）
/// - 支持通过 BLE 与设备同步闹钟数据
/// - 本地 SharedPreferences 缓存备份
/// - 最多 20 条闹钟容量限制
class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with WidgetsBindingObserver {
  /// 闹钟列表
  final List<AlarmModel> _alarms = [];

  /// 是否处于编辑模式
  bool _isEditing = false;

  /// 编辑模式下被选中的闹钟索引集合
  final Set<int> _selectedIndices = {};

  /// 是否已从本地存储加载过数据
  bool _loaded = false;

  /// 设备 BLE 连接状态
  bool _bleConnected = false;

  /// 是否正在同步
  bool _isSyncing = false;

  /// 闹钟 BLE 服务实例
  AlarmBleService get _bleService => AlarmBleService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAlarms();
    _checkBleAndSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 从 SharedPreferences 加载闹钟数据（本地缓存）。
  Future<void> _loadAlarms() async {
    final jsonStr = await StorageService.instance.getAlarms();
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        final alarms = list
            .map((e) => AlarmModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() {
            _alarms.clear();
            _alarms.addAll(alarms);
            _loaded = true;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loaded = true);
      }
    } else {
      if (mounted) setState(() => _loaded = true);
    }
  }

  /// 将闹钟列表持久化到 SharedPreferences。
  Future<void> _saveAlarms() async {
    final jsonStr = jsonEncode(_alarms.map((a) => a.toJson()).toList());
    await StorageService.instance.setAlarms(jsonStr);
  }

  /// 检查 BLE 连接状态并尝试同步。
  Future<void> _checkBleAndSync() async {
    final connected = await _bleService.isDeviceConnected();
    if (mounted) {
      setState(() => _bleConnected = connected);
    }
  }

  /// 从设备同步闹钟列表。
  Future<void> _syncFromDevice() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      // 确保已连接
      if (!_bleConnected) {
        final l10n = AppLocalizations.of(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.alarmBleNotConnected)),
          );
        }
        return;
      }

      final result = await _bleService.syncAlarms();
      if (result.success && mounted) {
        setState(() {
          _alarms.clear();
          _alarms.addAll(result.alarms);
        });
        await _saveAlarms();

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.alarmSyncSuccess(result.alarms.length),
            ),
          ),
        );
      } else if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? l10n.alarmSyncFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  /// 下发闹钟到设备。
  Future<bool> _sendAlarmToDevice(AlarmModel alarm) async {
    if (!_bleConnected) return false;
    final result = await _bleService.sendAlarm(alarm);
    return result.success;
  }

  /// 从设备删除闹钟。
  Future<bool> _deleteAlarmFromDevice(int alarmId) async {
    if (!_bleConnected) return false;
    final result = await _bleService.deleteAlarm(alarmId);
    return result.success;
  }

  /// 分配一个未使用的闹钟 ID（0~19）。
  int _allocateAlarmId() {
    final usedIds = _alarms.map((a) => a.alarmId).toSet();
    for (int i = 0; i < maxAlarmCount; i++) {
      if (!usedIds.contains(i)) return i;
    }
    return -1; // 理论上不会到这里（已在外层检查容量）
  }

  // ========================
  //  编辑模式操作
  // ========================

  bool get _allSelected =>
      _alarms.isNotEmpty && _selectedIndices.length == _alarms.length;

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.addAll(List.generate(_alarms.length, (i) => i));
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIndices.isEmpty) return;

    final sorted = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));

    // 先尝试从设备删除
    final toDelete = <AlarmModel>[];
    for (final i in sorted) {
      toDelete.add(_alarms[i]);
    }

    setState(() {
      for (final i in sorted) {
        _alarms.removeAt(i);
      }
      _selectedIndices.clear();
    });

    await _saveAlarms();

    // 异步从设备删除（不阻塞 UI）
    for (final alarm in toDelete) {
      _deleteAlarmFromDevice(alarm.alarmId);
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditing = false;
      _selectedIndices.clear();
    });
  }

  // ========================
  //  添加/编辑闹钟底部面板
  // ========================

  Future<void> _showAlarmSheet({int? existingIndex}) async {
    final l10n = AppLocalizations.of(context);

    // 容量检查（仅新增时）
    if (existingIndex == null && _alarms.length >= maxAlarmCount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.alarmMaxReached),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    final existing = existingIndex != null ? _alarms[existingIndex] : null;

    // 初始值
    TimeOfDay initialTime = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : const TimeOfDay(hour: 8, minute: 0);
    int initialRepeatMask = existing?.repeatMask ?? 0x00;

    final result = await showModalBottomSheet<_AlarmSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlarmSheet(
        initialTime: initialTime,
        initialRepeatMask: initialRepeatMask,
      ),
    );

    if (result == null) return;

    setState(() {
      final alarm = AlarmModel(
        alarmId: existing?.alarmId ?? _allocateAlarmId(),
        enabled: existing?.enabled ?? true,
        hour: result.time.hour,
        minute: result.time.minute,
        repeatMask: result.repeatMask,
        actionMask: 0x00,
      );

      if (existingIndex != null) {
        _alarms[existingIndex] = alarm;
      } else {
        _alarms.add(alarm);
      }
    });

    await _saveAlarms();

    // 异步下发到设备
    final newAlarm = existingIndex != null
        ? _alarms[existingIndex]
        : _alarms.last;
    _sendAlarmToDevice(newAlarm);
  }

  // ========================
  //  UI 构建
  // ========================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_loaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(l10n),
            Expanded(child: _buildAlarmList(l10n)),
            if (_isEditing && _selectedIndices.isNotEmpty)
              _buildBottomDeleteBar(l10n),
          ],
        ),
      ),
    );
  }

  /// 顶部栏。
  Widget _buildAppBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              l10n.alarmPageTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // 同步按钮
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Icon(
                    _bleConnected ? Icons.sync : Icons.sync_disabled,
                    size: 22,
                  ),
            color: _bleConnected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            onPressed: _isSyncing ? null : _syncFromDevice,
            tooltip: l10n.alarmSync,
          ),
          // 编辑/全选/完成
          if (_isEditing)
            IconButton(
              icon: Icon(
                _allSelected
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                size: 24,
              ),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _toggleSelectAll,
              tooltip: l10n.alarmSelectAll,
            ),
          if (_isEditing)
            TextButton(
              onPressed: _exitEditMode,
              child: Text(
                l10n.alarmDone,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed:
                  _alarms.isEmpty ? null : () => setState(() => _isEditing = true),
              child: Text(
                l10n.alarmEdit,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _alarms.isEmpty
                      ? Theme.of(context).colorScheme.outline
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          // 添加按钮
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            color: _alarms.length >= maxAlarmCount
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
            onPressed:
                _alarms.length >= maxAlarmCount ? null : () => _showAlarmSheet(),
          ),
        ],
      ),
    );
  }

  /// 闹钟列表或空状态。
  Widget _buildAlarmList(AppLocalizations l10n) {
    if (_alarms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.alarm_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.alarmNoAlarms,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _alarms.length,
      itemBuilder: (context, index) => _buildAlarmRow(index, l10n),
    );
  }

  /// 单个闹钟行。
  Widget _buildAlarmRow(int index, AppLocalizations l10n) {
    final alarm = _alarms[index];
    final isSelected = _selectedIndices.contains(index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 勾选框（编辑模式）
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _isEditing ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _isEditing ? 48.0 : 0.0,
              child: _isEditing
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(index),
                      activeColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : null,
            ),
          ),
          // 闹钟卡片
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: _isEditing && isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _isEditing
                    ? () => _toggleSelection(index)
                    : () => _showAlarmSheet(existingIndex: index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alarm.formattedTime,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: alarm.enabled
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 重复规则 + 触发动作
                            Text(
                              _buildAlarmSubtitle(alarm, l10n),
                              style: TextStyle(
                                fontSize: 13,
                                color: alarm.enabled
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isEditing)
                        Switch(
                          value: alarm.enabled,
                          onChanged: (v) {
                            setState(() => alarm.enabled = v);
                            _saveAlarms();
                            _sendAlarmToDevice(alarm);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建闹钟副标题：重复规则。
  String _buildAlarmSubtitle(AlarmModel alarm, AppLocalizations l10n) {
    // 重复规则描述
    String repeatDesc;
    if (alarm.isOnce) {
      repeatDesc = l10n.alarmRepeatOnce;
    } else if (alarm.isEveryDay) {
      final isEn = l10n.isEnglish;
      repeatDesc = isEn ? 'Every day' : '每天';
    } else if (alarm.isWeekday) {
      repeatDesc = l10n.alarmRepeatWeekdayShort;
    } else {
      final days = alarm.activeDays;
      final isEn = l10n.isEnglish;
      final names = days
          .map((d) => isEn ? AlarmModel.dayShortEn(d) : AlarmModel.dayShortZh(d))
          .toList();
      repeatDesc = names.join(l10n.alarmDaySeparator);
    }

    return repeatDesc;
  }

  /// 编辑模式底部批量删除栏。
  Widget _buildBottomDeleteBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${l10n.alarmDeleteSelected} (${_selectedIndices.length})',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _deleteSelected,
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            label: Text(
              l10n.alarmDelete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  底部面板返回结果
// ============================================================

class _AlarmSheetResult {
  final TimeOfDay time;
  final int repeatMask;

  const _AlarmSheetResult({
    required this.time,
    required this.repeatMask,
  });
}

// ============================================================
//  闹钟设置底部面板（三步流程）
// ============================================================

/// 两步闹钟设置流程：
///   Step 0：选择时间
///   Step 1：选择重复模式（单次 / 每天 / 仅工作日 / 自定义及日期选择）
class _AlarmSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final int initialRepeatMask;

  const _AlarmSheet({
    required this.initialTime,
    required this.initialRepeatMask,
  });

  @override
  State<_AlarmSheet> createState() => _AlarmSheetState();
}

class _AlarmSheetState extends State<_AlarmSheet> {
  int _step = 0;

  late TimeOfDay _selectedTime;
  late int _repeatMask;

  /// 用于 Step 1 的重复模式选择辅助状态。
  _RepeatMode _mode = _RepeatMode.once;
  Set<int> _customDays = {};

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _repeatMask = widget.initialRepeatMask;

    // 从 repeatMask 恢复模式
    if (_repeatMask == 0x00) {
      _mode = _RepeatMode.once;
    } else if (_repeatMask == 0x7F) {
      _mode = _RepeatMode.everyDay;
    } else if (_repeatMask == 0x1F) {
      _mode = _RepeatMode.weekday;
    } else {
      _mode = _RepeatMode.custom;
      _customDays = Set<int>.from(
        List.generate(7, (i) => i + 1).where((d) => (_repeatMask >> (d - 1)) & 1 == 1),
      );
    }
  }

  /// 将当前模式和自定义日期转换为 repeatMask。
  int _computeRepeatMask() {
    switch (_mode) {
      case _RepeatMode.once:
        return 0x00;
      case _RepeatMode.everyDay:
        return 0x7F;
      case _RepeatMode.weekday:
        return 0x1F;
      case _RepeatMode.custom:
        int mask = 0;
        for (final d in _customDays) {
          mask |= 1 << (d - 1);
        }
        return mask;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepContent(l10n),
            _buildBottomButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return _buildTimeStep();
      case 1:
        return _buildRepeatStep(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  // -------------------------
  //  Step 0: 时间选择
  // -------------------------

  static const int _loopCount = 100;
  static const int _loopMid = _loopCount ~/ 2;

  Widget _buildTimeStep() {
    final l10n = AppLocalizations.of(context);
    final hourInit = _selectedTime.hour + _loopMid * 24;
    final minuteInit = _selectedTime.minute + _loopMid * 60;

    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.alarmSelectTime,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: hourInit,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    _selectedTime = TimeOfDay(
                      hour: index % 24,
                      minute: _selectedTime.minute,
                    );
                  },
                  children: List.generate(_loopCount * 24, (i) {
                    return Center(
                      child: Text(
                        (i % 24).toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 22).copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                ':',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: minuteInit,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    _selectedTime = TimeOfDay(
                      hour: _selectedTime.hour,
                      minute: index % 60,
                    );
                  },
                  children: List.generate(_loopCount * 60, (i) {
                    return Center(
                      child: Text(
                        (i % 60).toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 22).copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // -------------------------
  //  Step 1: 选择重复模式
  // -------------------------

  Widget _buildRepeatStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.alarmSelectRepeat,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _repeatOption(
          title: l10n.alarmRepeatOnce,
          isSelected: _mode == _RepeatMode.once,
          onTap: () => setState(() => _mode = _RepeatMode.once),
        ),
        const SizedBox(height: 10),
        _repeatOption(
          title: l10n.alarmRepeatWeekday,
          isSelected: _mode == _RepeatMode.weekday,
          onTap: () => setState(() => _mode = _RepeatMode.weekday),
        ),
        const SizedBox(height: 10),
        _repeatOption(
          title: l10n.isEnglish ? 'Every day' : '每天',
          isSelected: _mode == _RepeatMode.everyDay,
          onTap: () => setState(() => _mode = _RepeatMode.everyDay),
        ),
        const SizedBox(height: 10),
        _repeatOption(
          title: l10n.alarmRepeatCustom,
          isSelected: _mode == _RepeatMode.custom,
          onTap: () => setState(() => _mode = _RepeatMode.custom),
        ),
        if (_mode == _RepeatMode.custom) ...[
          const SizedBox(height: 16),
          Text(
            l10n.alarmSelectDays,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(7, (i) => i + 1).map((day) => _buildDayOption(day, l10n)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDayOption(int day, AppLocalizations l10n) {
    final isEn = l10n.isEnglish;
    final isSelected = _customDays.contains(day);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _customDays.remove(day);
            } else {
              _customDays.add(day);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isEn
                      ? AlarmModel.dayFullEn(day)
                      : AlarmModel.dayFullZh(day),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _repeatOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  //  底部按钮
  // -------------------------

  Widget _buildBottomButtons(AppLocalizations l10n) {
    final isLastStep = _step == 1;
    final prevEnabled = _step > 0;

    // Step 1 自定义模式下未选日期则禁用下一步
    final nextEnabled = !(_step == 1 && _mode == _RepeatMode.custom && _customDays.isEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _textButton(
              label: l10n.alarmCancel,
              textColor: Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _textButton(
              label: l10n.alarmPrev,
              textColor: prevEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              onPressed: prevEnabled
                  ? () => setState(() => _step--)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _pillButton(
              label: isLastStep ? l10n.alarmSave : l10n.alarmNext,
              enabled: isLastStep ? true : nextEnabled,
              onPressed: () {
                if (isLastStep) {
                  final repeatMask = _computeRepeatMask();
                  // 仅今天闹钟校验时间不能早于当前时间
                  if (repeatMask == 0x00) {
                    final now = DateTime.now();
                    final nowMinutes = now.hour * 60 + now.minute;
                    final alarmMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
                    if (alarmMinutes <= nowMinutes) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.alarmTimePassedTitle),
                          content: Text(l10n.alarmTimePassed),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.alarmTimePassedOk),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }
                  Navigator.pop(
                    context,
                    _AlarmSheetResult(
                      time: _selectedTime,
                      repeatMask: repeatMask,
                    ),
                  );
                } else {
                  setState(() => _step = 1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _textButton({
    required String label,
    required Color textColor,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: textColor),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          disabledBackgroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
          disabledForegroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.6),
          foregroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

// ============================================================
//  辅助枚举
// ============================================================

enum _RepeatMode { once, everyDay, weekday, custom }
