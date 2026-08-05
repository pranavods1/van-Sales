import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranav_mechinetest/features/customers/data/models/customer_model.dart';
import 'package:pranav_mechinetest/features/orders/data/models/cart_item_model.dart';

class CartState {
  final CustomerModel? selectedCustomer;
  final List<CartItemModel> items;

  CartState({
    this.selectedCustomer,
    this.items = const [],
  });

  CartState copyWith({
    CustomerModel? selectedCustomer,
    List<CartItemModel>? items,
  }) {
    return CartState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      items: items ?? this.items,
    );
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalTax {
    return items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double get grandTotal {
    return totalAmount + totalTax;
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void setCustomer(CustomerModel customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void addItem(CartItemModel item) {
    final existingIndex = state.items.indexWhere((element) => 
      element.product.id == item.product.id && 
      element.unitDetail.unitId == item.unitDetail.unitId &&
      element.productType == item.productType
    );

    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      final updatedItem = CartItemModel(
        product: existingItem.product,
        unitDetail: existingItem.unitDetail,
        quantity: existingItem.quantity + item.quantity,
        productType: existingItem.productType,
      );
      
      final newItems = List<CartItemModel>.from(state.items);
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void removeItem(int index) {
    final newItems = List<CartItemModel>.from(state.items);
    newItems.removeAt(index);
    state = state.copyWith(items: newItems);
  }

  void clearCart() {
    state = CartState();
  }
}
