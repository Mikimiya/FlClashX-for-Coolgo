import 'dart:convert';

import 'package:flclashx/coolgo/config.dart';
import 'package:flclashx/coolgo/models/models.dart';
import 'package:flclashx/coolgo/utils/jwt_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CoolGo Session 管理器
/// 
/// 负责 Token 和用户信息的持久化存储
class CoolGoSessionManager {
  CoolGoSessionManager();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 保存 Session
  Future<void> saveSession({
    required String token,
    required CoolGoUser user,
    bool remember = false,
  }) async {
    final prefs = await _preferences;
    
    await prefs.setString(CoolGoConfig.tokenKey, token);
    await prefs.setString(CoolGoConfig.userKey, json.encode(user.toJson()));
    await prefs.setBool(CoolGoConfig.rememberKey, remember);
  }

  /// 获取保存的 Token
  Future<String?> getToken() async {
    final prefs = await _preferences;
    return prefs.getString(CoolGoConfig.tokenKey);
  }

  /// 获取保存的用户信息
  Future<CoolGoUser?> getUser() async {
    final prefs = await _preferences;
    final userJson = prefs.getString(CoolGoConfig.userKey);
    
    if (userJson == null) return null;
    
    try {
      return CoolGoUser.fromJson(json.decode(userJson));
    } catch (_) {
      return null;
    }
  }

  /// 检查是否记住登录
  Future<bool> isRemembered() async {
    final prefs = await _preferences;
    return prefs.getBool(CoolGoConfig.rememberKey) ?? false;
  }

  /// 清除 Session
  Future<void> clearSession() async {
    final prefs = await _preferences;
    
    await prefs.remove(CoolGoConfig.tokenKey);
    await prefs.remove(CoolGoConfig.userKey);
    // 保留 remember 设置，不清除
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    // 检查 Token 是否过期
    if (isTokenExpired(token)) {
      await clearSession();
      return false;
    }
    
    return true;
  }

  /// 检查 Token 是否过期（本地检查）
  bool isTokenExpired(String token) {
    return JwtUtils.isExpired(token);
  }

  /// 获取 Token 剩余有效时间
  Duration? getTokenRemainingTime(String token) {
    return JwtUtils.getRemainingTime(token);
  }

  /// 检查 CoolGo 功能是否启用
  Future<bool> isEnabled() async {
    final prefs = await _preferences;
    // 默认启用
    return prefs.getBool(CoolGoConfig.enabledKey) ?? true;
  }

  /// 设置 CoolGo 功能启用状态
  Future<void> setEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(CoolGoConfig.enabledKey, enabled);
  }
}
