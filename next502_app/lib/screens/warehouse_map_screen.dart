import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class WarehouseMapScreen extends StatefulWidget {
  const WarehouseMapScreen({super.key});

  @override
  State<WarehouseMapScreen> createState() => _WarehouseMapScreenState();
}

class _WarehouseMapScreenState extends State<WarehouseMapScreen> {
  // 지도 컨트롤러 (나중에 마커 제어 등에 사용)
  late NaverMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 주변 창고 찾기",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. 네이버 지도 본체
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5666, 126.9784),
                zoom: 14,
              ),
              locationButtonEnable: false, // 기본 버튼 대신 커스텀 버튼 사용
            ),
            onMapReady: (controller) {
              _mapController = controller;
              print("✅ 네이버 지도 로드 완료");
            },
          ),

          // 2. 상단 필터 바 (상온, 냉장 등)
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: _buildMapFilter(),
          ),

          // 3. 내 위치로 이동 버튼 (FloatingActionButton)
          Positioned(
            bottom: 160,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                // [수정된 부분] const 제거 및 애니메이션 추가
                final cameraUpdate = NCameraUpdate.withParams(
                  target: const NLatLng(37.5666, 126.9784),
                  zoom: 15,
                )..setAnimation(
                  animation: NCameraAnimation.easing,
                  duration: const Duration(milliseconds: 500),
                );
                _mapController.updateCamera(cameraUpdate);
              },
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // 4. 하단 창고 요약 정보 카드
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

  // 필터 칩 리스트
  Widget _buildMapFilter() {
    final filters = ["전체", "상온", "냉장/냉동", "야적"];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[index]),
              onSelected: (bool selected) {},
              backgroundColor: Colors.white.withOpacity(0.9),
              selectedColor: Colors.deepPurple.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          );
        },
      ),
    );
  }

  // 창고 요약 카드
  Widget _buildWarehouseSummaryCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warehouse, size: 40, color: Colors.deepPurple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("부산 사하구 감천 창고",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("상온 / 120평",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => print("상세보기 클릭"),
                  child: const Text("상세보기 >",
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}