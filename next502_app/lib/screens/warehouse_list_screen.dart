import 'package:flutter/material.dart';
import '../widgets/main_search_bar.dart'; // 기존 만든 서치바 재사용

class WarehouseListScreen extends StatefulWidget {
  const WarehouseListScreen({super.key});

  @override
  State<WarehouseListScreen> createState() => _WarehouseListScreenState();
}

class _WarehouseListScreenState extends State<WarehouseListScreen> {
  // 필터링 상태 관리용
  String _selectedFilter = "전체";
  final List<String> _filters = ["전체", "보통", "야적", "냉동/냉장", "저장", "위험물"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("창고 검색 결과", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. 검색바 재사용 (상단 고정)
          const MainSearchBar(),

          // 2. 필터 칩 섹션 (가로 스크롤)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: _selectedFilter == _filters[index],
                    onSelected: (bool selected) {
                      setState(() => _selectedFilter = _filters[index]);
                    },
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: _selectedFilter == _filters[index] ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(thickness: 1, height: 20),

          // 3. 창고 목록 (세로 리스트)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 10, // 임시 데이터 개수
              itemBuilder: (context, index) {
                return _buildWarehouseListItem(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 개별 창고 리스트 아이템 위젯
  Widget _buildWarehouseListItem(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/warehouse/info'), // 상세페이지 이동
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            // 창고 이미지
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
              child: const Icon(Icons.warehouse, color: Colors.grey, size: 40),
            ),
            // 창고 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("부산 사상구 대형 창고", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 5),
                    const Text("부산광역시 사상구 엄궁동", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTag("상온"),
                        const SizedBox(width: 5),
                        _buildTag("200평"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
    );
  }
}
