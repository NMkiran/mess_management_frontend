import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ExpenseProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _expenses = [];
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get expenses => _expenses;

  void setToken(String token) {
    _token = token;
  }

  Future<bool> addExpense({
    required String category,
    required String description,
    required double amount,
    required String subCategory,
    String pic = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = 'http://10.0.2.2:3000/expenses'; // For Android Emulator
      // final url = 'http://localhost:3000/expenses'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/expenses'; // For physical device

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
          "category": category,
          "description": description,
          "amount": amount,
          "subCategory": subCategory,
          "pic": pic,
        }),
      );

      debugPrint('Response received with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        _expenses.add(response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Failed to add expense';
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

  Future<void> fetchExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = 'http://10.0.2.2:3000/expenses'; // For Android Emulator
      // final url = 'http://localhost:3000/expenses'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/expenses'; // For physical device

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _expenses = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to fetch expenses';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url =
          'http://10.0.2.2:3000/expenses/$expenseId'; // For Android Emulator
      // final url = 'http://localhost:3000/expenses/$expenseId'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/expenses/$expenseId'; // For physical device

      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _expenses.removeWhere((expense) => expense['_id'] == expenseId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete expense';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense({
    required String expenseId,
    required String category,
    required String description,
    required double amount,
    required String subCategory,
    String pic = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url =
          'http://10.0.2.2:3000/expenses/$expenseId'; // For Android Emulator
      // final url = 'http://localhost:3000/expenses/$expenseId'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/expenses/$expenseId'; // For physical device

      final response = await _dio.put(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
        data: json.encode({
          "category": category,
          "description": description,
          "amount": amount,
          "subCategory": subCategory,
          "pic": pic,
        }),
      );

      if (response.statusCode == 200) {
        final index =
            _expenses.indexWhere((expense) => expense['_id'] == expenseId);
        if (index != -1) {
          _expenses[index] = response.data;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update expense';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
