import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../orders/presentation/providers/cart_provider.dart';
import '../providers/product_provider.dart';

@RoutePage()
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[50],
      body: productState.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No Products Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  context.router.push(ProductDetailRoute(product: product));
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shadowColor: Colors.amber.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.inventory_2, color: Colors.amber.shade700, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.sell, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Price: ₹${product.price}',
                                      style:  TextStyle(
                                        color: Colors.amber.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.percent, size: 14, color: Colors.grey),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Tax: ${product.taxPercentage}%',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(height: 1),
                      ),
                      const Text(
                        'Available Units',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.units.map((unit) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  unit.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${double.tryParse(unit.price)?.toStringAsFixed(2) ?? unit.price}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.read(productListProvider.notifier).fetchProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: cartState.selectedCustomer != null
          ? FloatingActionButton.extended(
              onPressed: () {
                if (cartState.items.isEmpty) {
                  SnackbarUtils.showError(context, 'Cart is empty!');
                  return;
                }
                context.router.push(const CheckoutRoute());
              },
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                '${cartState.items.length} Items - ₹${cartState.grandTotal}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
