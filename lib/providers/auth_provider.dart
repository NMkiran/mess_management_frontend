import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'member_provider.dart';
import 'expense_provider.dart';

class AuthProvider with ChangeNotifier {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, use localhost
  // For physical device, use your computer's IP address
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:3000'; // For iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:3000'; // For physical device
  late final Dio _dio;
  bool _isLoading = false;
  String? _error;
  String? _token;

  AuthProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<bool> login(
      String username, String password, BuildContext context) async {
    debugPrint('Login attempt started for username: $username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = '$baseUrl/auth/login';
      debugPrint('Making API request to: $url');

      final response = await _dio.post(
        url,
        data: json.encode({
          "username": username,
          "password": password,
        }),
      );

      debugPrint('Response received with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['token'] != null) {
          _token = response.data['token'];
          // Share token with MemberProvider and ExpenseProvider
          if (context.mounted) {
            Provider.of<MemberProvider>(context, listen: false)
                .setToken(_token!);
          }
          _isLoading = false;
          debugPrint('Login successful, token received');
          notifyListeners();
          return true;
        } else {
          _error = 'Invalid response format: token not found';
          _isLoading = false;
          debugPrint('Login failed: $_error');
          notifyListeners();
          return false;
        }
      } else {
        _error = response.data['message'] ??
            'Login failed with status code: ${response.statusCode}';
        _isLoading = false;
        debugPrint('Login failed: $_error');
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection and server status.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Could not connect to the server. Please check:\n'
              '1. Server is running\n'
              '2. IP address is correct\n'
              '3. Port 3000 is open\n'
              '4. Device and server are on same network';
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
      debugPrint('DioException occurred: $errorMessage');
      debugPrint('Error details: ${e.toString()}');
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      debugPrint('Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
