import 'package:pranav_mechinetest/features/products/data/models/product_detail_model.dart';
import 'package:pranav_mechinetest/features/products/data/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final ProductDetailModel unitDetail;
  final int quantity;
  final int productType; // 1 = Normal, 2 = FOC, 3 = Change, 4 = Sample

  CartItemModel({
    required this.product,
    required this.unitDetail,
    required this.quantity,
    required this.productType,
  });

  double get totalPrice {
    if (productType == 2 || productType == 4) { // FOC or Sample
      return 0.0;
    }
    final price = double.tryParse(unitDetail.price) ?? 0.0;
    return price * quantity;
  }

  double get taxAmount {
    if (productType == 2 || productType == 4) {
      return 0.0;
    }
    return (totalPrice * product.taxPercentage) / 100;
  }
}
