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
import '../../../data/models/cart/cart_model.dart';
import '../../../data/repositories/cart/cart_repo.dart';

class CartController extends StateNotifier<CartState> {
  final CartRepository repository;
  final TokenStorage _storage = TokenStorage();

  CartController({required this.repository}) : super(CartState());

  Future<void> fetchCart() async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();

    if (token == null || userId == null) return;

    try {
      state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

      final cart = await repository.getCart(userId, token);

      state = state.copyWith(
        isLoading: false,
        hasError: false,
        errorMessage: '',
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

  Future<void> addItem(int productId, int quantity) async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();

    if (token == null || userId == null) return;

    try {
      state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');
      await repository.addItem(userId, productId, quantity, token);
      await fetchCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "Error adding item to cart",
      );
    }
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    if (quantity < 1) return;

    final token = await _storage.readToken();
    final userId = await _storage.readUserId();

    if (token == null || userId == null) return;

    try {
      state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');
      await repository.updateItem(userId, cartItemId, quantity, token);
      await fetchCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "Error updating item",
      );
    }
  }

  // Future<void> updateItem(int cartItemId, int quantity) async {
  //   if (quantity < 1) return;
  //
  //   final token = await _storage.readToken();
  //   final userId = await _storage.readUserId();
  //
  //   if (token == null || userId == null) return;
  //
  //   // The backend's update endpoint requires the underlying SKU id (product_id),
  //   // not the cart item's own id. Look it up from the cart we already have in state.
  //   final currentItem = state.cart?.items.firstWhere(
  //         (item) => item.id == cartItemId,
  //     orElse: () => throw Exception("Cart item not found"),
  //   );
  //
  //   if (currentItem == null) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       hasError: true,
  //       errorMessage: "Cart item not found",
  //     );
  //     return;
  //   }
  //   //
  //   final productId = currentItem.productSku.id;
  //
  //   try {
  //     state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');
  //     await repository.updateItem(userId, cartItemId, productId, quantity, token);
  //     await fetchCart();
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       hasError: true,
  //       errorMessage: "Error updating item",
  //     );
  //   }
  // }
  Future<void> deleteItem(int cartItemId) async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();

    if (token == null || userId == null) return;

    try {
      state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');
      await repository.deleteItem(userId, cartItemId, token);
      await fetchCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "Error removing item",
      );
    }
  }

  Future<void> clearCart() async {
    final token = await _storage.readToken();
    final userId = await _storage.readUserId();

    if (token == null || userId == null) return;

    try {
      state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');
      await repository.clearCart(userId, token);
      await fetchCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "Error clearing cart",
      );
    }
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