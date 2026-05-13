import 'dart:io';
import 'package:flutter/material.dart';
import 'package:next502_app/models/warehouse_model.dart';
import 'package:next502_app/services/api_client.dart';

class WarehouseProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<WarehouseModel> _warehouses = [];
  bool _isLoading = false;

  List<WarehouseModel> get warehouses => _warehouses;
  bool get isLoading => _isLoading;

  /// 창고 목록 검색 (키워드: 이름/주소 등, 타입: 창고유형)
  Future<void> fetchWarehouses({String? query, String? type}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> queryParams = {};

      // 검색어 파라미터 추가 (이름, 주소 검색용)
      if (query != null && query.trim().isNotEmpty) {
        queryParams['keyword'] = query.trim();
      }

      // 창고 유형 필터 추가 (서버 변수명에 맞춰 storageType 사용)
      if (type != null && type != "전체") {
        queryParams['storageType'] = type;
      }

      print("[API 요청] 검색어: $query, 필터: $type");

      final response = await _apiClient.dio.get(
        '/warehouse/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _warehouses = data.map((json) => WarehouseModel.fromJson(json)).toList();
        print("[API 완료] 조회된 창고 수: ${_warehouses.length}");
      } else {
        _warehouses = [];
      }
    } catch (e) {
      print("창고 검색 중 에러 발생: $e");
      _warehouses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 기존 메인 데이터 로드용
  Future<void> fetchMainWarehouses() async {
    await fetchWarehouses();
  }

  /// 창고 등록 후 목록 갱신
  Future<int> insertWarehouse(Map<String, dynamic> data, List<File> images) async {
    final response = await _apiClient.insertWarehouse(data, images);
    if (response.statusCode == 200) {
      await fetchMainWarehouses();
      return response.data is int ? response.data : int.parse(response.data.toString());
    }
    throw Exception('등록 실패');
  }
}