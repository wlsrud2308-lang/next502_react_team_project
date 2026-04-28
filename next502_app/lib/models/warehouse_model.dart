class WarehouseModel {
  final int warehouseId;
  final String name;
  final String address;
  final double totalArea;
  final String sizeRank;
  final WarehouseDetailModel? detail;
  final List<WarehouseImageModel> images;

  WarehouseModel({
    required this.warehouseId,
    required this.name,
    required this.address,
    required this.totalArea,
    required this.sizeRank,
    this.detail,
    this.images = const [],
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      warehouseId: json['warehouseId'] as int? ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',

      // ⭐ 수정 포인트: String으로 들어오는 "500.0"을 double로 안전하게 파싱합니다.
      totalArea: double.tryParse(json['totalArea']?.toString() ?? '0') ?? 0.0,

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
