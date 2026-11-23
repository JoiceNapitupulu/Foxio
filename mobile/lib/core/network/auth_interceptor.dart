import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureTokenStorage tokenStorage;
  final VoidCallback? onUnauthorized;

  AuthInterceptor({
    required this.tokenStorage,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (kDebugMode) {
      debugPrint('--> ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '<!- ERROR[${err.response?.statusCode}] ${err.requestOptions.uri}: ${err.message}',
      );
    }

    final path = err.requestOptions.path;
    final isAuthEndpoint =
        path.endsWith(ApiConstants.login) || path.endsWith(ApiConstants.register);

    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      await tokenStorage.clearAll();
      onUnauthorized?.call();
    }

    handler.next(err);
  }
}
