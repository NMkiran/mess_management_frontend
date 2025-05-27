import 'package:flutter/foundation.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';
import 'package:mess_management/models/history_model.dart';
import 'package:mess_management/models/history_summary_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mess_management/utilities/global_variable.dart';

class HistoryProvider with ChangeNotifier {
  // final ApiService _apiService = ApiService();
  List<History> _history = [];
  HistorySummary? _summary;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _expenses = [];

  List<History> get history => _history;
  HistorySummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get payments => _payments;
  List<Map<String, dynamic>> get expenses => _expenses;

  Future<void> fetchHistorySummary() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (globalToken.isEmpty) {
        _error = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch payments
      final paymentsUrl = Uri.parse(ApiUrls.baseUrl + ApiUrls.addPayment);
      final paymentsRequest = http.Request('GET', paymentsUrl);
      paymentsRequest.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $globalToken',
      });

      final paymentsResponse = await paymentsRequest.send();
      final paymentsBody = await paymentsResponse.stream.bytesToString();

      if (paymentsResponse.statusCode == 200) {
        _payments = List<Map<String, dynamic>>.from(json.decode(paymentsBody));
      } else {
        _error = 'Failed to fetch payments: ${paymentsResponse.reasonPhrase}';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch expenses
      final expensesUrl = Uri.parse(ApiUrls.baseUrl + ApiUrls.addExpenses);
      final expensesRequest = http.Request('GET', expensesUrl);
      expensesRequest.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $globalToken',
      });

      final expensesResponse = await expensesRequest.send();
      final expensesBody = await expensesResponse.stream.bytesToString();

      if (expensesResponse.statusCode == 200) {
        final expensesData = json.decode(expensesBody);
        _expenses = List<Map<String, dynamic>>.from(expensesData['data'] ?? []);
      } else {
        _error = 'Failed to fetch expenses: ${expensesResponse.reasonPhrase}';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Calculate summary
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      double todayIncome = 0;
      double todayExpenses = 0;
      double thisMonthIncome = 0;
      double thisMonthExpenses = 0;
      double allTimeIncome = 0;
      double allTimeExpenses = 0;

      // Process payments
      for (var payment in _payments) {
        final amount = (payment['amount'] ?? 0).toDouble();
        final createdAt = DateTime.parse(payment['createdAt']);

        allTimeIncome += amount;
        if (createdAt.isAfter(firstDayOfMonth)) {
          thisMonthIncome += amount;
        }
        if (createdAt.isAfter(today)) {
          todayIncome += amount;
        }
      }

      // Process expenses
      for (var expense in _expenses) {
        final amount = (expense['amount'] ?? 0).toDouble();
        final createdAt = DateTime.parse(expense['createdAt']);

        allTimeExpenses += amount;
        if (createdAt.isAfter(firstDayOfMonth)) {
          thisMonthExpenses += amount;
        }
        if (createdAt.isAfter(today)) {
          todayExpenses += amount;
        }
      }

      _summary = HistorySummary(
        todayIncome: todayIncome,
        todayExpenses: todayExpenses,
        thisMonthIncome: thisMonthIncome,
        thisMonthExpenses: thisMonthExpenses,
        allTimeIncome: allTimeIncome,
        allTimeExpenses: allTimeExpenses,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchHistory({
    String? entityType,
    String? entityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (globalToken.isEmpty) {
        _error = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final queryParams = <String, dynamic>{};
      if (entityType != null) queryParams['entity_type'] = entityType;
      if (entityId != null) queryParams['entity_id'] = entityId;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final url = Uri.parse(ApiUrls.baseUrl + ApiUrls.history)
          .replace(queryParameters: queryParams);
      final request = http.Request('GET', url);

      request.headers.addAll({
        'Authorization': 'Bearer $globalToken',
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        _history = (data['data'] as List)
            .map((json) => History.fromJson(json))
            .toList();
      } else {
        _error = 'Failed to fetch history: ${response.reasonPhrase}';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addHistory(History history) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // final response = await dio.post(
      //   ApiUrls.history,
      //   data: history.toJson(),
      // );

      // final newHistory = History.fromJson(response.data['data']);
      // _history.insert(0, newHistory); // Add to the beginning of the list

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // await _apiService.delete(ApiConfig.history);
      _history.clear();

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

  // Helper method to create history entries for different actions
  History createHistoryEntry({
    required String action,
    required String description,
    required String performedBy,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) {
    return History(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      action: action,
      description: description,
      performedBy: performedBy,
      timestamp: DateTime.now(),
      metadata: metadata,
      entityType: entityType,
      entityId: entityId,
    );
  }
}
