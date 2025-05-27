import 'package:flutter/material.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/dio/dio_client.dart';
import 'package:mess_management/utilities/global_variable.dart';

class ProfileProvider extends ChangeNotifier {
  String _userId = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _username = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get username => _username;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUserId(String userId) {
    print('ProfileProvider.setUserId called with: $userId');
    _userId = userId;
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (_userId.isEmpty) {
      _error = 'No user ID available';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (globalToken.isEmpty) {
      _error = 'No auth token available';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching profile for user ID: $_userId');
      final response = await dio(
        method: 'GET',
        // Use GET /users to fetch all users, then filter by ID
        endPoint: ApiUrls.getMembers,
        headers: {
          'Authorization': 'Bearer $globalToken',
        },
      );

      print('Profile API Response: $response');

      if (response['statusCode'] == 200) {
        final allUsers =
            response['data'] is List ? response['data'] : [response['data']];

        // Find user by ID in the list
        final userData = allUsers.firstWhere(
          (user) =>
              user['_id'].toString() == _userId ||
              user['id'].toString() == _userId,
          orElse: () => null,
        );

        if (userData != null) {
          print('User data found: $userData');
          _name = userData['name'] ?? '';
          _email = userData['email'] ?? '';
          _phone = userData['phoneNumber'] ?? '';
          _username = _email.split('@')[0]; // Use email username as username
          _error = null;

          print('Profile updated successfully');
          print('Name: $_name');
          print('Email: $_email');
          print('Phone: $_phone');
          print('Username: $_username');
        } else {
          _error = 'User not found';
          print('Error: User not found in response data');
        }
      } else {
        _error = response['message'] ?? 'Failed to fetch profile';
        print('Error fetching profile: $_error');
      }
    } catch (e) {
      print('Exception in fetchUserProfile: $e');
      _error = 'Failed to fetch profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await dio(
        method: 'PUT',
        endPoint: '${ApiUrls.getMembers}/$_userId',
        body: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phoneNumber': phone,
        },
      );

      if (response['statusCode'] == 200) {
        await fetchUserProfile(); // Refresh profile data
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearUserData() {
    _userId = '';
    _name = '';
    _email = '';
    _phone = '';
    _username = '';
    _error = null;
    notifyListeners();
  }
}
