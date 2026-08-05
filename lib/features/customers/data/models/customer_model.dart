class CustomerModel {
  final int id;
  final String name;
  final String? contactNumber;
  final String? address;
  final String? paymentTerms;
  final int routeId;
  final int storeId;

  CustomerModel({
    required this.id,
    required this.name,
    this.contactNumber,
    this.address,
    this.paymentTerms,
    required this.routeId,
    required this.storeId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Customer',
      contactNumber: json['contact_number']?.toString(),
      address: json['address']?.toString(),
      paymentTerms: json['payment_terms']?.toString(),
      routeId: json['route_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
    );
  }
}
