import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

@RoutePage()
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _discountController.addListener(() {
      setState(() {}); // Rebuild UI to update grand total dynamically
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    final cartState = ref.read(cartProvider);
    if (cartState.selectedCustomer == null || cartState.items.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(orderRepositoryProvider);
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      final finalGrandTotal = cartState.grandTotal - discount;

      final success = await repository.createVanSale(
        customer: cartState.selectedCustomer!,
        items: cartState.items,
        total: cartState.totalAmount,
        tax: cartState.totalTax,
        grandTotal: finalGrandTotal,
        discount: discount,
        remarks: _remarksController.text,
      );

      if (success) {
        if (!mounted) return;
        SnackbarUtils.showSuccess(context, 'Invoice created successfully!');
        ref.read(cartProvider.notifier).clearCart();
        // Go back to dashboard
        context.router.replaceAll([const DashboardRoute()]);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getProductTypeName(int type) {
    switch (type) {
      case 1: return 'Normal';
      case 2: return 'FOC';
      case 3: return 'Change';
      case 4: return 'Sample';
      default: return 'Unknown';
    }
  }

  bool _showAllItems = false;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final items = cartState.items;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final finalGrandTotal = cartState.grandTotal - discount;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(
          child: Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    final displayedItemsCount = _showAllItems ? items.length : (items.length > 5 ? 5 : items.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Info
            if (cartState.selectedCustomer != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Customer', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              cartState.selectedCustomer!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (items.length > 5)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllItems = !_showAllItems;
                      });
                    },
                    child: Text(_showAllItems ? 'Show Less' : 'View All (${items.length})'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Cart Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedItemsCount,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '${item.product.name} (${item.unitDetail.unitName})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${_getProductTypeName(item.productType)}'),
                        Text('Price: ₹${item.unitDetail.price}  x  ${item.quantity}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${item.totalPrice}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref.read(cartProvider.notifier).removeItem(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (items.length > 5 && !_showAllItems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    '+ ${items.length - 5} more items',
                    style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ),

            const SizedBox(height: 16),
            const Text('Additional Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount Amount (₹)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            // Totals
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', cartState.totalAmount),
                    const SizedBox(height: 8),
                    _buildTotalRow('Tax Amount', cartState.totalTax),
                    if (discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildTotalRow('Discount', discount, isDiscount: true),
                    ],
                    const Divider(height: 24),
                    _buildTotalRow('Grand Total', finalGrandTotal, isGrand: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('SUBMIT INVOICE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isGrand = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isGrand ? 18 : 16,
            fontWeight: isGrand ? FontWeight.bold : null,
            color: isGrand ? Colors.black : (isDiscount ? Colors.red : Colors.grey[700]),
          ),
        ),
        Text(
          isDiscount ? '-₹${amount.toStringAsFixed(2)}' : '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isGrand ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isGrand ? Colors.green : (isDiscount ? Colors.red : Colors.black),
          ),
        ),
      ],
    );
  }
}
