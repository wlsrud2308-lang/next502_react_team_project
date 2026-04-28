import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:next502_app/models/warehouse_model.dart';

class WarehouseProvider with ChangeNotifier {
  List<WarehouseModel> _warehouses = [];
  bool _isLoading = false;

  List<WarehouseModel> get warehouses => _warehouses;
  bool get isLoading => _isLoading;

  Future<void> fetchMainWarehouses() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 서버 주소 완성: http://10.0.2
      // 안드로이드 에뮬레이터는 10.0.2.2가 내 PC 주소입니다.
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/warehouse/search'),
      );

      print("응답 상태 코드: ${response.statusCode}"); // 디버깅용 로그

      if (response.statusCode == 200) {
        print("서버 응답 데이터: ${utf8.decode(response.bodyBytes)}"); // 데이터 확인용 로그

        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _warehouses = data.map((json) => WarehouseModel.fromJson(json)).toList();
      } else {
        print("서버 응답 에러: ${response.statusCode}");
      }
    } catch (e) {
      print("메인 창고 로드 에러 (연결 실패): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}