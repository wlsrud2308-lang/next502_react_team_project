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

    String? storedId = await _storage.read(key: 'userId');
    _userId = storedId != null ? int.tryParse(storedId) : null;

    _isLoggedIn = token != null;
    notifyListeners();
  }


  Future<void> loginSuccess(String accessToken, String role, int id) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'userRole', value: role);
    await _storage.write(key: 'userId', value: id.toString()); // 로컬 저장

    _isLoggedIn = true;
    _userRole = role;
    _userId = id;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll(); // 모든 정보(토큰, 롤, ID) 일괄 삭제

    _isLoggedIn = false;
    _userRole = null;
    _userId = null;
    notifyListeners();
  }
}
