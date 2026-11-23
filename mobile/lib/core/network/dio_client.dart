import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/local_storage_service.dart';
import '../constants/api_constants.dart';

class DioClient {
  final Dio dio;
  final LocalStorageService _storage;

  DioClient(this._storage)
      : dio = Dio(
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
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('--> ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint(
              '<!- ERROR[${error.response?.statusCode}] ${error.requestOptions.uri}: ${error.message}',
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Helper untuk mengambil pesan error ramah user dari DioException.
  static String parseErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      }
      return 'Terjadi kesalahan jaringan (${error.response?.statusCode ?? 'unknown'}).';
    }
    return 'Terjadi kesalahan tak terduga.';
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return DioClient(storage);
});
