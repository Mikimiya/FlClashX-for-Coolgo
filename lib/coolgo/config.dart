/// CoolGo 配置常量
class CoolGoConfig {
  CoolGoConfig._();

  /// 网站地址
  static const String websiteUrl = 'https://coolgo.network';

  /// 注册页面地址
  static const String registerUrl =
      'https://coolgo.network/register?trial=1&productId=5';

  /// 找回密码地址
  static const String forgotPasswordUrl =
      'https://coolgo.network/forgot-password';

  /// API 地址列表（多地址轮询）
  static const List<String> apiUrls = [
    'https://billing.coolgo.network',
    'https://billing.coolgo.cloud',
    'https://billing.coolgo.cc',
  ];

  /// 测试 API 地址
  static const List<String> testApiUrls = [
    'http://localhost:3010',
  ];

  /// 是否使用测试环境
  static const bool useTestApi = false;

  /// 获取当前使用的 API 地址列表
  static List<String> get currentApiUrls => useTestApi ? testApiUrls : apiUrls;

  /// 登录接口路径
  static const String loginPath = '/auth/login';

  /// 获取用户信息接口路径
  static const String profilePath = '/user/profile';

  /// CoolGo 订阅的标签名称
  static const String profileLabel = 'CoolGo';

  /// SharedPreferences 键名
  static const String tokenKey = 'coolgo_token';
  static const String userKey = 'coolgo_user';
  static const String rememberKey = 'coolgo_remember';
  static const String profileIdKey = 'coolgo_profile_id';
  static const String enabledKey = 'coolgo_enabled';

  /// 订阅标记头
  static const String managedHeader = 'x-coolgo-managed';

  /// API 请求超时时间
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Token 提前过期时间（提前5分钟认为过期）
  static const Duration tokenExpiryBuffer = Duration(minutes: 5);
}
