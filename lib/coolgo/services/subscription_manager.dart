import 'package:flclashx/coolgo/config.dart';
import 'package:flclashx/coolgo/models/models.dart';
import 'package:flclashx/models/models.dart';
import 'package:flclashx/providers/providers.dart';
import 'package:flclashx/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CoolGo 订阅管理器
/// 
/// 负责处理 CoolGo 订阅的创建、更新和删除
class CoolGoSubscriptionManager {
  CoolGoSubscriptionManager();

  /// 处理登录成功后的订阅
  /// 
  /// 每次登录都会删除旧的 CoolGo 订阅，重新拉取新订阅
  /// (符合需求：每次登录删除之前的订阅，重新拉取订阅)
  Future<void> handleSubscription(CoolGoUserProfile profile) async {
    final subscriptionUrl = profile.subscriptionUrl;
    
    if (subscriptionUrl == null || subscriptionUrl.isEmpty) {
      throw Exception('未找到有效订阅，请先购买套餐');
    }

    final prefs = await SharedPreferences.getInstance();
    final existingProfileId = prefs.getString(CoolGoConfig.profileIdKey);

    // 如果已存在 CoolGo 订阅，先删除
    if (existingProfileId != null) {
      await _deleteExistingProfile(existingProfileId, prefs);
    }
    
    // 创建新订阅
    await _createNewProfile(subscriptionUrl, prefs);
  }

  /// 删除已存在的订阅
  Future<void> _deleteExistingProfile(
    String profileId,
    SharedPreferences prefs,
  ) async {
    try {
      await globalState.appController.deleteProfile(profileId);
    } catch (e) {
      // 如果删除失败（可能已被用户删除），忽略错误
    }
    await prefs.remove(CoolGoConfig.profileIdKey);
  }

  /// 创建新的 CoolGo 订阅
  Future<void> _createNewProfile(
    String subscriptionUrl,
    SharedPreferences prefs,
  ) async {
    // 使用现有方法创建并更新订阅
    final profile = await Profile.normal(
      label: CoolGoConfig.profileLabel,
      url: subscriptionUrl,
    ).update();

    // 添加标记到 providerHeaders，方便后续识别
    final markedProfile = profile.copyWith(
      providerHeaders: {
        ...profile.providerHeaders,
        CoolGoConfig.managedHeader: 'true',
      },
    );

    // 添加订阅
    await globalState.appController.addProfile(markedProfile);

    // 保存 Profile ID 用于后续更新
    await prefs.setString(CoolGoConfig.profileIdKey, markedProfile.id);

    // 自动切换到新订阅
    await _switchToProfile(markedProfile.id);
  }

  /// 切换到指定 Profile
  Future<void> _switchToProfile(String profileId) async {
    // 通过 globalState.config 直接设置
    globalState.config = globalState.config.copyWith(
      currentProfileId: profileId,
    );
    
    globalState.appController.applyProfileDebounce(silence: true);
  }

  /// 获取 CoolGo 管理的 Profile
  Future<Profile?> getCoolGoProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString(CoolGoConfig.profileIdKey);
    
    if (profileId == null) return null;
    
    return globalState.config.profiles.getProfile(profileId);
  }

  /// 检查是否有 CoolGo 管理的订阅
  Future<bool> hasCoolGoProfile() async {
    final profile = await getCoolGoProfile();
    return profile != null;
  }

  /// 登出时的处理
  /// 
  /// [keepProfile] 是否保留订阅配置
  Future<void> handleLogout({bool keepProfile = true}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!keepProfile) {
      final profileId = prefs.getString(CoolGoConfig.profileIdKey);
      if (profileId != null) {
        await globalState.appController.deleteProfile(profileId);
      }
    }
    
    await prefs.remove(CoolGoConfig.profileIdKey);
  }

  /// 删除 CoolGo 订阅
  Future<void> deleteCoolGoProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString(CoolGoConfig.profileIdKey);
    
    if (profileId != null) {
      await globalState.appController.deleteProfile(profileId);
      await prefs.remove(CoolGoConfig.profileIdKey);
    }
  }
}
