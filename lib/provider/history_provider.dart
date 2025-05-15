import 'package:flutter/foundation.dart';
import 'package:mess_management/models/history_model.dart';
import 'package:mess_management/core/services/api_service.dart';
import 'package:mess_management/core/config/api_config.dart';

class HistoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<History> _history = [];
  bool _isLoading = false;
  String? _error;

  List<History> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

      final queryParams = <String, dynamic>{};
      if (entityType != null) queryParams['entity_type'] = entityType;
      if (entityId != null) queryParams['entity_id'] = entityId;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        ApiConfig.history,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'];
      _history = data.map((json) => History.fromJson(json)).toList();

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

      final response = await _apiService.post(
        ApiConfig.history,
        data: history.toJson(),
      );

      final newHistory = History.fromJson(response.data['data']);
      _history.insert(0, newHistory); // Add to the beginning of the list

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

      await _apiService.delete(ApiConfig.history);
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
