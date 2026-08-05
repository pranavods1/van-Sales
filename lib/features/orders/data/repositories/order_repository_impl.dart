import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/order_repository.dart';

import '../models/cart_item_model.dart';
import '../../../customers/data/models/customer_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiClient _apiClient;

  OrderRepositoryImpl(this._apiClient);

  @override
  Future<bool> createVanSale({
    required CustomerModel customer,
    required List<CartItemModel> items,
    required double total,
    required double tax,
    required double grandTotal,
    required double discount,
    required String remarks,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('store_id') ?? 0;
      final userId = prefs.getInt('user_id') ?? 0;
      final vanId = prefs.getInt('van_id') ?? 0;

      final List<int> itemIds = items.map((e) => e.product.id).toList();
      final List<int> quantities = items.map((e) => e.quantity).toList();
      final List<double> mrps = items.map((e) => double.tryParse(e.unitDetail.price) ?? 0.0).toList();
      final List<int> productTypes = items.map((e) => e.productType).toList();
      final List<int> units = items.map((e) => e.unitDetail.unitId).toList();

      final payload = {
        "customer_id": customer.id,
        "store_id": storeId,
        "user_id": userId,
        "van_id": vanId,
        "save_mode": "normal",
        "order_type": 1,
        "discount": discount,
        "total": total,
        "total_tax": tax,
        "grand_total": grandTotal,
        "round_off": 0,
        "if_vat": 1,
        "remarks": remarks.isEmpty ? "Van Sale" : remarks,
        "item_id": itemIds,
        "quantity": quantities,
        "mrp": mrps,
        "product_type": productTypes,
        "unit": units,
      };

      final response = await _apiClient.dio.post('/vansale.store', data: payload);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('messages')) {
          throw Exception(data['messages'].toString());
        }
      }
      throw Exception(e.message ?? 'Failed to submit order');
    }
  }
}
