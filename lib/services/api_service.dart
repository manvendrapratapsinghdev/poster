import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../utils/auth_utils.dart';

class BaseApiService {
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  BaseApiService([Dio? dio])
      : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.backedBaseUrl)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach access token to every request
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final retries = e.requestOptions.extra["retries"] ?? 0;
        final context = e.requestOptions.extra['context'] as BuildContext?;
        final isRefreshTokenRequest =
            e.requestOptions.extra['isRefreshTokenRequest'] == true;

        // Handle 403 Unauthorized globally
        if (e.response?.statusCode == 403) {
          await handleUnauthorized();

          if (isRefreshTokenRequest) {
            return handler.next(e);
          }
        }

        if (e.response?.statusCode == 401 &&
            retries < 3 &&
            !isRefreshTokenRequest) {
          final newToken = await _refreshToken(context: context);
          if (newToken != null) {
            final requestOptions = e.requestOptions;
            requestOptions.headers["Authorization"] = "Bearer $newToken";
            requestOptions.extra["retries"] = retries + 1;

            final cloneReq = await _dio.fetch(requestOptions);
            return handler.resolve(cloneReq);
          }
        }

        return handler.next(e);
      },
    ));
  }

  Future<String?> _refreshToken({BuildContext? context}) async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {"refresh_token": refreshToken},
        options: Options(
          extra: {
            if (context != null) 'context': context,
            'isRefreshTokenRequest': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        await _storage.write(key: 'access_token', value: newAccessToken);

        if (response.data['refresh_token'] != null) {
          await _storage.write(
              key: 'refresh_token', value: response.data['refresh_token']);
        }

        return newAccessToken;
      } else if (response.statusCode == 403 && context != null) {
        await handleUnauthorized();
      }
    } catch (e) {
      if (e is DioException &&
          e.response?.statusCode == 403 &&
          context != null) {
        await handleUnauthorized();
      }
      print("Refresh token failed: $e");
    }
    return null;
  }

  /// GET
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, BuildContext? context}) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        extra: context != null ? {'context': context} : {},
      ),
    );
  }

  /// POST
  Future<Response> post(String path, {dynamic data, BuildContext? context}) async {
    return _dio.post(
      path,
      data: data,
      options: Options(
        extra: context != null ? {'context': context} : {},
      ),
    );
  }

  /// PUT
  Future<Response> put(String path, {dynamic data, BuildContext? context}) async {
    return _dio.put(
      path,
      data: data,
      options: Options(
        extra: context != null ? {'context': context} : {},
      ),
    );
  }

  /// DELETE
  Future<Response> delete(String path, {BuildContext? context}) async {
    return _dio.delete(
      path,
      options: Options(
        extra: context != null ? {'context': context} : {},
      ),
    );
  }

  Dio get dio => _dio;
}
