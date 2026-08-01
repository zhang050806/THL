import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// [ApiConfig] 后端 API 配置文件。
/// 集中管理所有后端接口地址，对接自定义后端时只需修改此处的常量和 URL。
///
/// 🔧 用户自定义配置区 —— 对接自己的后端时只需修改这里
/// =====================================================
class ApiConfig {
  /// 后端 API 基础地址
  static String baseUrl = 'http://localhost:8080/api';

  /// 登录接口路径（相对于 baseUrl）
  static const String loginPath = '/auth/login';

  /// 注册接口路径（相对于 baseUrl）
  static const String registerPath = '/auth/register';

  /// 用户数据上传接口路径
  static const String userDataUploadPath = '/sync/upload';

  /// 用户数据拉取接口路径
  static const String userDataFetchPath = '/sync/fetch';

  /// 用户信息接口路径
  static const String userProfilePath = '/user/profile';
}

/// [ApiService] 单例 API 客户端。
/// 封装 GET/POST 请求、自动附加 Bearer Token、401 自动清除凭证、
/// 统一错误处理。通过 StorageService 持久化管理 Token。
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final StorageService _storage = StorageService.instance;

  /// 获取当前存储的认证 Token。
  Future<String?> get token => _storage.getToken();

  /// 构造通用请求头。
  /// 自动附加 JSON Content-Type 和 Bearer Token（如果已登录）。
  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final t = await _storage.getToken();
    if (t != null && t.isNotEmpty) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  /// 发起 GET 请求并返回 [ApiResponse]。
  /// [path] 接口相对路径，自动拼接到 baseUrl 后。
  Future<ApiResponse> get(String path) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$path');
      final response = await http.get(url, headers: await _headers());
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('网络连接失败，请检查网络设置');
    }
  }

  /// 发起 POST 请求并返回 [ApiResponse]。
  /// [path] 接口相对路径；[body] 请求体 Map，自动 JSON 编码。
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$path');
      final response = await http.post(
        url,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('网络连接失败，请检查网络设置');
    }
  }

  /// 统一解析 HTTP 响应。
  /// 处理 401 鉴权失效（自动清除 Token）、服务端错误消息提取。
  /// [response] HTTP 原始响应对象，返回 [ApiResponse] 包装的成功/失败结果。
  Future<ApiResponse> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token 过期或无效，清除本地 Token
      await _storage.clearToken();
      return ApiResponse.error('登录已过期，请重新登录', statusCode: 401);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data);
      } catch (_) {
        return ApiResponse.success(response.body);
      }
    }
    // 尝试解析服务端错误消息
    String message = '请求失败 (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      }
    } catch (_) {}
    return ApiResponse.error(message, statusCode: response.statusCode);
  }
}

/// [ApiResponse] 通用 API 响应封装。
/// [isSuccess] 请求是否成功
/// [data] 成功时携带的业务数据（可能为 null、Map、String 等）
/// [errorMessage] 失败时的错误描述
/// [statusCode] HTTP 状态码
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  /// 构造成功响应。
  factory ApiResponse.success(dynamic data) =>
      ApiResponse._(isSuccess: true, data: data);

  /// 构造失败响应。
  factory ApiResponse.error(String message, {int? statusCode}) =>
      ApiResponse._(
          isSuccess: false, errorMessage: message, statusCode: statusCode);
}
