import 'package:dio/dio.dart';

class DioExceptions {
  static String handleError(DioException error) {
    String errorMessage;
    if (error.response?.data != null) {
      if (error.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (error.response?.data['message'] != null) {
        errorMessage = error.response?.data['message'];
        if (error.response?.data['details'] != null) {
          errorMessage += ': ${error.response?.data['details']}';
        }
      } else {
        errorMessage =
            'Server error: ${error.response?.statusCode} - ${error.response?.data}';
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Could not connect to the server. Please check if the server is running.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Server response timeout. Please try again.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage =
              'Request timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          errorMessage =
              'Server error: ${error.response?.statusCode} - ${error.response?.data}';
          break;
        default:
          errorMessage = 'Network error: ${error.message ?? error.toString()}';
      }
    }
    return errorMessage;
  }
}
