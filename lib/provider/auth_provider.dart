import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'member_provider.dart';
import 'expense_provider.dart';

class AuthProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  Future<bool> login(
      String username, String password, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = 'http://10.0.2.2:3000/auth/login'; // For Android Emulator
      // final url = 'http://localhost:3000/auth/login'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/auth/login'; // For physical device

      debugPrint('Making API request to: $url');

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'username': username,
          'password': password,
        },
      );

      debugPrint('Response received with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        _token = response.data['token'];
        _isLoading = false;
        notifyListeners();

        // Share token with MemberProvider and ExpenseProvider
        if (context.mounted) {
          Provider.of<MemberProvider>(context, listen: false).setToken(_token!);
          Provider.of<ExpenseProvider>(context, listen: false)
              .setToken(_token!);
        }
        return true;
      } else {
        _error = response.data['message'] ?? 'Login failed';
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
}
