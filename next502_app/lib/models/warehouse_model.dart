class WarehouseModel {
  final int id;
  final String name;
  final String address;
  final double totalArea;
  final String sizeRank;
  final WarehouseDetailModel? detail; // 상세 정보
  final List<WarehouseImageModel> images; // 이미지 목록

  WarehouseModel({
    required this.id,
    required this.name,
    required this.address,
    required this.totalArea,
    required this.sizeRank,
    this.detail,
    this.images = const [],
  });

  // 서버 JSON 데이터를 객체로 변환
  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      totalArea: (json['totalArea'] as num).toDouble(),
      sizeRank: json['sizeRank'] ?? '',
      detail: json['detail'] != null
          ? WarehouseDetailModel.fromJson(json['detail'])
          : null,
      images: (json['images'] as List? ?? [])
          .map((img) => WarehouseImageModel.fromJson(img))
          .toList(),
    );
  }
}

// 2. 상세 정보 모델
class WarehouseDetailModel {
  final String storageType;
  final String operationStructure;
  final String description;
  final String amenities;

  WarehouseDetailModel({
    required this.storageType,
    required this.operationStructure,
    required this.description,
    required this.amenities,
  });

  factory WarehouseDetailModel.fromJson(Map<String, dynamic> json) {
    return WarehouseDetailModel(
      storageType: json['storageType'] ?? '',
      operationStructure: json['operationStructure'] ?? '',
      description: json['description'] ?? '',
      amenities: json['amenities'] ?? '',
    );
  }
}

// 3. 이미지 모델
class WarehouseImageModel {
  final int warehouseImageSeq;
  final String imageUrl;
  final String isRepresentativeYn;
  final int? sortOrder;

  WarehouseImageModel({
    required this.warehouseImageSeq,
    required this.imageUrl,
    required this.isRepresentativeYn,
    this.sortOrder,
  });

  factory WarehouseImageModel.fromJson(Map<String, dynamic> json) {
    return WarehouseImageModel(
      warehouseImageSeq: json['warehouseImageSeq'] as int? ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isRepresentativeYn: json['isRepresentativeYn'] ?? 'N',
      sortOrder: json['sortOrder'] as int?,
    );
  }
}
