import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map) {
      // Custom ASP.NET Core error format: { "message": "..." }
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return ApiException(data['message'].toString(), statusCode: statusCode);
      }

      // ASP.NET Core ModelState ProblemDetails: { "errors": { "Field": ["msg"] } }
      if (data['errors'] is Map) {
        final errorsMap = data['errors'] as Map;
        for (final entry in errorsMap.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            return ApiException(value.first.toString(), statusCode: statusCode);
          }
        }
      }

      if (data['title'] != null && data['title'].toString().isNotEmpty) {
        return ApiException(data['title'].toString(), statusCode: statusCode);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'Koneksi ke server melebihi batas waktu. Coba lagi sebentar.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Tidak dapat terhubung ke server Foxio. Pastikan backend sedang berjalan.',
        );
      case DioExceptionType.cancel:
        return const ApiException('Permintaan dibatalkan.');
      default:
        if (statusCode == 401) {
          return const ApiException(
            'Sesi Anda telah berakhir. Silakan login kembali.',
            statusCode: 401,
          );
        }
        return ApiException(
          'Terjadi kesalahan jaringan (${statusCode ?? 'unknown'}).',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
