import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080';
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = await storage.read(key: 'accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> login(String userId, String userPw) async {
    return await dio.post('/auth/login', data: {
      'userId': userId,
      'userPw': userPw,
    });
  }

  Future<Response> signup(Map<String, dynamic> userData) async {
    return await dio.post('/auth/signup', data: userData);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }
}