import 'dart:convert';

import 'package:flclashx/coolgo/config.dart';

/// JWT Token 工具类
class JwtUtils {
  JwtUtils._();

  /// 解析 JWT Token 获取 payload
  static Map<String, dynamic>? parsePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // 解码 payload (第二部分)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 获取 Token 过期时间
  static DateTime? getExpirationDate(String token) {
    final payload = parsePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp == null) return null;

    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
    
    return null;
  }

  /// 获取 Token 签发时间
  static DateTime? getIssuedAt(String token) {
    final payload = parsePayload(token);
    if (payload == null) return null;

    final iat = payload['iat'];
    if (iat == null) return null;

    if (iat is int) {
      return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
    }
    
    return null;
  }

  /// 检查 Token 是否过期
  /// 
  /// 提前 [buffer] 时间认为过期（默认提前5分钟）
  static bool isExpired(String token, {Duration? buffer}) {
    final expDate = getExpirationDate(token);
    if (expDate == null) return true;

    final effectiveBuffer = buffer ?? CoolGoConfig.tokenExpiryBuffer;
    final effectiveExpiry = expDate.subtract(effectiveBuffer);

    return DateTime.now().isAfter(effectiveExpiry);
  }

  /// 获取 Token 剩余有效时间
  static Duration? getRemainingTime(String token) {
    final expDate = getExpirationDate(token);
    if (expDate == null) return null;

    final remaining = expDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 获取用户 ID
  static int? getUserId(String token) {
    final payload = parsePayload(token);
    return payload?['userId'] as int?;
  }

  /// 获取用户邮箱
  static String? getEmail(String token) {
    final payload = parsePayload(token);
    return payload?['email'] as String?;
  }

  /// 获取用户角色
  static String? getRole(String token) {
    final payload = parsePayload(token);
    return payload?['role'] as String?;
  }
}
