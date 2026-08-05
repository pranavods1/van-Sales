class ProductTypeModel {
  final int id;
  final String name;

  ProductTypeModel({
    required this.id,
    required this.name,
  });

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
