import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/models/customer_model.dart';

// 1. ApiClient Provider (can be shared, but redefined here for simplicity if needed, better to use a global one but this works)
final customerApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// 2. CustomerRepository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final apiClient = ref.watch(customerApiClientProvider);
  return CustomerRepositoryImpl(apiClient);
});

// 3. CustomerList Notifier Provider (Strict Riverpod 3.0 Standard)
final customerListProvider = NotifierProvider<CustomerListNotifier, AsyncValue<List<CustomerModel>>>(() {
  return CustomerListNotifier();
});

class CustomerListNotifier extends Notifier<AsyncValue<List<CustomerModel>>> {
  @override
  AsyncValue<List<CustomerModel>> build() {
    // Initial state is loading, we can fetch immediately or wait for a fetch call
    return const AsyncValue.loading();
  }

  Future<void> fetchCustomers() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final routeId = prefs.getInt('route_id') ?? 0;
      final storeId = prefs.getInt('store_id') ?? 0;

      final repository = ref.read(customerRepositoryProvider);
      final customers = await repository.getCustomers(routeId, storeId);
      
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
