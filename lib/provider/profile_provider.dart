import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _boxName = 'profile';
  late final Box _box;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _roomNumber = '';

  ProfileProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox(_boxName);
    _loadUserData();
  }

  void _loadUserData() {
    _name = _box.get('name', defaultValue: 'John Doe');
    _email = _box.get('email', defaultValue: 'john.doe@example.com');
    _phone = _box.get('phone', defaultValue: '+91 9876543210');
    _roomNumber = _box.get('roomNumber', defaultValue: 'A-101');
    notifyListeners();
  }

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get roomNumber => _roomNumber;

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? roomNumber,
  }) async {
    if (name != null) {
      _name = name;
      await _box.put('name', name);
    }
    if (email != null) {
      _email = email;
      await _box.put('email', email);
    }
    if (phone != null) {
      _phone = phone;
      await _box.put('phone', phone);
    }
    if (roomNumber != null) {
      _roomNumber = roomNumber;
      await _box.put('roomNumber', roomNumber);
    }
    notifyListeners();
  }

  Future<void> clearUserData() async {
    await _box.clear();
  }
}
