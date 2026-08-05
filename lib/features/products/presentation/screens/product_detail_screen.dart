import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_detail_model.dart';
import '../providers/product_detail_provider.dart';
import '../../../orders/presentation/providers/cart_provider.dart';
import '../../../orders/data/models/cart_item_model.dart';
import '../../../../core/utils/snackbar_utils.dart';

@RoutePage()
class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedProductType = 1; // 1 = Normal, 2 = FOC, 3 = Change, 4 = Sample
  
  // Map to store quantities per unit ID
  final Map<int, int> _quantities = {};

  void _incrementQty(int unitId) {
    setState(() {
      _quantities[unitId] = (_quantities[unitId] ?? 0) + 1;
    });
  }

  void _decrementQty(int unitId) {
    setState(() {
      final current = _quantities[unitId] ?? 0;
      if (current > 0) {
        _quantities[unitId] = current - 1;
      }
    });
  }

  void _addAllToCart(List<ProductDetailModel> details) {
    int totalAdded = 0;
    for (var detail in details) {
      final qty = _quantities[detail.unitId] ?? 0;
      if (qty > 0) {
        final cartItem = CartItemModel(
          product: widget.product,
          unitDetail: detail,
          quantity: qty,
          productType: _selectedProductType,
        );
        ref.read(cartProvider.notifier).addItem(cartItem);
        
        // Reset quantity
        setState(() {
          _quantities[detail.unitId] = 0;
        });
        totalAdded++;
      }
    }
    
    if (totalAdded > 0) {
      SnackbarUtils.showSuccess(context, 'Successfully added items to Cart!');
    } else {
      SnackbarUtils.showError(context, 'Please increase quantity for at least one unit');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(productDetailProvider(widget.product.id));
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Basic Product Info Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.inventory_2, color: Colors.blue, size: 40),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Base Price: ₹${widget.product.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tax Percentage: ${widget.product.taxPercentage}%',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Only show Product Type selector if a customer is selected
            if (cartState.selectedCustomer != null)
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Product Type',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Normal'),
                          selected: _selectedProductType == 1,
                          onSelected: (val) => setState(() => _selectedProductType = 1),
                        ),
                        ChoiceChip(
                          label: const Text('FOC'),
                          selected: _selectedProductType == 2,
                          onSelected: (val) => setState(() => _selectedProductType = 2),
                        ),
                        ChoiceChip(
                          label: const Text('Change'),
                          selected: _selectedProductType == 3,
                          onSelected: (val) => setState(() => _selectedProductType = 3),
                        ),
                        ChoiceChip(
                          label: const Text('Sample'),
                          selected: _selectedProductType == 4,
                          onSelected: (val) => setState(() => _selectedProductType = 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 2. Detailed Units Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Detailed Unit Pricing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            detailState.when(
              data: (details) {
                if (details.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No detailed units found.', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    final qty = _quantities[detail.unitId] ?? 0;
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                                  child: const Icon(Icons.layers, color: Colors.green),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.unitName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        'Price: ₹${detail.price}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Quantity Controls
                            if (cartState.selectedCustomer != null) ...[
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: Colors.red,
                                    iconSize: 30,
                                    onPressed: () => _decrementQty(detail.unitId),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.green,
                                    iconSize: 30,
                                    onPressed: () => _incrementQty(detail.unitId),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: Text(error.toString())),
              ),
            ),
            const SizedBox(height: 100), // padding for bottom bar
          ],
        ),
      ),
      bottomSheet: cartState.selectedCustomer != null
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: detailState.maybeWhen(
                    data: (details) => ElevatedButton.icon(
                      onPressed: () => _addAllToCart(details),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox(),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
