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
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      warehouseId: json['warehouseId'] as int? ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      // 서버에서 String으로 오는 totalArea 대응
      totalArea: double.tryParse(json['totalArea']?.toString() ?? '0.0') ?? 0.0,
      occupiedArea: (json['occupiedArea'] as num?)?.toDouble() ?? 0.0,
      sizeRank: json['sizeRank'] ?? '',
      storageType: json['storageType'],
      operationStructure: json['operationStructure'],
      description: json['description'],
      amenities: json['amenities'],
      repImageUrl: json['repImageUrl'],
      images: (json['images'] as List? ?? [])
          .map((img) => WarehouseImageModel.fromJson(img))
          .toList(),
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

