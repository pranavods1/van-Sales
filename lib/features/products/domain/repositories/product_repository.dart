import 'package:pranav_mechinetest/features/products/data/models/product_model.dart';
import 'package:pranav_mechinetest/features/products/data/models/product_detail_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts(int storeId);
  Future<List<ProductDetailModel>> getProductDetail(int productId);
}
