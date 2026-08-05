class UserModel {
  final int id;
  final String name;
  final String email;
  final int storeId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      storeId: json['store_id'] ?? 0,
    );
  }
}
