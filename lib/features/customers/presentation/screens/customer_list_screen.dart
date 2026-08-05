import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/router/app_router.dart';
import '../providers/customer_provider.dart';
import '../../../orders/presentation/providers/cart_provider.dart';

@RoutePage()
class CustomerListScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode;
  
  const CustomerListScreen({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch customers as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerListProvider.notifier).fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: customerState.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'No Customers Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () {
                    if (widget.isSelectionMode) {
                      ref.read(cartProvider.notifier).setCustomer(customer);
                      context.router.push(const ProductListRoute());
                    }
                  },
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    radius: 25,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (customer.contactNumber != null && customer.contactNumber!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(customer.contactNumber!, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        const SizedBox(height: 4),
                        if (customer.paymentTerms != null && customer.paymentTerms!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.payment, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Terms: ${customer.paymentTerms}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
                  onPressed: () => ref.read(customerListProvider.notifier).fetchCustomers(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
