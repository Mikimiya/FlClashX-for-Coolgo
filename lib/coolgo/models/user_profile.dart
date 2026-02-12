import 'package:freezed_annotation/freezed_annotation.dart';
import 'remnawave_info.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// 获取用户信息接口的响应
@freezed
class CoolGoProfileResponse with _$CoolGoProfileResponse {
  const factory CoolGoProfileResponse({
    required bool success,
    String? message,
    CoolGoUserProfile? data,
  }) = _CoolGoProfileResponse;

  factory CoolGoProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$CoolGoProfileResponseFromJson(json);
}

/// 用户详细信息
@freezed
class CoolGoUserProfile with _$CoolGoUserProfile {
  const factory CoolGoUserProfile({
    required String email,
    @Default('') String name,
    @Default(false) bool isVerified,
    @Default(false) bool isAdmin,
    @Default(0) double balance,
    @Default(true) bool isAutoRenew,
    @Default(false) bool hasUsedTrial,
    @Default(false) bool hasActiveSubscription,
    
    /// 订阅详情（核心字段）
    CoolGoRemnawaveInfo? remnawaveInfo,
    
    /// 注册时间
    String? createdAt,
  }) = _CoolGoUserProfile;

  factory CoolGoUserProfile.fromJson(Map<String, dynamic> json) =>
      _$CoolGoUserProfileFromJson(json);
}

/// UserProfile 扩展方法
extension CoolGoUserProfileExt on CoolGoUserProfile {
  /// 获取订阅 URL
  String? get subscriptionUrl => remnawaveInfo?.subscriptionUrl;

  /// 是否有有效订阅
  bool get hasValidSubscription {
    return remnawaveInfo != null && 
           remnawaveInfo!.subscriptionUrl != null &&
           remnawaveInfo!.subscriptionUrl!.isNotEmpty &&
           remnawaveInfo!.isActive;
  }

  /// 套餐名称
  String get planName => remnawaveInfo?.planName ?? '无套餐';

  /// 显示名称（优先使用 name，否则使用 email 前缀）
  String get displayName {
    if (name.isNotEmpty) return name;
    final atIndex = email.indexOf('@');
    return atIndex > 0 ? email.substring(0, atIndex) : email;
  }
}
