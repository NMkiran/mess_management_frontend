import 'package:flutter/foundation.dart';
import 'package:mess_management/models/expense_model.dart';
import 'package:mess_management/core/services/api_service.dart';
import 'package:mess_management/core/config/api_config.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExpenses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

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
