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

  /// 창고 목록 조회
  Future<void> fetchMainWarehouses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/warehouse/search');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _warehouses = data.map((json) => WarehouseModel.fromJson(json)).toList();
      } else {
        print("창고 조회 응답 에러: ${response.statusCode}");
      }
    } catch (e) {
      print("메인 창고 로드 에러: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 창고 등록
  /// 반환: 생성된 warehouseId. 실패 시 throw.
  Future<int> insertWarehouse(Map<String, dynamic> data, List<File> images) async {
    print('[WarehouseProvider] insertWarehouse 시작');

    final response = await _apiClient.insertWarehouse(data, images);
    print('[WarehouseProvider] insert 응답 status: ${response.statusCode}');
    print('[WarehouseProvider] insert 응답 data: ${response.data} (타입: ${response.data.runtimeType})');

    if (response.statusCode == 200) {
      final raw = response.data;
      int newId;
      if (raw is int) {
        newId = raw;
      } else if (raw is num) {
        newId = raw.toInt();
      } else {
        newId = int.tryParse(raw.toString()) ?? 0;
      }
      print('[WarehouseProvider] 파싱된 warehouseId: $newId');


      try {
        await fetchMainWarehouses();
      } catch (e, stack) {
        print('[WarehouseProvider] fetchMainWarehouses 실패 (등록은 성공): $e');
        print('스택: $stack');
      }

      return newId;
    }

    throw Exception('창고 등록 실패: ${response.statusCode}');
  }
}