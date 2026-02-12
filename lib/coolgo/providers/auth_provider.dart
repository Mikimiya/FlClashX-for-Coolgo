import 'package:flclashx/coolgo/config.dart';
import 'package:flclashx/coolgo/models/models.dart';
import 'package:flclashx/coolgo/services/services.dart';
import 'package:flclashx/coolgo/utils/utils.dart';
import 'package:flclashx/coolgo/views/views.dart';
import 'package:flclashx/common/common.dart';
import 'package:flclashx/state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// CoolGo 认证状态
class CoolGoAuthState {
  const CoolGoAuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.token,
    this.user,
    this.userProfile,
    this.errorMessage,
  });

  final bool isLoggedIn;
  final bool isLoading;
  final String? token;
  final CoolGoUser? user;
  final CoolGoUserProfile? userProfile;
  final String? errorMessage;

  CoolGoAuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? token,
    CoolGoUser? user,
    CoolGoUserProfile? userProfile,
    String? errorMessage,
    bool clearError = false,
    bool clearToken = false,
    bool clearUser = false,
    bool clearUserProfile = false,
  }) {
    return CoolGoAuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      userProfile: clearUserProfile ? null : (userProfile ?? this.userProfile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// 初始状态
  factory CoolGoAuthState.initial() => const CoolGoAuthState();
}

/// CoolGo 认证 Provider
@Riverpod(keepAlive: true)
class CoolGoAuth extends _$CoolGoAuth {
  late final CoolGoSessionManager _sessionManager;
  late final CoolGoApiClient _apiClient;
  late final CoolGoAuthService _authService;
  late final CoolGoSubscriptionManager _subscriptionManager;

  @override
  CoolGoAuthState build() {
    _sessionManager = CoolGoSessionManager();
    _apiClient = CoolGoApiClient(
      onTokenExpired: _handleTokenExpired,
    );
    _authService = CoolGoAuthService(
      apiClient: _apiClient,
      sessionManager: _sessionManager,
    );
    _subscriptionManager = CoolGoSubscriptionManager();

    // 启动时检查登录状态
    _checkAuthOnStartup();

    return CoolGoAuthState.initial();
  }

  /// 启动时检查认证状态
  Future<void> _checkAuthOnStartup() async {
    final isEnabled = await _sessionManager.isEnabled();
    if (!isEnabled) return;

    state = state.copyWith(isLoading: true);

    try {
      final userProfile = await _authService.validateToken();
      
      if (userProfile != null) {
        final token = await _sessionManager.getToken();
        final user = await _sessionManager.getUser();
        
        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          token: token,
          user: user,
          userProfile: userProfile,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoggedIn: false,
          isLoading: false,
          clearToken: true,
          clearUser: true,
          clearUserProfile: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Token 过期回调
  void _handleTokenExpired() {
    state = state.copyWith(
      isLoggedIn: false,
      clearToken: true,
      clearUser: true,
      clearUserProfile: true,
    );

    // 跳转到登录页
    final context = globalState.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CoolGoLoginPage()),
        (route) => false,
      );

      // 提示用户
      globalState.showMessage(
        title: appLocalizations.tip,
        message: const TextSpan(text: '登录已过期，请重新登录'),
      );
    }
  }

  /// 登录
  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userProfile = await _authService.login(
        email,
        password,
        remember: remember,
      );

      final token = await _sessionManager.getToken();
      final user = await _sessionManager.getUser();

      // 处理订阅
      await _subscriptionManager.handleSubscription(userProfile);

      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        token: token,
        user: user,
        userProfile: userProfile,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 登出
  Future<void> logout({bool keepProfile = true}) async {
    await _authService.logout();
    await _subscriptionManager.handleLogout(keepProfile: keepProfile);

    state = state.copyWith(
      isLoggedIn: false,
      clearToken: true,
      clearUser: true,
      clearUserProfile: true,
      clearError: true,
    );
  }

  /// 刷新用户信息
  Future<void> refreshProfile() async {
    final token = state.token;
    if (token == null) return;

    try {
      final userProfile = await _authService.getProfile(token);
      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      // 刷新失败不影响当前状态
    }
  }

  /// 刷新订阅
  Future<void> refreshSubscription() async {
    final userProfile = state.userProfile;
    if (userProfile == null) return;

    try {
      await _subscriptionManager.handleSubscription(userProfile);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 检查是否需要显示登录页
  Future<bool> shouldShowLogin() async {
    final isEnabled = await _sessionManager.isEnabled();
    if (!isEnabled) return false;

    return !state.isLoggedIn;
  }

  /// 设置 CoolGo 功能启用状态
  Future<void> setEnabled(bool enabled) async {
    await _sessionManager.setEnabled(enabled);
  }

  /// 获取 CoolGo 功能启用状态
  Future<bool> isEnabled() async {
    return await _sessionManager.isEnabled();
  }
}

/// 便捷访问器
final coolGoAuth = CoolGoAuth.new;
