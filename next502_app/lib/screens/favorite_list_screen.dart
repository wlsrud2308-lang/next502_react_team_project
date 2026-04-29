import 'package:flutter/material.dart';

class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  // 🚀 임시 더미 데이터 (나중에 백엔드 찜 목록 API와 연동할 예정입니다)
  final List<Map<String, dynamic>> _favorites = [
    {"id": 1, "name": "부산 금정구 대형 창고", "address": "부산광역시 금정구", "price": "월 150만"},
    {"id": 2, "name": "해운대 소형 보관소", "address": "부산광역시 해운대구", "price": "월 50만"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("관심 창고 목록", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _favorites.isEmpty
          ? const Center(child: Text("아직 찜한 창고가 없습니다.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];
          return Card(
            elevation: 0,
            color: Colors.grey.shade50,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: const Icon(Icons.warehouse, color: Colors.deepPurple),
              ),
              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['address'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(item['price'], style: const TextStyle(fontSize: 13, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: () {
                  // TODO: 백엔드 연동 시 찜 해제 API 호출 로직 추가
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("찜 해제 기능은 준비 중입니다.")));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}