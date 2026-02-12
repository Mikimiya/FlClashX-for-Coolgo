import 'package:freezed_annotation/freezed_annotation.dart';

part 'remnawave_info.freezed.dart';
part 'remnawave_info.g.dart';

/// 用户流量信息
@freezed
class CoolGoUserTraffic with _$CoolGoUserTraffic {
  const factory CoolGoUserTraffic({
    String? firstConnectedAt,
    String? lastConnectedNodeUuid,
    @Default(0) int lifetimeUsedTrafficBytes,
    String? onlineAt,
    @Default(0) int usedTrafficBytes,
  }) = _CoolGoUserTraffic;

  factory CoolGoUserTraffic.fromJson(Map<String, dynamic> json) =>
      _$CoolGoUserTrafficFromJson(json);
}

/// Remnawave 订阅信息
@freezed
class CoolGoRemnawaveInfo with _$CoolGoRemnawaveInfo {
  const factory CoolGoRemnawaveInfo({
    /// 过期时间 (ISO 8601 格式)
    String? expireAt,

    /// 设备数量限制
    @Default(0) int hwidDeviceLimit,

    /// 套餐名称
    String? planName,

    /// 订阅状态: ACTIVE, EXPIRED, etc.
    String? status,

    /// 订阅地址（核心字段）
    String? subscriptionUrl,

    /// 流量限制（字节）
    @Default(0) int trafficLimitBytes,

    /// 流量重置策略: MONTH, etc.
    String? trafficLimitStrategy,

    /// 已使用设备数
    @Default(0) int usedDevices,

    /// 用户流量详情
    CoolGoUserTraffic? userTraffic,

    /// 用户名
    String? username,

    /// 用户 UUID
    String? uuid,
  }) = _CoolGoRemnawaveInfo;

  factory CoolGoRemnawaveInfo.fromJson(Map<String, dynamic> json) =>
      _$CoolGoRemnawaveInfoFromJson(json);
}

/// RemnawaveInfo 扩展方法
extension CoolGoRemnawaveInfoExt on CoolGoRemnawaveInfo {
  /// 是否有效订阅
  bool get isActive => status?.toUpperCase() == 'ACTIVE';

  /// 是否已过期
  bool get isExpired {
    if (expireAt == null) return false;
    try {
      final expiry = DateTime.parse(expireAt!);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return false;
    }
  }

  /// 获取过期时间的 DateTime 对象
  DateTime? get expiryDate {
    if (expireAt == null) return null;
    try {
      return DateTime.parse(expireAt!);
    } catch (_) {
      return null;
    }
  }

  /// 剩余流量（字节）
  int get remainingTrafficBytes {
    final used = userTraffic?.usedTrafficBytes ?? 0;
    return trafficLimitBytes - used;
  }

  /// 流量使用百分比 (0-100)
  double get trafficUsagePercent {
    if (trafficLimitBytes == 0) return 0;
    final used = userTraffic?.usedTrafficBytes ?? 0;
    return (used / trafficLimitBytes * 100).clamp(0, 100);
  }

  /// 格式化流量显示
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  /// 格式化的流量限制
  String get formattedTrafficLimit => formatBytes(trafficLimitBytes);

  /// 格式化的已用流量
  String get formattedUsedTraffic =>
      formatBytes(userTraffic?.usedTrafficBytes ?? 0);

  /// 格式化的剩余流量
  String get formattedRemainingTraffic => formatBytes(remainingTrafficBytes);
}
