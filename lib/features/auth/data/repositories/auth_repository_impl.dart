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

        // Save user details for later API calls and UI display
        final userJson = response.data['user'];
        await prefs.setInt('user_id', userJson['id'] ?? 0);
        await prefs.setString('user_name', userJson['name'] ?? 'Salesman');

        // Return the user model
        return UserModel.fromJson(userJson);
      } else {
        throw Exception('Login failed. Please check your credentials.');
      }
    } on DioException catch (e) {
      // Check for network/connection errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network and try again.');
      }

      // Handle HTTP errors and show user-friendly messages
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw Exception('Incorrect email or password. Please try again.');
        }

        if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map<String, dynamic> && data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception(e.message ??
          'Network error occurred. Please check your internet connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<void> getUserDetail(int userId) async {
    try {
      // The API requires a GET request but with a JSON body {"user_id": "150"}
      final response = await apiClient.dio.get(
        '/get_user_detail',
        data: {
          'user_id': userId.toString(),
        },
      );

      if (response.data['success'] == true) {
        final dataList = response.data['data'] as List;
        if (dataList.isNotEmpty) {
          final userData = dataList.first;
          
          // Save these vital IDs to SharedPreferences for later API calls
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('route_id', userData['route_id'] ?? 0);
          await prefs.setInt('van_id', userData['van_id'] ?? 0);
          await prefs.setInt('store_id', userData['store_id'] ?? 0);
        }
      } else {
        throw Exception('Failed to fetch user details');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch user details: ${e.message}');
    }
  }
}