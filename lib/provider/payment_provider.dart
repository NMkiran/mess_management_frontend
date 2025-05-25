import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';
import 'package:mess_management/utilities/global_variable.dart';

import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  static const String _boxName = 'payments';
  late final Box _box;
  List<PaymentModel> _payments = [];
  double _totalPayments = 0;
  final _dioClient = DioClient();
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
    _dioClient.setAuthToken(token);
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
    print("object");
    try {
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
        "imageUrl": imageUrl.trim(),
      };


      // Add upiSubType only for UPI payments
      if (paymentMethod == 'UPI') {
        requestData['upiSubType'] = upiSubType;
      }
      print("Request data: $requestData");
      Map response = await dio(
        endPoint: ApiUrls().addPayment,
        method: 'POST',
        body: requestData,

      );
      print('Response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {

        final payment =
            PaymentModel.fromJson(Map<String, dynamic>.from(response['data']));
        _payments.add(payment);
        _calculateTotal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorMessage =
            response['data']['message'] ?? 'Failed to add payment';
        final errorDetails = response['data']['details'] ?? '';
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

  Future<void> fetchPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.payments}';
      final response = await _dioClient.dio.get(url);

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

  Future<bool> deletePayment(String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.paymentById(paymentId)}';
      final response = await _dioClient.dio.delete(url);

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
