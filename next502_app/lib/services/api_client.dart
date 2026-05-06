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

  Future<Response> signup(Map<String, dynamic> userData) async {
    return await dio.post('/auth/signup', data: userData);
  }

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

  Future<Response> insertWarehouse(Map<String, dynamic> data, List<File> images) async {
    final formData = FormData();

    formData.files.add(MapEntry(
      'data',
      MultipartFile.fromString(
        _jsonEncode(data),
        filename: 'data.json',
        contentType: DioMediaType('application', 'json'),
      ),
    ));

    for (final file in images) {
      final fileName = file.path.split('/').last;
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    return await dio.post(
      '/warehouse/insert',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  String _jsonEncode(Map<String, dynamic> data) {
    final entries = data.entries.map((e) {
      final v = e.value;
      if (v == null) return '"${e.key}":null';
      if (v is num) return '"${e.key}":$v';
      if (v is bool) return '"${e.key}":$v';

      final escaped = v.toString()
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n');
      return '"${e.key}":"$escaped"';
    }).join(',');
    return '{$entries}';
  }

  Future<Response> getMyInfo() async {
    return await dio.get('/api/member/me');
  }

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
    if (refreshToken != null) {
      await storage.write(key: 'refreshToken', value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await storage.deleteAll();
  }

  Future<Response> updateMemberInfo(Map<String, dynamic> data) async {
    return await dio.put('/api/member/me', data: data);
  }

  // 찜하기 토글
  Future<Response> toggleFavorite(int whId) async {
    return await dio.post('/favorite/$whId');
  }

  // 내 찜 목록 가져오기
  Future<Response> getFavoriteList() async {
    return await dio.get('/favorite/list');
  }

  //내가 등록한 창고 목록 가져오기
  Future<Response> getMyWarehouseList() async {
    try {
      return await dio.get('/warehouse/my-list');
    } catch (e) {
      rethrow;
    }
  }
}