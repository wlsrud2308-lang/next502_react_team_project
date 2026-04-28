import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  String? _userRole; // 권한 정보를 저장할 변수 추가

  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole; // 외부에서 권한을 확인할 때 사용

  // 임대인(PROVIDER)인지 확인하는 편리한 도구
  bool get isProvider => _userRole == 'ROLE_PROVIDER' || _userRole == 'ROLE_ADMIN';

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? token = await _storage.read(key: 'accessToken');
    // 앱을 켰을 때 저장된 권한 정보도 함께 불러옵니다.
    _userRole = await _storage.read(key: 'userRole');

    _isLoggedIn = token != null;
    notifyListeners();
  }

  // ⭐ 핵심 수정: String accessToken과 String role을 받도록 변경
  Future<void> loginSuccess(String accessToken, String role) async {
    _isLoggedIn = true;
    _userRole = role; // 로그인 성공 시 전달받은 권한 저장
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userRole'); // 권한 정보도 함께 삭제

    _isLoggedIn = false;
    _userRole = null;
    notifyListeners();
  }
}