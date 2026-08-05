import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_detail_model.dart';
import 'product_provider.dart';

final productDetailProvider = FutureProvider.autoDispose.family<List<ProductDetailModel>, int>((ref, productId) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getProductDetail(productId);
});
