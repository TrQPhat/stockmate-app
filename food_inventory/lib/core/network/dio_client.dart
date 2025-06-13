import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import '../config/app_config.dart';

class DioClient {
  final Dio _dio;
  final String baseUrl;

  DioClient(this._dio, {required this.baseUrl}) {
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout =
          const Duration(milliseconds: AppConfig.requestTimeout)
      ..options.receiveTimeout =
          const Duration(milliseconds: AppConfig.requestTimeout)
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = getIt<SharedPreferences>();
          final token = prefs.getString(AppConfig.accessTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
      ));
  }
  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}
