import 'package:pranav_mechinetest/features/auth/data/models/user_model.dart';





abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> getUserDetail(int userId);
}
