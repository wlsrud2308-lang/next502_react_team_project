import 'package:flutter/material.dart';

class WarehouseInfoScreen extends StatelessWidget {
  const WarehouseInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("창고 상세 정보", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}), // 찜하기
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),          // 공유하기
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 창고 메인 이미지 슬라이더 (또는 단일 이미지)
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. 제목 및 유형 배지
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text("냉동/냉장", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      const Text("인증 완료", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "부산 사하구 감천항 물류센터",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text("부산광역시 사하구 감천항로 123", style: TextStyle(color: Colors.grey)),

                  const Divider(height: 40),

                  // 3. 주요 사양 (그리드 형태)
                  const Text("창고 사양", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpecItem(Icons.aspect_ratio, "면적", "150평"),
                      _buildSpecItem(Icons.height, "층고", "7.5m"),
                      _buildSpecItem(Icons.local_shipping, "주차", "대형 가능"),
                    ],
                  ),

                  const Divider(height: 40),

                  // 4. 상세 설명
                  const Text("상세 설명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "본 창고는 감천항 인근에 위치하여 수출입 물류 최적의 장소입니다. "
                        "24시간 보안 시스템이 가동 중이며, 화물 전용 승강기가 완비되어 있습니다. "
                        "언제든 채팅이나 전화로 문의 주시기 바랍니다.",
                    style: TextStyle(height: 1.6, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  // 5. 위치 정보 (미니 지도 영역)
                  const Text("위치", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text("네이버 지도 영역")),
                  ),
                  const SizedBox(height: 100), // 하단 버튼 공간 확보
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. 하단 고정 문의 버튼
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
                onPressed: () {},
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
                onPressed: () {},
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

  // 사양 아이템 위젯
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
