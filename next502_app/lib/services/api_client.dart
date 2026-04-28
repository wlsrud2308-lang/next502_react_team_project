import 'dart:io';

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

  /// 사업자등록증 이미지를 백엔드로 업로드
  ///   "companyName": "(주)부산창고",
  ///   "registerNumber": "123-45-67890",
  ///   "representativeName": "홍길동",
  ///   "businessAddress": "부산광역시 사하구 ...",
  ///   "message": "OCR 분석 완료"
  /// }
  Future<Response> uploadBusinessLicense(File imageFile) async {
    String fileName = imageFile.path.split('/').last;

    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    return await dio.post(
      '/ocr/business-license',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        // OCR 분석은 시간이 걸릴 수 있어 타임아웃 여유있게 설정
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }
}