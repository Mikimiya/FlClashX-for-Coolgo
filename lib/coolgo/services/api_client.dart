import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flclashx/coolgo/config.dart';

/// Token 过期回调类型
typedef OnTokenExpired = void Function();

/// CoolGo API 客户端
/// 
/// 支持多 API 地址轮询，自动处理请求失败时切换到备用地址
class CoolGoApiClient {
  CoolGoApiClient({
    OnTokenExpired? onTokenExpired,
  }) : _onTokenExpired = onTokenExpired {
    _dio = Dio(BaseOptions(
      connectTimeout: CoolGoConfig.requestTimeout,
      receiveTimeout: CoolGoConfig.requestTimeout,
      sendTimeout: CoolGoConfig.requestTimeout,
    ));

    // 添加拦截器处理 Token 过期
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token 过期或无效
          _onTokenExpired?.call();
        }
        handler.next(error);
      },
    ));
  }

  late final Dio _dio;
  final OnTokenExpired? _onTokenExpired;
  
  /// 当前 API 地址索引
  int _currentApiIndex = 0;
  
  /// 获取 API 地址列表
  List<String> get _apiUrls => CoolGoConfig.currentApiUrls;

  /// 获取当前 API 基础地址
  String get _currentBaseUrl => _apiUrls[_currentApiIndex];

  /// 切换到下一个 API 地址
  void _switchToNextApi() {
    _currentApiIndex = (_currentApiIndex + 1) % _apiUrls.length;
  }

  /// 随机选择一个 API 地址作为起始
  void _randomizeStartApi() {
    _currentApiIndex = Random().nextInt(_apiUrls.length);
  }

  /// 发送 POST 请求
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      () => _dio.post<Map<String, dynamic>>(
        '$_currentBaseUrl$path',
        data: data,
        options: Options(headers: headers),
      ),
    );
  }

  /// 发送 GET 请求
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      () => _dio.get<Map<String, dynamic>>(
        '$_currentBaseUrl$path',
        options: Options(headers: headers),
      ),
    );
  }

  /// 带重试的请求方法
  /// 
  /// 如果请求失败，会自动切换到下一个 API 地址重试
  Future<Map<String, dynamic>> _requestWithRetry(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    _randomizeStartApi(); // 随机选择起始 API
    
    Exception? lastException;
    
    for (int attempt = 0; attempt < _apiUrls.length; attempt++) {
      try {
        final response = await request();
        return response.data ?? {};
      } on DioException catch (e) {
        lastException = e;
        
        // 如果是 401 错误，不需要重试其他 API
        if (e.response?.statusCode == 401) {
          rethrow;
        }
        
        // 网络错误或超时，切换到下一个 API
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.response?.statusCode == null ||
            (e.response?.statusCode ?? 0) >= 500) {
          _switchToNextApi();
          continue;
        }
        
        // 其他错误直接抛出
        rethrow;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        _switchToNextApi();
      }
    }
    
    // 所有 API 都失败了
    throw lastException ?? Exception('所有 API 地址均不可用');
  }

  /// 关闭客户端
  void close() {
    _dio.close();
  }
}
