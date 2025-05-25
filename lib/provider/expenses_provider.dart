import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mess_management/utilities/global_variable.dart';
import '../models/expenses_model.dart';
import '../dio/dio_client.dart';
import '../dio/dio_exceptions.dart';
import '../dio/api_urls.dart';

class ExpensesProvider extends ChangeNotifier {
  List<ExpensesModel> _expenses = [];
  double _totalExpenses = 0;
  final _dioClient = DioClient();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ExpensesModel> get expenses => _expenses;
  double get totalExpenses => _totalExpenses;

  // void setToken(String token) {
  //   _token = token;
  //   _dioClient.setAuthToken(token);
  // }

  Future<bool> addExpense({
    required String name,
    required String type,
    required double amount,
    required String description,
    required String category,
    required String subCategory,
    required String paymentMethod,
    required String upiSubType,
    String imageUrl = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (globalToken == null || globalToken!.isEmpty) {
        _error = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = '${ApiUrls.baseUrl}${ApiUrls.payments}';

      // Validate input data
      if (amount <= 0) {
        _error = 'Amount must be greater than 0';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (name.trim().isEmpty) {
        _error = 'Name cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final requestData = {
        "name": name.trim(),
        "type": type,
        "amount": amount,
        "description": description.trim(),
        "category": category.trim(),
        "subCategory": subCategory.trim(),
        "paymentMethod": paymentMethod,
        "upiSubType": upiSubType,
        "imageUrl": imageUrl.trim(),
      };

      final response = await _dioClient.dio.post(
        url,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final expense =
            ExpensesModel.fromJson(Map<String, dynamic>.from(response.data));
        _expenses.add(expense);
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to add expense';
        final errorDetails = response.data['details'] ?? '';
        _error = errorDetails.isNotEmpty
            ? '$errorMessage: $errorDetails'
            : errorMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _error = DioExceptions.handleError(e);
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

  Future<void> fetchExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.payments}';
      final response = await _dioClient.dio.get(url);

      if (response.statusCode == 200) {
        _expenses = List<ExpensesModel>.from(response.data.map(
            (data) => ExpensesModel.fromJson(Map<String, dynamic>.from(data))));
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to fetch expenses';
        _isLoading = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      _error = DioExceptions.handleError(e);
      _isLoading = false;
      notifyListeners();
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
      final url = '${ApiUrls.baseUrl}${ApiUrls.paymentById(expenseId)}';
      final response = await _dioClient.dio.delete(url);

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
    } on DioException catch (e) {
      _error = DioExceptions.handleError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _calculateTotal() {
    _totalExpenses = _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<ExpensesModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  double getCurrentMonthTotal() {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _expenses
        .where((expense) =>
            '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}' ==
            currentMonth)
        .fold(0, (sum, expense) => sum + expense.amount);
  }
}
