import 'package:flutter/material.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  final List<Expense> _expenses = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Expense> get expenses => _expenses;

  Future<bool> addExpense({
    required String category,
    required String description,
    required double amount,
    required String subCategory,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var data = {
        "category": category,
        "description": description,
        "amount": amount,
        "subCategory": subCategory,
      };
      final response =
          await dio(endPoint: ApiUrls.addExpenses, method: 'POST', body: data);

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final expense = Expense.fromJson(response['data']['data']);
        _expenses.add(expense);
        _isLoading = false;

        notifyListeners();
        return true;
      } else {
        _error = response['data']['message'] ?? 'Failed to add expense';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
