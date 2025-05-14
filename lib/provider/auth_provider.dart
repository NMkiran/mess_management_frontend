import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';

class AuthProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  Future<bool> login(
      {required String username, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      Map response = await dio(
        method: 'POST',
        endPoint: ApiUrls().login,
        body: {
          'username': username,
          'password': password,
        },
      );
      if (response['statusCode'] == 200) {
        _token = response['token'];
        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      String errorMessage;
      switch (e.type) {
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
              'Server error: ${e.response?.statusCode} - ${e.response?.data}';
          break;
        default:
          errorMessage = 'Network error: ${e.message ?? e.toString()}';
      }
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
