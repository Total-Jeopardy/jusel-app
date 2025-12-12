import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';

class CartState {
  final List<CartItem> items;

  CartState({List<CartItem>? items}) : items = items ?? [];

  int get itemCount => items.length;
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere(
      (i) =>
          i.productId == item.productId &&
          i.effectivePrice == item.effectivePrice &&
          i.overrideReason == item.overrideReason,
    );

    if (existingIndex >= 0) {
      // Update quantity if same product with same price
      final existingItem = state.items[existingIndex];
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void removeItem(int index) {
    final updatedItems = List<CartItem>.from(state.items);
    updatedItems.removeAt(index);
    state = state.copyWith(items: updatedItems);
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});



