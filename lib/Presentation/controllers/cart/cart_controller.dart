// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/storage/token_storage.dart';
// import '../../../data/models/cart/cart_model.dart';
// import '../../../data/repositories/cart/cart_repo.dart';
// class CartController extends StateNotifier<CartState> {
//   final CartRepository repository;
//
//   CartController({required this.repository}) : super(CartState());
//
//   Future<void> fetchCart() async {
//     final storage = TokenStorage();
//     final token = await storage.readToken();
//     final userId = await storage.readUserId();
//
//     if (token == null || userId == null) return;
//
//     try {
//       state = state.copyWith(isLoading: true);
//
//       final cart = await repository.getCart(userId, token);
//
//       state = state.copyWith(
//         isLoading: false,
//         cart: cart,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         hasError: true,
//         errorMessage: "Error loading cart",
//       );
//     }
//   }
//
//   Future<void> addItem(int productId, int quantity) async {
//     final storage = TokenStorage();
//     final token = await storage.readToken();
//     final userId = await storage.readUserId();
//
//     if (token == null || userId == null) return;
//
//     await repository.addItem(userId, productId, quantity, token);
//     await fetchCart();
//   }
//
//   Future<void> updateItem(int cartItemId, int quantity) async {
//     final storage = TokenStorage();
//     final token = await storage.readToken();
//     final userId = await storage.readUserId();
//
//     if (quantity < 1) return;
//     if (token == null || userId == null) return;
//
//     await repository.updateItem(userId, cartItemId, quantity, token);
//     await fetchCart();
//   }
//
//   Future<void> deleteItem(int cartItemId) async {
//     final storage = TokenStorage();
//     final token = await storage.readToken();
//     final userId = await storage.readUserId();
//
//     if (token == null || userId == null) return;
//
//     await repository.deleteItem(userId, cartItemId, token);
//     await fetchCart();
//   }
//
//   Future<void> clearCart() async {
//     final storage = TokenStorage();
//     final token = await storage.readToken();
//     final userId = await storage.readUserId();
//
//     if (token == null || userId == null) return;
//
//     await repository.clearCart(userId, token);
//     await fetchCart();
//   }
// }
//
//
//
//
// class CartState {
//   final bool isLoading;
//   final bool hasError;
//   final String errorMessage;
//   final CartModel? cart;
//
//   CartState({
//     this.isLoading = false,
//     this.hasError = false,
//     this.errorMessage = '',
//     this.cart,
//   });
//
//   CartState copyWith({
//     bool? isLoading,
//     bool? hasError,
//     String? errorMessage,
//     CartModel? cart,
//   }) {
//     return CartState(
//       isLoading: isLoading ?? this.isLoading,
//       hasError: hasError ?? this.hasError,
//       errorMessage: errorMessage ?? this.errorMessage,
//       cart: cart ?? this.cart,
//     );
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/cart/cart_item_model.dart';
import '../../../data/models/cart/cart_model.dart';
import '../../../data/repositories/cart/cart_repo.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/cart/cart_item_model.dart';
import '../../../data/models/cart/cart_model.dart';
import '../../../data/repositories/cart/cart_repo.dart';

class CartController extends StateNotifier<CartState> {
  final CartRepository repository;
  final TokenStorage _storage = TokenStorage();

  CartController({required this.repository}) : super(CartState());

  // ================= FETCH =================
  Future<void> fetchCart() async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();

    if (token == null || userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final cart = await repository.getCart(userId, token);

      state = state.copyWith(
        isLoading: false,
        cart: cart,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "Error loading cart",
      );
    }
  }

  // ================= ADD =================
  Future<void> addItem(int productId, int quantity) async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();
    if (token == null || userId == null) return;

    await repository.addItem(userId, productId, quantity, token);

    await fetchCart(); // keep simple + safe
  }

  // ================= UPDATE (REAL-TIME) =================
  Future<void> updateItem(int cartItemId, int productId, int quantity) async {
    if (quantity < 1) return;

    final token = await _storage.readToken();
    final userId = await _storage.readUserId();
    if (token == null || userId == null) return;

    final oldCart = state.cart;
    if (oldCart == null) return;

    // 1. update UI instantly
    final updatedItems = oldCart.items.map((item) {
      if (item.id == cartItemId) {
        return CartItem(
          id: item.id,
          productSku: item.productSku,
          name: item.name,
          quantity: quantity,
          mainImage: item.mainImage,
        );
      }
      return item;
    }).toList();

    final newTotal = _calcTotal(updatedItems);
    final newCount = _calcCount(updatedItems);

    state = state.copyWith(
      cart: oldCart.copyWith(
        items: updatedItems,
        totalPrice: newTotal,
        totalItems: newCount,
      ),
    );

    // 2. sync API
    try {
      await repository.updateItem(
        userId,
        cartItemId,
        productId,
        quantity,
        token,
      );
    } catch (e) {
      await fetchCart(); // rollback
    }
  }

  // ================= DELETE (REAL-TIME) =================
  Future<void> deleteItem(int cartItemId) async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();
    if (token == null || userId == null) return;

    final oldCart = state.cart;
    if (oldCart == null) return;

    final updatedItems =
    oldCart.items.where((e) => e.id != cartItemId).toList();

    state = state.copyWith(
      cart: oldCart.copyWith(
        items: updatedItems,
        totalPrice: _calcTotal(updatedItems),
        totalItems: _calcCount(updatedItems),
      ),
    );

    try {
      await repository.deleteItem(userId, cartItemId, token);
    } catch (e) {
      state = state.copyWith(cart: oldCart); // rollback
    }
  }

  // ================= CLEAR =================
  Future<void> clearCart() async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();
    if (token == null || userId == null) return;

    await repository.clearCart(userId, token);
    await fetchCart();
  }

  // ================= CALC =================
  double _calcTotal(List<CartItem> items) {
    return items.fold(0, (sum, i) => sum + i.totalPrice);
  }

  int _calcCount(List<CartItem> items) {
    return items.fold(0, (sum, i) => sum + i.quantity);
  }
}
class CartState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final CartModel? cart;

  CartState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.cart,
  });

  CartState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    CartModel? cart,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      cart: cart ?? this.cart,
    );
  }
}
