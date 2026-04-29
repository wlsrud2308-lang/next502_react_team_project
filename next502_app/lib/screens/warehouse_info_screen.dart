import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/warehouse_model.dart';
import 'chat_screen.dart'; // ChatScreen import 확인

class WarehouseInfoScreen extends StatelessWidget {
  final WarehouseModel? warehouseData;
  final _storage = const FlutterSecureStorage();

  const WarehouseInfoScreen({super.key, this.warehouseData});

  // 1. 찜하기(Favorite) 로직
  Future<void> _toggleFavorite(BuildContext context, int warehouseId) async {
    try {
      String? token = await _storage.read(key: 'accessToken');
      // 백엔드 주소에 맞게 수정 필요
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
            SnackBar(content: Text(utf8.decode(response.bodyBytes))),
          );
        }
      }
    } catch (e) {
      debugPrint("찜하기 에러: $e");
    }
  }

  // 2. 채팅방 생성 및 이동 로직 (수정됨)
  Future<void> _startChat(BuildContext context, int warehouseId, String warehouseName) async {
    print("1. 채팅 시작 버튼 클릭됨! warehouseId: $warehouseId"); // 확인용 로그
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) {
        print("에러: 토큰이 없습니다. 로그인이 필요합니다.");
        return;
      }
      print("전송 토큰: $token");

      final String url = 'http://10.0.2.2:8080/chat/room/${warehouseId}';
      print("2. API 호출 주소: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("3. 서버 응답 코드: ${response.statusCode}");
      print("4. 서버 응답 바디: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> room = json.decode(utf8.decode(response.bodyBytes));
        final int roomId = room['chatRoomId']; // 서버 엔티티의 PK 필드명 확인


        print("5. 화면 이동 시작! roomId: $roomId");

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatRoomId: roomId,
                warehouseName: warehouseName,
              ),
            ),
          );
        }
      } else {
        print("6. 서버 에러 발생: ${response.statusCode}");
      }
    } catch (e) {
      print("7. 통신 중 예외 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // arguments로 넘어온 데이터를 우선 사용
    final warehouse = warehouseData ?? ModalRoute.of(context)!.settings.arguments as WarehouseModel;
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
      // 하단 고정 버튼 바
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
                onPressed: () {}, // url_launcher로 전화 연결 가능
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
                // [변경] _startChat 함수 호출 시 이름도 함께 전달
                onPressed: () => _startChat(context, warehouseId, warehouse.name),
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




