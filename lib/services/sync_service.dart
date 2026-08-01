import 'dart:convert';
import 'api_service.dart';
import 'storage_service.dart';

/// [SyncService] 单例数据同步服务。
/// 提供用户数据的上传、拉取、批量同步抽象。
/// 基于 dirty flag 机制，仅同步本地已修改的数据，
/// 同步成功后自动清除对应 dirty 标记。
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final ApiService _api = ApiService.instance;
  final StorageService _storage = StorageService.instance;

  /// 上传用户数据到服务端。
  /// [key] 数据标识（如 'shortcuts' / 'bound_devices' / 'settings'）
  /// [data] 要上传的数据（Map / List 等可 JSON 序列化对象）
  /// 返回 [ApiResponse]，成功时自动清除 key 对应的 dirty 标记。
  Future<ApiResponse> uploadUserData(String key, dynamic data) async {
    final body = <String, dynamic>{
      'key': key,
      'data': data,
    };
    final response =
        await _api.post(ApiConfig.userDataUploadPath, body: body);
    if (response.isSuccess) {
      await _storage.clearDirty(key);
    }
    return response;
  }

  /// 从服务端拉取用户数据。
  /// [key] 数据标识，通过 query 参数传递
  /// 返回 [ApiResponse]，成功时 data 为服务端返回的原始数据。
  Future<ApiResponse> fetchUserData(String key) async {
    final response = await _api.get('${ApiConfig.userDataFetchPath}?key=$key');
    return response;
  }

  /// 拉取用户个人资料并自动同步到本地存储。
  /// 成功时自动更新本地 nickname 和 phone。
  Future<ApiResponse> fetchUserProfile() async {
    final response = await _api.get(ApiConfig.userProfilePath);
    if (response.isSuccess) {
      final data = response.data;
      if (data is Map) {
        final nickname = data['nickname'] ?? data['name'];
        if (nickname != null) await _storage.setNickname(nickname.toString());
        final phone = data['phone'];
        if (phone != null) await _storage.setPhone(phone.toString());
      }
    }
    return response;
  }

  /// 同步所有本地 dirty 数据到服务端。
  /// 遍历 dirty flags 列表，对每个 key 读取本地数据后上传。
  /// 返回 [SyncResult] 列表，包含每个 key 的同步成功/失败状态。
  Future<List<SyncResult>> syncAll() async {
    final results = <SyncResult>[];
    final dirtyKeys = await _storage.getDirtyFlags();

    for (final key in dirtyKeys) {
      dynamic data;
      // 根据 key 类型从本地存储读取对应数据
      switch (key) {
        case StorageKeys.shortcuts:
          final raw = await _storage.getShortcuts();
          data = raw != null ? jsonDecode(raw) : null;
          break;
        case StorageKeys.boundDevices:
          final raw = await _storage.getBoundDevices();
          data = raw != null ? jsonDecode(raw) : null;
          break;
        default:
          continue; // 未知 key 跳过
      }
      if (data != null) {
        final resp = await uploadUserData(key, data);
        results.add(SyncResult(
          key: key,
          success: resp.isSuccess,
          error: resp.errorMessage,
        ));
      }
    }
    return results;
  }
}

/// [SyncResult] 单项同步结果。
/// [key] 数据标识键
/// [success] 同步是否成功
/// [error] 失败时的错误信息
class SyncResult {
  final String key;
  final bool success;
  final String? error;

  SyncResult({required this.key, required this.success, this.error});
}
