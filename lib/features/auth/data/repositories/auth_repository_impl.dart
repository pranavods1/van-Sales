import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['status'] == 'success') {
        // Save the token to SharedPreferences
        final token = response.data['authorisation']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        // Save user_id for later API calls (Get User Detail, Create Invoice, etc)
        final userJson = response.data['user'];
        await prefs.setInt('user_id', userJson['id']);

        // Return the user model
        return UserModel.fromJson(userJson);
      } else {
        throw Exception('Login failed. Please check your credentials.');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error occurred');
    }
  }
}
