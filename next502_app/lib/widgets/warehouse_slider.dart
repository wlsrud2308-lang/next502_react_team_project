import 'package:flutter/material.dart';

class WarehouseSlider extends StatelessWidget {
  const WarehouseSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "창고 조회",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 210, // 버튼이 들어가서 높이를 살짝 키웠습니다.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildWarehouseCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseCard() {
    return Container(
      width: 170, // 버튼 배치를 위해 너비를 살짝 넓혔습니다.
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Container(
              height: 90,
              width: double.infinity,
              color: const Color(0xFFF0F0F0),
              child: const Icon(Icons.warehouse, color: Colors.grey, size: 35),
            ),
            // 정보 영역
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "부산 강서구 창고",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "상온 / 100평",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // 전화문의 및 채팅 버튼 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildContactButton(Icons.phone, "전화", Colors.green),
                      _buildContactButton(Icons.chat_bubble, "채팅", Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 작은 상담 버튼 위젯
  Widget _buildContactButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


