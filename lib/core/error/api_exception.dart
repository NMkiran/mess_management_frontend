import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please try again.',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.badResponse:
        final data = error.response?.data;
        String message = 'An error occurred';

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'];
        }

        return ApiException(
          message: message,
          statusCode: error.response?.statusCode,
          data: data,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );

      default:
        return ApiException(
          message: 'An unexpected error occurred',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
    }
  }

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
