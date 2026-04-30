import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:next502_app/providers/warehouse_provider.dart';
import 'package:next502_app/models/warehouse_model.dart';

class WarehouseMapScreen extends StatefulWidget {
  const WarehouseMapScreen({super.key});

  @override
  State<WarehouseMapScreen> createState() => _WarehouseMapScreenState();
}

class _WarehouseMapScreenState extends State<WarehouseMapScreen> {
  late NaverMapController _mapController;
  WarehouseModel? _selectedWarehouse; // 하단 카드에 보여줄 선택된 창고

  @override
  Widget build(BuildContext context) {
    // 1. WarehouseProvider를 지켜봅니다.
    final warehouseProvider = Provider.of<WarehouseProvider>(context);

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
          // 2. 네이버 지도 본체
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.1795, 129.0756), // 부산 시청 좌표
                zoom: 11, // 부산 전체가 보이도록 줌 레벨 조정
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              print("✅ 지도 준비 완료");

              // 3. 지도가 준비되면 서버에서 데이터를 가져옵니다.
              await warehouseProvider.fetchMainWarehouses();

              // 4. 가져온 데이터를 지도에 마커로 찍습니다.
              _addMarkers(warehouseProvider.warehouses);
            },
          ),

          // 5. 로딩 중일 때 표시할 인디케이터
          if (warehouseProvider.isLoading)
            const Center(child: CircularProgressIndicator()),

          // 6. 창고 마커를 클릭했을 때만 하단에 정보 카드 표시
          if (_selectedWarehouse != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildWarehouseSummaryCard(_selectedWarehouse!),
            ),
        ],
      ),
    );
  }

  // 데이터 기반 마커 추가 함수
  void _addMarkers(List<WarehouseModel> warehouses) {
    // 기존 마커가 있다면 모두 지우고 시작 (필요 시)
    _mapController.clearOverlays();

    final markers = warehouses.map((w) {
      return NMarker(
        id: w.warehouseId.toString(),
        position: NLatLng(w.latitude, w.longitude), // 모델에 추가한 좌표 사용
        caption: NOverlayCaption(text: w.name),
      )..setOnTapListener((marker) {
        // 마커 클릭 시 동작
        setState(() {
          _selectedWarehouse = w; // 하단 카드 정보 업데이트
        });

        // 카메라를 해당 위치로 부드럽게 이동
        final cameraUpdate = NCameraUpdate.withParams(
          target: marker.position,
          zoom: 14,
        )..setAnimation(animation: NCameraAnimation.easing, duration: const Duration(milliseconds: 300));
        _mapController.updateCamera(cameraUpdate);
      });
    }).toSet();

    _mapController.addOverlayAll(markers);
    print("✅ ${markers.length}개의 마커 추가 완료");
  }

  // 선택된 창고 정보 카드 위젯
  Widget _buildWarehouseSummaryCard(WarehouseModel warehouse) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          // 창고 이미지 (URL이 있으면 네트워크 이미지, 없으면 기본 아이콘)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: warehouse.repImageUrl != null
                ? Image.network(warehouse.repImageUrl!, width: 90, height: 90, fit: BoxFit.cover)
                : Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.warehouse, color: Colors.grey)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(warehouse.address, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("${warehouse.storageType ?? '상온'} / ${warehouse.totalArea.toInt()}평", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/whInfo', arguments: warehouse),
                  child: const Text("상세보기 >", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
          // 닫기 버튼
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _selectedWarehouse = null),
          ),
        ],
      ),
    );
  }
}