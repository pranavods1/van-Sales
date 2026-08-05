import 'package:pranav_mechinetest/features/products/data/models/product_model.dart';



abstract class ProductRepository {
  Future<List<ProductModel>> getProducts(int storeId);
}
