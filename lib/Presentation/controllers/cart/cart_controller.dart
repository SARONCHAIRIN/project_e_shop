import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/cart/cart_model.dart';
import '../../../data/repositories/cart/cart_repo.dart';
class CartController extends StateNotifier<CartState> {
  final CartRepository repository;

  CartController({required this.repository}) : super(CartState());

  Future<void> fetchCart() async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) return;

    try {
      state = state.copyWith(isLoading: true);

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

  Future<void> addItem(int productId, int quantity) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) return;

    await repository.addItem(userId, productId, quantity, token);
    await fetchCart();
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (quantity < 1) return;
    if (token == null || userId == null) return;

    await repository.updateItem(userId, cartItemId, quantity, token);
    await fetchCart();
  }

  Future<void> deleteItem(int cartItemId) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) return;

    await repository.deleteItem(userId, cartItemId, token);
    await fetchCart();
  }

  Future<void> clearCart() async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) return;

    await repository.clearCart(userId, token);
    await fetchCart();
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
