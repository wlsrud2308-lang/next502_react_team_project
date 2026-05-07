import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // 네이버 맵 패키지
import '../models/warehouse_model.dart';
import 'chat_screen.dart';
import 'package:next502_app/utils/image_url_helper.dart';
import 'package:next502_app/services/api_client.dart';

class WarehouseInfoScreen extends StatefulWidget {
  final WarehouseModel? warehouseData;

  const WarehouseInfoScreen({super.key, this.warehouseData});

  @override
  State<WarehouseInfoScreen> createState() => _WarehouseInfoScreenState();
}

class _WarehouseInfoScreenState extends State<WarehouseInfoScreen> {
  final _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  bool isFavorite = false;

  Future<void> _toggleFavorite(int warehouseId) async {
    try {
      final response = await _apiClient.toggleFavorite(warehouseId);
      if (response.statusCode == 200) {
        setState(() {
          isFavorite = !isFavorite;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data.toString())),
          );
        }
      }
    } catch (e) {
      debugPrint("찜하기 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("찜하기 처리에 실패했습니다.")),
        );
      }
    }
  }

  Future<void> _startChat(int warehouseId, String warehouseName) async {
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) return;

      final String url = 'http://10.0.2.2:8080/chat/room/$warehouseId';
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

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatRoomId: roomId,
                warehouseName: warehouseName,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("통신 중 예외 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final warehouse = widget.warehouseData ?? ModalRoute.of(context)!.settings.arguments as WarehouseModel;
    final int warehouseId = warehouse.warehouseId;

    return Scaffold(
      appBar: AppBar(
        title: Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : null,
            ),
            onPressed: () => _toggleFavorite(warehouseId),
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
              child: _buildDetailImage(warehouse),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(warehouse.sizeRank, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 15),
                  Text(warehouse.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(warehouse.address, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 40),
                  const Text("창고 사양", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpecItem(Icons.aspect_ratio, "면적", "${warehouse.totalArea.toInt()}평"),
                      _buildSpecItem(Icons.height, "층고", "7.5m"),
                      _buildSpecItem(Icons.local_shipping, "주차", "대형 가능"),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("상세 설명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    warehouse.description ?? "등록된 상세 설명이 없습니다.",
                    style: const TextStyle(height: 1.6, color: Colors.black87),
                  ),

                  const Divider(height: 40),

                  // ★ 네이버 지도 섹션 (확대 레벨 17.5 적용)
                  _buildNaverMapSection(warehouse),

                  const SizedBox(height: 120), // 하단 여백 충분히 확보
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
                onPressed: () => _startChat(warehouseId, warehouse.name),
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

  // --- 확대 레벨이 적용된 네이버 지도 위젯 ---
  Widget _buildNaverMapSection(WarehouseModel warehouse) {
    if (warehouse.latitude == 0.0 || warehouse.longitude == 0.0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("위치 정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          height: 280, // 지도를 조금 더 크게 조절
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(warehouse.latitude, warehouse.longitude),
                  zoom: 17.5, // ★ 확대 레벨을 높여 건물이 자세히 보이게 함
                ),
                scrollGesturesEnable: false, // 스크롤 방해 금지
                zoomGesturesEnable: false,   // 고정 뷰
                logoClickEnable: false,
              ),
              onMapReady: (controller) {
                final marker = NMarker(
                  id: 'location_${warehouse.warehouseId}',
                  position: NLatLng(warehouse.latitude, warehouse.longitude),
                );
                // 마커에 창고 이름 표시
                marker.setCaption(NOverlayCaption(
                  text: warehouse.name,
                  textSize: 13,
                  color: Colors.black,
                  haloColor: Colors.white,
                ));
                controller.addOverlay(marker);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                warehouse.address,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailImage(WarehouseModel warehouse) {
    final url = normalizeImageUrl(warehouse.repImageUrl) ??
        (warehouse.images.isNotEmpty
            ? normalizeImageUrl(warehouse.images.first.imageUrl)
            : null);

    if (url == null) {
      return const Icon(Icons.image, size: 100, color: Colors.grey);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) =>
      const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
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