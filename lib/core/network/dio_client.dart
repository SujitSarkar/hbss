import 'package:dio/dio.dart';

import 'package:maori_health/core/config/app_constants.dart';
import 'package:maori_health/core/config/env_config.dart';
import 'package:maori_health/core/network/interceptors/auth_interceptor.dart';
import 'package:maori_health/core/network/interceptors/network_log_interceptor.dart';
import 'package:maori_health/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';
import 'package:maori_health/core/storage/secure_storage_service.dart';

class DioClient {
  late final Dio _dio;

  DioClient({required SecureStorageService secureStorage, required LocalCacheService cache}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
      RefreshTokenInterceptor(secureStorage: secureStorage, cache: cache),
      if (EnvConfig.isDev) NetworkLogInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
