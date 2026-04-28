import 'package:flutter/material.dart';
import '../models/warehouse_model.dart'; // 작성하신 모델 경로에 맞게 수정하세요

class WarehouseSlider extends StatelessWidget {
  // 1. 서버에서 가져온 창고 리스트를 인자로 받습니다.
  final List<WarehouseModel> items;

  const WarehouseSlider({super.key, required this.items});

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
          height: 220, // 버튼 배치를 위해 높이를 넉넉히 설정
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final warehouse = items[index];
              return _buildWarehouseCard(context, warehouse);
            },
          ),
        ),
      ],
    );
  }

  // 2. 개별 창고 카드 위젯
  Widget _buildWarehouseCard(BuildContext context, WarehouseModel warehouse) {
    return GestureDetector(
      onTap: () {
        // [클릭 시 상세 페이지로 이동]
        // main.dart에 등록한 '/whInfo' 라우트를 사용하며 데이터를 넘깁니다.
        Navigator.pushNamed(
          context,
          '/whInfo',
          arguments: warehouse,
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          elevation: 2,
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
                // 이미지가 없을 경우 아이콘 표시
                child: warehouse.images.isNotEmpty
                    ? Image.network(warehouse.images[0].imageUrl, fit: BoxFit.cover)
                    : const Icon(Icons.warehouse, color: Colors.grey, size: 35),
              ),
              // 정보 영역
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name, // "창고지기", "넥스트" 등
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${warehouse.sizeRank} / ${warehouse.totalArea.toInt()}평",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    // 하단 퀵 버튼 (전화, 채팅)
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
      ),
    );
  }

  // 작은 상담 버튼 유틸리티
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



