import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranav_mechinetest/features/products/data/models/product_model.dart';
import 'package:pranav_mechinetest/features/products/data/repositories/product_repository_impl.dart';
import 'package:pranav_mechinetest/features/products/domain/repositories/product_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/product_type_model.dart';


final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepositoryImpl(apiClient);
});

final productTypeProvider = FutureProvider<List<ProductTypeModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductTypes();
});

final productListProvider = NotifierProvider<ProductListNotifier, AsyncValue<List<ProductModel>>>(() {
  return ProductListNotifier();
});

class ProductListNotifier extends Notifier<AsyncValue<List<ProductModel>>> {
  @override
  AsyncValue<List<ProductModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('store_id') ?? 0;

      final repository = ref.read(productRepositoryProvider);
      final products = await repository.getProducts(storeId);
      
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
