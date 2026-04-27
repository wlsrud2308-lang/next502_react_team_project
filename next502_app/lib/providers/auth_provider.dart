import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? token = await _storage.read(key: 'accessToken');
    _isLoggedIn = token != null;
    notifyListeners();
  }

  Future<void> loginSuccess() async {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    _isLoggedIn = false;
    notifyListeners();
  }
}