import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_model.dart';
import 'package:dio/dio.dart';

class PaymentProvider extends ChangeNotifier {
  static const String _boxName = 'payments';
  late final Box _box;
  List<PaymentModel> _payments = [];
  double _totalPayments = 0;
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  String? _token;

  PaymentProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox(_boxName);
    await _loadPayments();
  }

  Future<void> _loadPayments() async {
    final List<dynamic> paymentsJson = _box.get('payments', defaultValue: []);
    if (paymentsJson.isEmpty) {
      // Load dummy data if no data exists
      // _payments = DummyData.getSamplePayments();
      await _box.put('payments', _payments.map((p) => p.toJson()).toList());
    } else {
      _payments = paymentsJson
          .map((json) => PaymentModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    _calculateTotal();
    notifyListeners();
  }

  void _calculateTotal() {
    _totalPayments = _payments.fold(0, (sum, payment) => sum + payment.amount);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentModel> get payments => _payments;
  double get totalPayments => _totalPayments;

  void setToken(String token) {
    _token = token;
  }

  Future<bool> addPayment({
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
      if (_token == null || _token!.isEmpty) {
        _error = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      const url = 'http://10.0.2.2:3000/payments'; // For Android Emulator
      // final url = 'http://localhost:3000/payments'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/payments'; // For physical device

      debugPrint('Making API request to: $url');

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

      final headers = {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };

      debugPrint('Request data: $requestData');
      debugPrint('Request headers: $headers');

      final response = await _dio.post(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: requestData,
      );

      debugPrint('Response received with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payment =
            PaymentModel.fromJson(Map<String, dynamic>.from(response.data));
        _payments.add(payment);
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to add payment';
        final errorDetails = response.data['details'] ?? '';
        _error = errorDetails.isNotEmpty
            ? '$errorMessage: $errorDetails'
            : errorMessage;
        _isLoading = false;
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

  Future<void> fetchPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const url = 'http://10.0.2.2:3000/payments'; // For Android Emulator
      // final url = 'http://localhost:3000/payments'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/payments'; // For physical device

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _payments = List<PaymentModel>.from(response.data.map(
            (data) => PaymentModel.fromJson(Map<String, dynamic>.from(data))));
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to fetch payments';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePayment(String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url =
          'http://10.0.2.2:3000/payments/$paymentId'; // For Android Emulator
      // final url = 'http://localhost:3000/payments/$paymentId'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/payments/$paymentId'; // For physical device

      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _payments.removeWhere((payment) => payment.id == paymentId);
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete payment';
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

  List<PaymentModel> getPaymentsByMemberId(String memberId) {
    return _payments.where((payment) => payment.id == memberId).toList();
  }

  // List<PaymentModel> getPaymentsByMonth(String month) {
  //   return _payments.where((payment) => payment.month == month).toList();
  // }

  List<PaymentModel> getPaymentsByDateRange(DateTime start, DateTime end) {
    return _payments
        .where((payment) =>
            payment.date.isAfter(start.subtract(const Duration(days: 1))) &&
            payment.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // double getTotalPaymentsForMonth(String month) {
  //   return getPaymentsByMonth(month)
  //       .fold(0, (sum, payment) => sum + payment.amount);
  // }

  double getCurrentMonthTotal() {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    // return getTotalPaymentsForMonth(currentMonth);
    return _payments
        .where((payment) =>
            '${payment.date.year}-${payment.date.month.toString().padLeft(2, '0')}' ==
            currentMonth)
        .fold(0, (sum, payment) => sum + payment.amount);
  }
}
