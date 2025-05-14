import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  List<ExpenseModel> _expenses = [];
  double _totalExpenses = 0;
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ExpenseModel> get expenses => _expenses;
  double get totalExpenses => _totalExpenses;

  void setToken(String token) {
    _token = token;
  }

  void _calculateTotal() {
    _totalExpenses = _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Future<bool> addExpense({
    required String category,
    required String description,
    required double amount,
    required String subCategory,
    // required String date,
    String pic = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate token
      if (_token == null || _token!.isEmpty) {
        _error = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      const url = 'http://10.0.2.2:3000/expenses'; // For Android Emulator
      // final url = 'http://localhost:3000/expenses'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/expenses'; // For physical device

      debugPrint('Making API request to: $url');

      // Validate input data
      if (amount <= 0) {
        _error = 'Amount must be greater than 0';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (description.trim().isEmpty) {
        _error = 'Description cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (category.trim().isEmpty) {
        _error = 'Category cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (subCategory.trim().isEmpty) {
        _error = 'Sub-category cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final requestData = {
        "category": category.trim(),
        "description": description.trim(),
        "subCategory": subCategory.trim(),
        "amount": amount.toDouble(), // Ensure amount is sent as double
        "date": now.toUtc().toIso8601String(), // Convert to UTC ISO string
        "pic": pic.isEmpty ? null : pic.trim(), // Send null if pic is empty
      };

      final headers = {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };

      debugPrint('Request data: $requestData');
      debugPrint('Request headers: $headers');

      // First, try to encode the request data to ensure it's valid JSON
      try {
        json.encode(requestData);
      } catch (e) {
        debugPrint('Error encoding request data: $e');
        _error = 'Invalid request data format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _dio.post(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              true, // Accept all status codes for better error handling
        ),
        data: requestData,
      );

      debugPrint('Full response: ${response.toString()}');

      if (response.statusCode == 400) {
        _error =
            'Invalid request: ${response.data['message'] ?? 'Unknown error'}';
        if (response.data['details'] != null) {
          debugPrint('Validation errors: ${response.data['details']}');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('Response received with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      debugPrint('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final expense =
            ExpenseModel.fromJson(Map<String, dynamic>.from(response.data));
        _expenses.add(expense);
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to add expense';
        final errorDetails = response.data['details'] ?? '';
        final validationErrors = response.data['errors'] ?? {};

        String fullErrorMessage = errorMessage;
        if (errorDetails.isNotEmpty) {
          fullErrorMessage += ': $errorDetails';
        }
        if (validationErrors.isNotEmpty) {
          fullErrorMessage += '\nValidation errors: $validationErrors';
        }

        _error = fullErrorMessage;
        _isLoading = false;
        debugPrint('Server error: $_error');
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response?.data != null) {
        debugPrint('Error response data: ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please log in again.';
        } else if (e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
          if (e.response?.data['details'] != null) {
            errorMessage += ': ${e.response?.data['details']}';
          }
          if (e.response?.data['errors'] != null) {
            errorMessage +=
                '\nValidation errors: ${e.response?.data['errors']}';
          }
        } else {
          errorMessage =
              'Server error: ${e.response?.statusCode} - ${e.response?.data}';
        }
      } else {
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
        _expenses = List<ExpenseModel>.from(response.data.map(
            (data) => ExpenseModel.fromJson(Map<String, dynamic>.from(data))));
        _calculateTotal();
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
        _expenses.removeWhere((expense) => expense.id == expenseId);
        _calculateTotal();
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
            _expenses.indexWhere((expense) => expense.id == expenseId);
        if (index != -1) {
          _expenses[index] =
              ExpenseModel.fromJson(Map<String, dynamic>.from(response.data));
        }
        _calculateTotal();
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

  List<ExpenseModel> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}
