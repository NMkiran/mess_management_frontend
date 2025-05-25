import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';

import 'package:mess_management/provider/profile_provider.dart';
import 'package:mess_management/utilities/global_variable.dart';
import 'package:provider/provider.dart';


class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  Future<bool> login({
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('Attempting login for username: $username');
      Map<String, dynamic> response = await dio(
        method: 'POST',
        endPoint: ApiUrls.login,
        body: {
          'username': username,
          'password': password,
        },
      );
      print('Auth Response: $response');

      if (response['statusCode'] == 200) {

        final data = response['data'];
        _token = data['token'];
        print('Token received: $_token');
        globalToken = _token!;

        // Get user ID - handle both formats where user info could be nested
        var userInfo = data['user'] ?? data;
        print('User info from response: $userInfo');

        // Look for _id first, then id
        final userId =
            userInfo is Map ? (userInfo['_id'] ?? userInfo['id']) : null;
        print('Extracted user ID: $userId');

        if (userId != null) {
          print('Setting user ID in ProfileProvider: $userId');
          Provider.of<ProfileProvider>(context, listen: false)
              .setUserId(userId.toString());
        } else {
          print('Warning: No user ID found in response');
          _error = 'Could not find user ID in response';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _error = null;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        print('Login failed: $_error');
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
