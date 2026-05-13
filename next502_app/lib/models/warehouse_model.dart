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
  final List<String> imageUrls; // ★ 백엔드 DTO의 List<String> 구조에 맞춤

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
    this.imageUrls = const [], // 기본값 빈 리스트
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

      // ★ 백엔드 WarehouseDTO의 imageUrls (List<String>) 매핑
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],

      // 서버 응답에서 위도, 경도 추출
      latitude: double.tryParse(json['latitude']?.toString() ?? '37.5666') ?? 37.5666,
      longitude: double.tryParse(json['longitude']?.toString() ?? '126.9784') ?? 126.9784,
    );
  }
}