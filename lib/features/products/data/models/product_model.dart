class ProductUnitModel {
  final int id;
  final int unit;
  final String name;
  final String price;
  final String? minPrice;
  final int stock;

  ProductUnitModel({
    required this.id,
    required this.unit,
    required this.name,
    required this.price,
    this.minPrice,
    required this.stock,
  });

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitModel(
      id: json['id'] ?? 0,
      unit: json['unit'] ?? 0,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      minPrice: json['min_price']?.toString(),
      stock: json['stock'] ?? 0,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String? code;
  final String? proImage;
  final num taxPercentage;
  final num price;
  final int storeId;
  final int status;
  final List<ProductUnitModel> units;

  ProductModel({
    required this.id,
    required this.name,
    this.code,
    this.proImage,
    required this.taxPercentage,
    required this.price,
    required this.storeId,
    required this.status,
    required this.units,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var unitsList = json['units'] as List? ?? [];
    List<ProductUnitModel> parsedUnits = unitsList.map((e) => ProductUnitModel.fromJson(e)).toList();

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      code: json['code']?.toString(),
      proImage: json['pro_image']?.toString(),
      taxPercentage: json['tax_percentage'] ?? 0,
      price: json['price'] ?? 0,
      storeId: json['store_id'] ?? 0,
      status: json['status'] ?? 0,
      units: parsedUnits,
    );
  }
}
