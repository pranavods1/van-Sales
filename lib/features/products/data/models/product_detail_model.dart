class ProductDetailModel {
  final int id;
  final int productId;
  final int unitId;
  final String qty;
  final String price;
  final String? minimumPrice;
  final String unitName;

  ProductDetailModel({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.qty,
    required this.price,
    this.minimumPrice,
    required this.unitName,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    // Safely extract the unit name from the nested 'units' array
    String extractedUnitName = 'Unknown';
    if (json['units'] != null && json['units'] is List && (json['units'] as List).isNotEmpty) {
      extractedUnitName = json['units'][0]['name'] ?? 'Unknown';
    }

    return ProductDetailModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      unitId: json['unit'] ?? 0,
      qty: json['qty']?.toString() ?? '0.000',
      price: json['price']?.toString() ?? '0.000',
      minimumPrice: json['minimum_price']?.toString(),
      unitName: extractedUnitName,
    );
  }
}
