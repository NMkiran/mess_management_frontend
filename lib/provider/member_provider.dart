import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';

import '../models/member_model.dart';

class MemberProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _error;
  List<MemberModel> _members = [];
  String? _token;

  // Getters
  List<MemberModel> get members => _members;
  List<MemberModel> get activeMembers =>
      _members.where((m) => m.isActive).toList();
  int get totalMembers => _members.length;
  int get activeCount => activeMembers.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) {
    _token = token;
  }

  // Member operations
  Future<bool> addMember({
    required String name,
    required String roomNumber,
    required String phoneNumber,
    required String email,
    String pic = "",
    String aadharCard = "",
    String address = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await dio(method: 'POST', endPoint: ApiUrls().addMember, body: {
        "name": name,
        "roomNumber": roomNumber,
        "phoneNumber": phoneNumber,
        "email": email,
        "pic": pic,
        "aadharCard": aadharCard,
        "address": address,
      });

      if (response['statusCode'] == 200) {
        final member =
            MemberModel.fromJson(Map<String, dynamic>.from(response['data']));
        _members.add(member);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['data']['message'] ?? 'Failed to add member';
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

  Future<void> fetchMembers() async {
    print("Fetching members...");
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await dio(
        method: 'GET',
        endPoint: ApiUrls().getMembers,
      );
      // print("Response data: ${response['data']['data']}");

      if (response['statusCode'] == 200) {
        final List<dynamic> membersData = response['data']['data'];
        _members = membersData
            .map(
                (data) => MemberModel.fromJson(Map<String, dynamic>.from(data)))
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Failed to fetch members';
        _isLoading = false;
        notifyListeners();
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
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMember(MemberModel updatedMember) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url =
          'http://10.0.2.2:3000/members/${updatedMember.id}'; // For Android Emulator
      // final url = 'http://localhost:3000/members/${updatedMember.id}'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/members/${updatedMember.id}'; // For physical device

      final response = await _dio.put(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
        data: json.encode(updatedMember.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _members.indexWhere((m) => m.id == updatedMember.id);
        if (index != -1) {
          _members[index] =
              MemberModel.fromJson(Map<String, dynamic>.from(response.data));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update member';
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

  Future<bool> deleteMember(String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url =
          'http://10.0.2.2:3000/members/$memberId'; // For Android Emulator
      // final url = 'http://localhost:3000/members/$memberId'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/members/$memberId'; // For physical device

      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
      );

      if (response.statusCode == 200) {
        _members.removeWhere((m) => m.id == memberId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete member';
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

  Future<bool> toggleMemberStatus(String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final member = _members.firstWhere((m) => m.id == memberId);
      final url =
          'http://10.0.2.2:3000/members/$memberId/toggle-status'; // For Android Emulator
      // final url = 'http://localhost:3000/members/$memberId/toggle-status'; // For iOS Simulator
      // final url = 'http://192.168.1.100:3000/members/$memberId/toggle-status'; // For physical device

      final response = await _dio.put(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
        data: json.encode({
          "isActive": !member.isActive,
        }),
      );

      if (response.statusCode == 200) {
        final index = _members.indexWhere((m) => m.id == memberId);
        if (index != -1) {
          _members[index] =
              MemberModel.fromJson(Map<String, dynamic>.from(response.data));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update member status';
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

  // Search and filter methods
  List<MemberModel> searchMembers(String query) {
    query = query.toLowerCase();
    return _members.where((member) {
      return member.name.toLowerCase().contains(query) ||
          member.roomNumber.toLowerCase().contains(query) ||
          member.email.toLowerCase().contains(query);
    }).toList();
  }
}
