import 'package:flclashx/coolgo/config.dart';
import 'package:flclashx/coolgo/models/models.dart';
import 'package:flclashx/coolgo/services/api_client.dart';
import 'package:flclashx/coolgo/utils/session_manager.dart';

/// CoolGo 认证服务
class CoolGoAuthService {
  CoolGoAuthService({
    required CoolGoApiClient apiClient,
    required CoolGoSessionManager sessionManager,
  })  : _apiClient = apiClient,
        _sessionManager = sessionManager;

  final CoolGoApiClient _apiClient;
  final CoolGoSessionManager _sessionManager;

  /// 登录
  /// 
  /// [email] 用户邮箱
  /// [password] 用户密码
  /// [remember] 是否记住登录状态
  /// 
  /// 返回用户详细信息（包含订阅地址）
  Future<CoolGoUserProfile> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    // 1. 调用登录接口
    final response = await _apiClient.post(
      CoolGoConfig.loginPath,
      data: {
        'email': email,
        'password': password,
      },
    );

    final authResult = CoolGoAuthResult.fromJson(response);

    if (!authResult.success || authResult.data == null) {
      throw Exception(authResult.message ?? '登录失败');
    }

    final token = authResult.data!.token;
    final user = authResult.data!.user;

    // 2. 保存 Session
    await _sessionManager.saveSession(
      token: token,
      user: user,
      remember: remember,
    );

    // 3. 获取用户详细信息
    final profile = await getProfile(token);

    return profile;
  }

  /// 获取用户详细信息
  Future<CoolGoUserProfile> getProfile(String token) async {
    final response = await _apiClient.get(
      CoolGoConfig.profilePath,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final profileResponse = CoolGoProfileResponse.fromJson(response);

    if (!profileResponse.success || profileResponse.data == null) {
      throw Exception(profileResponse.message ?? '获取用户信息失败');
    }

    return profileResponse.data!;
  }

  /// 验证当前 Token 是否有效
  /// 
  /// 返回用户信息，如果 Token 无效则抛出异常
  Future<CoolGoUserProfile?> validateToken() async {
    final token = await _sessionManager.getToken();
    if (token == null) return null;

    // 先检查本地 Token 是否过期
    if (_sessionManager.isTokenExpired(token)) {
      await _sessionManager.clearSession();
      return null;
    }

    try {
      // 调用 API 验证 Token
      return await getProfile(token);
    } catch (e) {
      // Token 无效，清除 Session
      await _sessionManager.clearSession();
      return null;
    }
  }

  /// 登出
  Future<void> logout() async {
    await _sessionManager.clearSession();
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await _sessionManager.isLoggedIn();
  }

  /// 获取保存的 Token
  Future<String?> getToken() async {
    return await _sessionManager.getToken();
  }

  /// 获取保存的用户信息
  Future<CoolGoUser?> getSavedUser() async {
    return await _sessionManager.getUser();
  }
}
