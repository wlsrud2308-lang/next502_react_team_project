import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/warehouse_model.dart'; // 모델 import

class WarehouseInfoScreen extends StatelessWidget {
  final WarehouseModel? warehouseData; // Map 대신 Model 사용 권장
  final _storage = const FlutterSecureStorage();

  const WarehouseInfoScreen({super.key, this.warehouseData});

  // 1. 찜하기(Favorite) 호출 로직 (whInfo 사용)
  Future<void> _toggleFavorite(BuildContext context, int whInfo) async {
    try {
      String? token = await _storage.read(key: 'accessToken');
      // 백엔드 주소: /favorite/{whInfo}
      final String url = 'http://10.0.2';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body)),
          );
        }
      }
    } catch (e) {
      print("찜하기 에러: $e");
    }
  }

  // 2. 채팅방 생성 로직 (whInfo 전달)
  Future<void> _startChat(BuildContext context, int whInfo) async {
    try {
      String? token = await _storage.read(key: 'accessToken');
      final String url = 'http://10.0.2';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'whInfo': whInfo}), // 서버 전달 키값 whInfo
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> room = json.decode(response.body);
        final int roomId = room['id'];

        if (context.mounted) {
          Navigator.pushNamed(context, '/chat', arguments: {'roomId': roomId});
        }
      }
    } catch (e) {
      print("채팅방 생성 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. arguments로 넘어온 WarehouseModel 수신
    final warehouse = ModalRoute.of(context)!.settings.arguments as WarehouseModel;
    final int warehouseId = warehouse.warehouseId;

    return Scaffold(
      appBar: AppBar(
        title: Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _toggleFavorite(context, warehouseId),
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: warehouse.images.isNotEmpty
                  ? Image.network(warehouse.images.first.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 규모 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(warehouse.sizeRank, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 15),
                  Text(warehouse.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(warehouse.address, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 40),
                  const Text("창고 사양", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpecItem(Icons.aspect_ratio, "면적", "${warehouse.totalArea.toInt()}평"),
                      _buildSpecItem(Icons.height, "층고", "7.5m"),
                      _buildSpecItem(Icons.local_shipping, "주차", "대형 가능"),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("상세 설명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    warehouse.detail?.description ?? "등록된 상세 설명이 없습니다.",
                    style: const TextStyle(height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {}, // 전화 로직 추가 가능
                icon: const Icon(Icons.phone),
                label: const Text("전화 문의"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startChat(context, warehouseId), // whInfo 전달
                icon: const Icon(Icons.chat_bubble),
                label: const Text("채팅 상담"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 30),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}



