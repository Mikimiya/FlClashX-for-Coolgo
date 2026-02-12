import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// CoolGo 用户基础信息（登录响应中的 user 字段）
@freezed
class CoolGoUser with _$CoolGoUser {
  const factory CoolGoUser({
    required int id,
    required String email,
    @Default(false) bool emailVerified,
    @Default('USER') String role,
    @Default(false) bool isAdmin,
    @Default('0') String balance,
    String? affiliateCode,
  }) = _CoolGoUser;

  factory CoolGoUser.fromJson(Map<String, dynamic> json) =>
      _$CoolGoUserFromJson(json);
}
