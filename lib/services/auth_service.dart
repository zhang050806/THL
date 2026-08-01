import 'api_service.dart';
import 'storage_service.dart';

/// [AuthService] 单例认证服务。
/// 管理用户登录、注册、登出及 Token 持久化，作为 API 与 UI 之间的认证中间层。
/// 登录成功自动提取并保存 Token、昵称、账号 ID；
/// 注册成功后自动调用登录接口以获取完整会话凭证。
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ApiService _api = ApiService.instance;
  final StorageService _storage = StorageService.instance;

  /// 用户登录。
  /// [account] 支持手机号/邮箱等统一账号标识
  /// [password] 登录密码
  /// 返回 [ApiResponse]：成功时自动保存 token、nickname、accountId 到本地存储。
  Future<ApiResponse> login(String account, String password) async {
    final response = await _api.post(ApiConfig.loginPath, body: {
      'account': account,
      'password': password,
    });

    if (response.isSuccess) {
      // 从服务端响应中提取 token（适配常见后端返回格式：token / accessToken / access_token）
      final data = response.data;
      String? token;
      if (data is Map) {
        token = data['token'] ?? data['accessToken'] ?? data['access_token'];
        // 同时保存用户信息
        final nickname = data['nickname'] ?? data['name'] ?? account;
        await _storage.setNickname(nickname.toString());
        final accountId = data['id'] ?? data['userId'] ?? data['user_id'];
        if (accountId != null) {
          await _storage.setAccountId(accountId.toString());
        }
      }
      if (token != null) {
        await _storage.setToken(token);
      }
    }
    return response;
  }

  /// 用户注册。
  /// [account] 账号标识（手机号/邮箱）
  /// [password] 注册密码
  /// [nickname] 用户昵称
  /// 注册成功自动保存昵称；若服务端直接返回 token 则自动登录。
  Future<ApiResponse> register(
      String account, String password, String nickname) async {
    final response = await _api.post(ApiConfig.registerPath, body: {
      'account': account,
      'password': password,
      'nickname': nickname,
    });

    if (response.isSuccess) {
      // 注册成功后自动保存昵称
      await _storage.setNickname(nickname);
      // 如果服务端注册后直接返回 token，则自动登录
      final data = response.data;
      if (data is Map) {
        String? token =
            data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _storage.setToken(token);
          final accountId = data['id'] ?? data['userId'] ?? data['user_id'];
          if (accountId != null) {
            await _storage.setAccountId(accountId.toString());
          }
        }
      }
    }
    return response;
  }

  /// 登出：清除本地 Token 和用户认证数据。
  Future<void> logout() async {
    await _storage.clearAuthData();
  }

  /// 检查当前是否已登录（本地 Token 是否存在且非空）。
  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  /// 获取当前存储的认证 Token。
  Future<String?> getToken() => _storage.getToken();
}
