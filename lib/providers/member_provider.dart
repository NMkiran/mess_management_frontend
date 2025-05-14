import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class MemberProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _members = [];
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get members => _members;

  void setToken(String token) {
    _token = token;
  }

  Future<bool> addMember({
    required String name,
    required String email,
    required String phoneNumber,
    required String roomNumber,
    String pic = "",
    String aadharCard = "",
    String address = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = 'http://10.0.2.2:3000/members'; // For Android Emulator
      // final url = 'http://localhost:3000/members'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/members'; // For physical device

      debugPrint('Making API request to: $url');

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
        data: json.encode({
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "pic": pic,
          "aadharCard": aadharCard,
          "address": address,
          "roomNumber": roomNumber,
        }),
      );

      debugPrint('Response received with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        _members.add(response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Failed to add member';
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

  Future<void> fetchMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = 'http://10.0.2.2:3000/members'; // For Android Emulator
      // final url = 'http://localhost:3000/members'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/members'; // For physical device

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _members = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to fetch members';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
