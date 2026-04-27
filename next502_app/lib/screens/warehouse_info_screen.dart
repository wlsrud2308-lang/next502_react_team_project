import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WarehouseInfoScreen extends StatelessWidget {
  final Map<String, dynamic>? warehouseData;
  // 실제 서비스 시에는 로그인 성공 후 저장된 고유 번호를 사용해야 합니다.
  final int myUserSeq = 10;

  const WarehouseInfoScreen({super.key, this.warehouseData});

  // 채팅방 생성 및 이동 로직
  Future<void> _startChat(BuildContext context, int warehouseSeq) async {
    try {
      // 1. 서버 주소 수정 (안드로이드 에뮬레이터 기준 10.0.2.2:8080)
      final String url = 'http://10.0.2';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> room = json.decode(response.body);

        // 2. 백엔드 ChatRoomEntity의 PK 필드명(id)에 맞춰 수정
        final int roomId = room['id'];

        if (context.mounted) {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {
              'roomId': roomId,
              'myUserSeq': myUserSeq,
            },
          );
        }
      } else {
        throw Exception("서버 응답 에러: ${response.statusCode}");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("채팅방을 연결할 수 없습니다: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = args ?? warehouseData ?? {};

    // 백엔드 WarehouseEntity의 PK 필드명(warehouseSeq) 확인
    final int warehouseSeq = data['warehouseSeq'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? "창고 상세 정보", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // TODO: Favorite(찜) 기능을 호출하세요 (POST /favorite/{warehouseSeq})
              }
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: data['imageUrl'] != null
                  ? Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50))
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(data['sizeRank'] ?? "규모 미정", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      const Text("인증 완료", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(data['name'] ?? "창고 명칭 정보 없음", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(data['address'] ?? "주소 정보 없음", style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 40),
                  const Text("창고 사양", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpecItem(Icons.aspect_ratio, "면적", "${data['totalArea'] ?? '0'}평"),
                      _buildSpecItem(Icons.height, "층고", "7.5m"),
                      _buildSpecItem(Icons.local_shipping, "주차", "대형 가능"),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("상세 설명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    data['description'] ?? "등록된 상세 설명이 없습니다.",
                    style: const TextStyle(height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  const Text("위치", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text("지도 영역")),
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
                onPressed: () {
                  // TODO: 연락처(data['contact'])로 전화 연결 로직 추가
                },
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
                onPressed: () => _startChat(context, warehouseSeq),
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

