import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth_result.freezed.dart';
part 'auth_result.g.dart';

/// 登录响应结果
@freezed
class CoolGoAuthResult with _$CoolGoAuthResult {
  const factory CoolGoAuthResult({
    required bool success,
    String? message,
    CoolGoAuthData? data,
  }) = _CoolGoAuthResult;

  factory CoolGoAuthResult.fromJson(Map<String, dynamic> json) =>
      _$CoolGoAuthResultFromJson(json);
}

/// 登录响应数据
@freezed
class CoolGoAuthData with _$CoolGoAuthData {
  const factory CoolGoAuthData({
    required String token,
    required CoolGoUser user,
  }) = _CoolGoAuthData;

  factory CoolGoAuthData.fromJson(Map<String, dynamic> json) =>
      _$CoolGoAuthDataFromJson(json);
}
