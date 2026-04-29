import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080';
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient() {
    // 모든 요청에 JWT 토큰을 자동으로 포함시키는 인터셉터
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

  /// 1. 일반 로그인
  Future<Response> login(String userId, String userPw) async {
    return await dio.post('/auth/login', data: {
      'userId': userId,
      'userPw': userPw,
    });
  }


  Future<Response> loginWithKakao(String accessToken, int kakaoId, String nickname) async {
    try {
      return await dio.post('/auth/kakao', data: {
        'accessToken': accessToken,
        'kakaoId': kakaoId,
        'nickname': nickname,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 3. 일반 회원가입
  Future<Response> signup(Map<String, dynamic> userData) async {
    return await dio.post('/auth/signup', data: userData);
  }

  /// 4. 사업자등록증 이미지 업로드 및 OCR 분석
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
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  /// 5. 내 정보 가져오기
  Future<Response> getMyInfo() async {
    return await dio.get('/api/member/me');
  }

  /// 6. 서버에서 받은 토큰 보안 저장소에 저장
  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
    if (refreshToken != null) {
      await storage.write(key: 'refreshToken', value: refreshToken);
    }
  }

  /// 7. 로그아웃 시 토큰 삭제
  Future<void> clearTokens() async {
    await storage.deleteAll();
  }


  Future<Response> updateMemberInfo(Map<String, dynamic> data) async {
    return await dio.put('/api/member/me', data: data);
  }
}