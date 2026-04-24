import 'package:flutter/material.dart';
// import 'package:flutter_naver_map/flutter_naver_map.dart'; // 네이버 지도 패키지

class WarehouseMapScreen extends StatefulWidget {
  const WarehouseMapScreen({super.key});

  @override
  State<WarehouseMapScreen> createState() => _WarehouseMapScreenState();
}

class _WarehouseMapScreenState extends State<WarehouseMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 주변 창고 찾기", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. 네이버 지도 영역
          Container(
            color: Colors.grey.shade200,
            child: const Center(child: Text("여기에 네이버 지도가 표시됩니다.")),
            // 실제 구현 시: NaverMap(onMapReady: (controller) => ...)
          ),

          // 2. 상단 검색/필터 바
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildMapFilter(),
          ),

          // 3. 내 위치로 이동 버튼
          Positioned(
            bottom: 160,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                // 현재 GPS 위치로 지도 이동 로직
              },
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // 4. 지도 하단 창고 요약 카드 (마커 클릭 시 노출)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildWarehouseSummaryCard(),
          ),
        ],
      ),
    );
  }

  // 필터 위젯 (상온, 냉장 등 선택)
  Widget _buildMapFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["전체", "상온", "냉장/냉동", "야적"].map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              onSelected: (bool selected) {},
              backgroundColor: Colors.white,
              selectedColor: Colors.deepPurple.withOpacity(0.2),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 마커 클릭 시 나타날 요약 카드
  Widget _buildWarehouseSummaryCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(width: 90, color: Colors.grey.shade100, child: const Icon(Icons.warehouse)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("부산 사하구 감천 창고", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("상온 / 120평", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                const Text("상세보기 >", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
