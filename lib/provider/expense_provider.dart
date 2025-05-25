
import 'package:flutter/foundation.dart';
import 'package:mess_management/models/expense_model.dart';
import 'package:mess_management/core/services/api_service.dart';
import 'package:mess_management/core/config/api_config.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';
import 'package:mess_management/utilities/global_variable.dart';

import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  List<ExpenseModel> _expenses = [];
  double _totalExpenses = 0;
  // String? _token;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExpenseModel> get expenses => _expenses;
  double get totalExpenses => _totalExpenses;

  void _calculateTotal() {
    _totalExpenses = _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

//Add expanses completed
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

  Future<void> fetchExpenses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate token
      if (globalToken.isEmpty) {
        _error = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

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

      // First, try to encode the request data to ensure it's valid JSON
      Map response = await dio(
        method: 'POST',
        endPoint: ApiUrls().addExpanse,
        body: requestData,
      );
      // try {} catch (e) {
      //   debugPrint('Error encoding request data: $e');
      //   _error = 'Invalid request data format';
      //   _isLoading = false;
      //   notifyListeners();
      //   return false;
      // }

      if (response['statusCode'] == 400) {
        _error =
            'Invalid request: ${response['data']['message'] ?? 'Unknown error'}';
        if (response['data']['details'] != null) {}
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final expense = ExpenseModel.fromJson(
            Map<String, dynamic>.from(response['data'] ?? {}));

        _expenses.add(expense);
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response['statusCode'] == 401) {
        _error = 'Authentication failed. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        final errorMessage =
            response['data']['message'] ?? 'Failed to add expense';
        final errorDetails = response['data']['details'] ?? '';
        final validationErrors = response['data']['errors'] ?? {};


      final response = await _apiService.get(ApiConfig.expenses);
      final List<dynamic> data = response.data['data'];
      _expenses = data.map((json) => Expense.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();


      final response = await _apiService.post(
        ApiConfig.expenses,
        data: expense.toJson(),

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            // 'Authorization': 'Bearer $_token',
          },
        ),
      );

      final newExpense = Expense.fromJson(response.data['data']);
      _expenses.add(newExpense);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.put(
        '${ApiConfig.expenses}/${expense.id}',
        data: expense.toJson(),

      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            // 'Authorization': 'Bearer $_token',
          },
        ),
      );

      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.delete('${ApiConfig.expenses}/$id');
      _expenses.removeWhere((expense) => expense.id == id);

      final response = await _dio.put(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer $_token',
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


      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
