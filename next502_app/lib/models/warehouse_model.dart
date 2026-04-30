class WarehouseModel {
  final int warehouseId;
  final String name;
  final String address;
  final double totalArea;
  final double occupiedArea;
  final String sizeRank;
  final String? storageType;
  final String? operationStructure;
  final String? description;
  final String? amenities;
  final String? repImageUrl;
  final List<WarehouseImageModel> images;

  // --- 지도 기능을 위해 추가된 필드 ---
  final double latitude;  // 위도
  final double longitude; // 경도

  WarehouseModel({
    required this.warehouseId,
    required this.name,
    required this.address,
    required this.totalArea,
    this.occupiedArea = 0.0,
    required this.sizeRank,
    this.storageType,
    this.operationStructure,
    this.description,
    this.amenities,
    this.repImageUrl,
    this.images = const [],
    // 위/경도 필수값으로 설정 (좌표가 없으면 지도에 표시 불가)
    required this.latitude,
    required this.longitude,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      warehouseId: json['warehouseId'] as int? ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',

      // 숫자 데이터 안전하게 파싱 (String으로 올 경우 대비)
      totalArea: double.tryParse(json['totalArea']?.toString() ?? '0.0') ?? 0.0,
      occupiedArea: (json['occupiedArea'] as num?)?.toDouble() ?? 0.0,

      sizeRank: json['sizeRank'] ?? '',
      storageType: json['storageType'],
      operationStructure: json['operationStructure'],
      description: json['description'],
      amenities: json['amenities'],
      repImageUrl: json['repImageUrl'],

      // 이미지 리스트 매핑
      images: (json['images'] as List? ?? [])
          .map((img) => WarehouseImageModel.fromJson(img))
          .toList(),

      // --- 서버 응답에서 위도, 경도 추출 (변수명은 DB 컬럼명에 맞게 조정하세요) ---
      latitude: double.tryParse(json['latitude']?.toString() ?? '37.5666') ?? 37.5666,
      longitude: double.tryParse(json['longitude']?.toString() ?? '126.9784') ?? 126.9784,
    );
  }
}

class WarehouseImageModel {
  final int warehouseImageId;
  final String imageUrl;

  WarehouseImageModel({required this.warehouseImageId, required this.imageUrl});

  factory WarehouseImageModel.fromJson(Map<String, dynamic> json) {
    return WarehouseImageModel(
      warehouseImageId: json['warehouseImageId'] ?? json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}