import 'package:flutter/material.dart';
import 'package:next502_app/services/api_client.dart';
import 'package:next502_app/models/warehouse_model.dart';
import 'package:next502_app/utils/image_url_helper.dart';

class MyWarehouseListScreen extends StatefulWidget {
  const MyWarehouseListScreen({super.key});

  @override
  State<MyWarehouseListScreen> createState() => _MyWarehouseListScreenState();
}

class _MyWarehouseListScreenState extends State<MyWarehouseListScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _myWarehouses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyWarehouses();
  }

  //  내가 등록한 창고 목록 가져오기
  Future<void> _fetchMyWarehouses() async {
    try {
      final response = await _apiClient.getMyWarehouseList();
      if (response.statusCode == 200) {
        setState(() {
          _myWarehouses = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("내 창고 목록 불러오기 에러: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("내가 등록한 창고", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myWarehouses.isEmpty
          ? const Center(child: Text("아직 등록한 창고가 없습니다.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myWarehouses.length,
        itemBuilder: (context, index) {
          final item = _myWarehouses[index];
          return Card(
            elevation: 0,
            color: Colors.grey.shade50,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              onTap: () {
                // 누르면 상세 화면으로 이동
                final model = WarehouseModel.fromJson({
                  'warehouseId': item['warehouseId'],
                  'name': item['name'],
                  'address': item['address'],
                  'sizeRank': item['sizeRank'] ?? '등급 없음',
                  'totalArea': item['totalArea'] ?? 0.0,
                  'description': item['description'] ?? '상세 설명이 없습니다.',
                  'repImageUrl': item['repImageUrl'] ?? '',
                  'images': [],
                });

                Navigator.pushNamed(context, '/whInfo', arguments: model);
              },
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  image: item['repImageUrl'] != null && item['repImageUrl'].toString().isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(normalizeImageUrl(item['repImageUrl']) ?? ''),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: item['repImageUrl'] == null || item['repImageUrl'].toString().isEmpty
                    ? const Icon(Icons.domain, color: Colors.blue)
                    : null,
              ),
              title: Text(item['name'] ?? '이름 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(item['address'] ?? '주소 정보 없음', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}