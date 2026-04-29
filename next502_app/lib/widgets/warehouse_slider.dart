import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/warehouse_model.dart';
// import '../screens/chat_screen.dart'; // pushNamed 사용 시 import 생략 가능

class WarehouseSlider extends StatelessWidget {
  final List<WarehouseModel> items;
  final _storage = const FlutterSecureStorage();

  const WarehouseSlider({super.key, required this.items});

  // 채팅방 생성 및 이동 로직
  Future<void> _startChat(BuildContext context, WarehouseModel warehouse) async {
    try {
      String? token = await _storage.read(key: 'accessToken');

      final String url = 'http://10.0.2.2:8080/chat/room/${warehouse.warehouseId}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> room = json.decode(utf8.decode(response.bodyBytes));
        final int roomId = room['chatRoomId'];

        if (context.mounted) {
          // main.dart의 routes 설정('/chat')을 사용하여 이동
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {
              'chatRoomId': roomId,
              'warehouseName': warehouse.name,
            },
          );
        }
      }
    } catch (e) {
      debugPrint("슬라이더 채팅방 생성 에러: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("채팅 연결에 실패했습니다.")),
        );
      }
    }
  }

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
          height: 220,
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

  Widget _buildWarehouseCard(BuildContext context, WarehouseModel warehouse) {
    return GestureDetector(
      onTap: () {
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
              // --- 이미지 영역 수정됨 ---
              Container(
                height: 90,
                width: double.infinity,
                color: const Color(0xFFF0F0F0),
                child: warehouse.repImageUrl != null && warehouse.repImageUrl!.isNotEmpty
                    ? Image.network(warehouse.repImageUrl!, fit: BoxFit.cover)
                    : (warehouse.images.isNotEmpty
                    ? Image.network(warehouse.images[0].imageUrl, fit: BoxFit.cover)
                    : const Icon(Icons.warehouse, color: Colors.grey, size: 35)),
              ),
              // -----------------------
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildContactButton(Icons.phone, "전화", Colors.green, () {
                          debugPrint("${warehouse.name} 전화 연결");
                        }),
                        _buildContactButton(Icons.chat_bubble, "채팅", Colors.blue, () {
                          _startChat(context, warehouse);
                        }),
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

  Widget _buildContactButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
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
      ),
    );
  }
}




