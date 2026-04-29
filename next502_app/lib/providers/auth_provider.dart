import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  String? _userRole;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  int? get userId => _userId;

  bool get isProvider => _userRole == 'ROLE_PROVIDER' || _userRole == 'ROLE_ADMIN';

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? token = await _storage.read(key: 'accessToken');
    _userRole = await _storage.read(key: 'userRole');
    String? idStr = await _storage.read(key: 'userId');
    _userId = idStr != null ? int.tryParse(idStr) : null;

    _isLoggedIn = token != null;
    notifyListeners();
  }


  Future<void> loginSuccess(String accessToken, String role, int id) async {
    await _storage.write(key: 'userRole', value: role);
    await _storage.write(key: 'userId', value: id.toString());

    _isLoggedIn = true;
    _userRole = role;
    _userId = id;
    notifyListeners();
  }


  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userRole');
    await _storage.delete(key: 'userId');

    _isLoggedIn = false;
    _userRole = null;
    _userId = null;
    notifyListeners();
  }
}