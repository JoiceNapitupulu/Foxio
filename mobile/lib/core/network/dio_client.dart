import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_token_storage.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class UnauthorizedEventNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notifyUnauthorized() {
    state++;
  }
}

final unauthorizedEventProvider =
    NotifierProvider<UnauthorizedEventNotifier, int>(
  UnauthorizedEventNotifier.new,
);

class DioClient {
  final Dio dio;

  DioClient({
    required SecureTokenStorage tokenStorage,
    VoidCallback? onUnauthorized,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  static String parseErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is DioException) {
      return ApiException.fromDioException(error).message;
    }
    return 'Terjadi kesalahan tak terduga.';
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureTokenStorageProvider);
  return DioClient(
    tokenStorage: storage,
    onUnauthorized: () {
      ref.read(unauthorizedEventProvider.notifier).notifyUnauthorized();
    },
  );
});
