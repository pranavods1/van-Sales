import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_type_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;

  ProductRepositoryImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getProducts(int storeId) async {
    try {
      final response = await apiClient.dio.get(
        '/get_product',
        data: {
          'store_id': storeId.toString(),
        },
      );

      if (response.data['success'] == true) {
        // Note: The API returns data inside a pagination object: response.data['data']['data']
        final paginationData = response.data['data'];
        final dataList = paginationData['data'] as List;
        
        return dataList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch products');
      }
    } on DioException catch (e) {
      debugPrint('🔥 [API ERROR] getProducts DioException: ${e.message}');
      debugPrint('🔥 [API ERROR] Response: ${e.response?.statusCode} ${e.response?.statusMessage}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          throw Exception('The requested service was not found. Please contact support or try again later.');
        }
        if (e.response!.statusCode == 500) {
          throw Exception('Internal server error. Please try again later.');
        }
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception(e.message ?? 'Network error occurred. Please check your internet connection.');
    } catch (e) {
      debugPrint('🔥 [API ERROR] getProducts Unknown Exception: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<List<ProductDetailModel>> getProductDetail(int productId) async {
    try {
      final response = await apiClient.dio.get(
        '/get_product_detail',
        data: {
          'product_id': productId.toString(),
        },
      );

      if (response.data['success'] == true) {
        final dataList = response.data['data'] as List;
        return dataList.map((json) => ProductDetailModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch product details');
      }
    } on DioException catch (e) {
      debugPrint('🔥 [API ERROR] getProductDetail DioException: ${e.message}');
      debugPrint('🔥 [API ERROR] Response: ${e.response?.statusCode} ${e.response?.statusMessage}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          throw Exception('The requested service was not found. Please contact support or try again later.');
        }
        if (e.response!.statusCode == 500) {
          throw Exception('Internal server error. Please try again later.');
        }
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception(e.message ?? 'Network error occurred. Please check your internet connection.');
    } catch (e) {
      debugPrint('🔥 [API ERROR] getProductDetail Unknown Exception: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  @override
  Future<List<ProductTypeModel>> getProductTypes() async {
    try {
      final response = await apiClient.dio.get('/get_product_type');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        return dataList.map((json) => ProductTypeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch product types');
      }
    } on DioException catch (e) {
      debugPrint('🔥 [API ERROR] getProductTypes DioException: ${e.message}');
      throw Exception(e.message ?? 'Network error occurred.');
    } catch (e) {
      debugPrint('🔥 [API ERROR] getProductTypes Unknown Exception: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }
}
