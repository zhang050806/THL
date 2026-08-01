import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// [StorageKeys] 本地持久化存储 Key 常量定义。
/// 集中管理所有 SharedPreferences 键名，避免硬编码分散。
class StorageKeys {
  // 认证相关
  static const String authToken = 'auth_token';
  static const String accountNickname = 'account_nickname';
  static const String accountAvatar = 'account_avatar';
  static const String accountPhone = 'account_phone';
  static const String accountBirthday = 'account_birthday';
  static const String accountId = 'account_id';

  // 设备相关
  static const String boundDevices = 'bound_devices';
  static const String serverUrl = 'server_url';

  // 用户数据（快捷指令等）
  static const String shortcuts = 'shortcuts';

  // 应用设置
  static const String isDarkMode = 'is_dark_mode';
  static const String appLanguage = 'app_language';

  // 闹钟数据
  static const String alarms = 'alarms';

  // 同步标记
  static const String dataDirtyFlags = 'data_dirty_flags';
}

/// [StorageService] 单例 SharedPreferences 封装。
/// 统一管理所有 key 的读写操作，涵盖认证、设备、快捷指令、应用设置、同步标记等模块。
/// 提供 dirty flag 机制以支持离线修改后的批量云端同步。
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  /// 延迟初始化 SharedPreferences 实例并缓存。
  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========================
  // 认证相关
  // ========================

  /// 获取认证 Token。
  Future<String?> getToken() async =>
      (await _p).getString(StorageKeys.authToken);

  /// 设置认证 Token。
  Future<void> setToken(String token) async =>
      (await _p).setString(StorageKeys.authToken, token);

  /// 清除认证 Token（用于登出或 Token 过期）。
  Future<void> clearToken() async =>
      (await _p).remove(StorageKeys.authToken);

  /// 检查是否已登录（Token 是否存在且非空）。
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 获取用户昵称，默认返回 'THL用户'。
  Future<String> getNickname() async =>
      (await _p).getString(StorageKeys.accountNickname) ?? 'THL用户';

  /// 设置用户昵称。
  Future<void> setNickname(String value) async =>
      (await _p).setString(StorageKeys.accountNickname, value);

  /// 获取用户头像本地路径，无则返回 null。
  Future<String?> getAvatar() async =>
      (await _p).getString(StorageKeys.accountAvatar);

  /// 设置用户头像本地路径。
  Future<void> setAvatar(String value) async =>
      (await _p).setString(StorageKeys.accountAvatar, value);

  /// 获取绑定手机号，默认返回 '未绑定'。
  Future<String> getPhone() async =>
      (await _p).getString(StorageKeys.accountPhone) ?? '未绑定';

  /// 设置绑定手机号。
  Future<void> setPhone(String value) async =>
      (await _p).setString(StorageKeys.accountPhone, value);

  /// 获取生日信息，默认返回 '未设置'。
  Future<String> getBirthday() async =>
      (await _p).getString(StorageKeys.accountBirthday) ?? '未设置';

  /// 设置生日信息。
  Future<void> setBirthday(String value) async =>
      (await _p).setString(StorageKeys.accountBirthday, value);

  /// 获取账号ID（服务端返回的用户唯一标识）。
  Future<String?> getAccountId() async =>
      (await _p).getString(StorageKeys.accountId);

  /// 设置账号ID。
  Future<void> setAccountId(String value) async =>
      (await _p).setString(StorageKeys.accountId, value);

  // ========================
  // 设备相关
  // ========================

  /// 获取已绑定设备列表的 JSON 字符串。
  Future<String?> getBoundDevices() async =>
      (await _p).getString(StorageKeys.boundDevices);

  /// 设置已绑定设备列表的 JSON 字符串。
  Future<void> setBoundDevices(String value) async =>
      (await _p).setString(StorageKeys.boundDevices, value);

  /// 获取已绑定设备列表（解析为 List<Map>）。
  Future<List<Map<String, dynamic>>> getDeviceList() async {
    final raw = await getBoundDevices();
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// 向设备列表中添加一个设备，自动去重（按 address）。
  Future<void> addDevice(Map<String, dynamic> device) async {
    final devices = await getDeviceList();
    final addr = device['address'] as String? ?? '';
    final idx = devices.indexWhere((d) => d['address'] == addr);
    if (idx >= 0) {
      devices[idx] = device;
    } else {
      devices.add(device);
    }
    await setBoundDevices(json.encode(devices));
  }

  /// 从设备列表中移除指定设备（按 address 匹配）。
  Future<void> removeDevice(String address) async {
    final devices = await getDeviceList();
    devices.removeWhere((d) => d['address'] == address);
    await setBoundDevices(json.encode(devices));
  }

  /// 获取服务器连接地址。
  Future<String?> getServerUrl() async =>
      (await _p).getString(StorageKeys.serverUrl);

  /// 设置服务器连接地址。
  Future<void> setServerUrl(String value) async =>
      (await _p).setString(StorageKeys.serverUrl, value);

  // ========================
  // 快捷指令
  // ========================

  /// 获取快捷指令列表的 JSON 字符串。
  Future<String?> getShortcuts() async =>
      (await _p).getString(StorageKeys.shortcuts);

  /// 设置快捷指令列表的 JSON 字符串。
  Future<void> setShortcuts(String value) async =>
      (await _p).setString(StorageKeys.shortcuts, value);

  // ========================
  // 闹钟数据
  // ========================

  /// 获取闹钟列表的 JSON 字符串。
  Future<String?> getAlarms() async =>
      (await _p).getString(StorageKeys.alarms);

  /// 设置闹钟列表的 JSON 字符串。
  Future<void> setAlarms(String value) async =>
      (await _p).setString(StorageKeys.alarms, value);

  // ========================
  // 应用设置
  // ========================

  /// 获取暗色模式偏好，默认 false（亮色模式）。
  Future<bool> getIsDarkMode() async =>
      (await _p).getBool(StorageKeys.isDarkMode) ?? false;

  /// 设置暗色模式偏好。
  Future<void> setIsDarkMode(bool value) async =>
      (await _p).setBool(StorageKeys.isDarkMode, value);

  /// 获取应用语言偏好，默认 'zh'（中文）。
  Future<String> getAppLanguage() async =>
      (await _p).getString(StorageKeys.appLanguage) ?? 'zh';

  /// 设置应用语言偏好（如 'zh' / 'en'）。
  Future<void> setAppLanguage(String value) async =>
      (await _p).setString(StorageKeys.appLanguage, value);

  // ========================
  // 同步标记（dirty flags）
  // ========================

  /// 标记某项数据已在本地修改，需要同步到服务端。
  /// [dataKey] 数据标识键（如 StorageKeys.shortcuts）。
  Future<void> markDirty(String dataKey) async {
    final p = await _p;
    final flags = p.getStringList(StorageKeys.dataDirtyFlags) ?? [];
    if (!flags.contains(dataKey)) {
      flags.add(dataKey);
      await p.setStringList(StorageKeys.dataDirtyFlags, flags);
    }
  }

  /// 清除某项数据的 dirty 标记（同步成功后调用）。
  /// [dataKey] 数据标识键。
  Future<void> clearDirty(String dataKey) async {
    final p = await _p;
    final flags = p.getStringList(StorageKeys.dataDirtyFlags) ?? [];
    flags.remove(dataKey);
    await p.setStringList(StorageKeys.dataDirtyFlags, flags);
  }

  /// 获取所有 dirty 标记列表。
  Future<List<String>> getDirtyFlags() async {
    final p = await _p;
    return p.getStringList(StorageKeys.dataDirtyFlags) ?? [];
  }

  /// 是否有任何待同步的数据。
  Future<bool> hasDirtyData() async => (await getDirtyFlags()).isNotEmpty;

  // ========================
  // 登出清理
  // ========================

  /// 清除所有认证相关数据。
  /// 保留应用设置（主题/语言）和设备列表、快捷指令等用户数据，
  /// 以便下次登录后通过同步恢复。
  Future<void> clearAuthData() async {
    final p = await _p;
    await p.remove(StorageKeys.authToken);
    await p.remove(StorageKeys.accountId);
    await p.remove(StorageKeys.accountNickname);
    await p.remove(StorageKeys.accountPhone);
    await p.remove(StorageKeys.accountBirthday);
  }
}
