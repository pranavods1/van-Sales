import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final ApiClient apiClient;

  CustomerRepositoryImpl(this.apiClient);

  @override
  Future<List<CustomerModel>> getCustomers(int routeId, int storeId) async {
    try {
      final response = await apiClient.dio.get(
        '/get_customer',
        data: {
          'route_id': routeId.toString(),
          'store_id': storeId.toString(),
        },
      );

      if (response.data['success'] == true) {
        final dataList = response.data['data'] as List;
        return dataList.map((json) => CustomerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch customers');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception(e.message ?? 'Network error occurred. Please check your internet connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }
}
