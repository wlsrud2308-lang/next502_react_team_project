import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WarehouseInfoScreen extends StatelessWidget {
  // 1. 데이터를 받기 위한 변수 추가 (임시 데이터 대신 실제 데이터를 받음)
  final Map<String, dynamic>? warehouseData;
  final int myUserSeq = 10; // 테스트용 임시 내 번호 (로그인 정보에서 가져와야 함)

  const WarehouseInfoScreen({super.key, this.warehouseData});

  // 2. 채팅방 생성 및 이동 로직
  Future<void> _startChat(BuildContext context, int warehouseSeq) async {
    try {
      // 백엔드의 ChatController @PostMapping("/room/{warehouseSeq}") 호출
      final response = await http.post(
        Uri.parse('http://10.0.2'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> room = json.decode(response.body);
        final int roomId = room['chatRoomSeq'];

        if (context.mounted) {
          // ChatScreen으로 이동하며 필수 데이터 전달
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {
              'roomId': roomId,
              'myUserSeq': myUserSeq,
            },
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("채팅방을 연결할 수 없습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.pushNamed로 넘어온 데이터를 꺼냅니다 (목록에서 넘겨준 경우)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = args ?? warehouseData ?? {}; // 전달받은 데이터가 없으면 빈 맵
    final int warehouseSeq = data['warehouseSeq'] ?? 1; // 기본값 1

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? "창고 상세 정보", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
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
              child: data['imageUrl'] != null
                  ? Image.network(data['imageUrl'], fit: BoxFit.cover)
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
                  Text(
                    data['name'] ?? "창고 명칭 정보 없음",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
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
                    child: const Center(child: Text("네이버 지도 영역")),
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {}, // 전화 문의 로직 추가 가능
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
                // 3. 채팅 상담 버튼 클릭 시 서버 연동 함수 실행
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
