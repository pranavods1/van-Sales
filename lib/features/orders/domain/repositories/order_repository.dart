import '../../data/models/cart_item_model.dart';
import '../../../customers/data/models/customer_model.dart';

abstract class OrderRepository {
  Future<bool> createVanSale({
    required CustomerModel customer,
    required List<CartItemModel> items,
    required double total,
    required double tax,
    required double grandTotal,
    required double discount,
    required String remarks,
  });
}
