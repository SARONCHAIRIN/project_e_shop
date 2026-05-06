
import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/cart/cart_model.dart';
import '../../../data/repositories/cart/cart_repo.dart';

class CartController extends ChangeNotifier {
  final CartRepository repository;

  CartController({required this.repository});

  bool isLoading = false;
  CartModel? cart;

  bool hasError = false;
  String errorMessage = '';

  // =========================
  // FETCH CART
  // =========================
  Future<void> fetchCart() async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) {
      debugPrint(" Token or userId is null");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      cart = await repository.getCart(userId, token);
    } catch (e) {
      debugPrint(" Fetch cart error: $e");

      hasError = true;

      errorMessage = e.toString().contains('Socket')

          ? "No internet connection"

          : "Server error. Please try again";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // ADD ITEM
  // =========================
  Future<void> addItem(int productId, int quantity) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) {
      debugPrint(" Token or userId is null");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await repository.addItem(userId, productId, quantity, token);
      await fetchCart();
    } catch (e) {
      debugPrint(" Add item error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> updateItem(int cartItemId, int quantity) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();
    if (quantity < 1) return;

    if (token == null || userId == null) {
      debugPrint("Token or userId is null");
      return;
    }

    // Update locally immediately — no isLoading, no flicker
    final index = cart!.items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      cart!.items[index].quantity = quantity;
      notifyListeners();
    }

    try {
      await repository.updateItem(userId, cartItemId, quantity, token);
    } catch (e) {
      debugPrint("Update item error: $e");
      // Revert by re-fetching if API fails
      await fetchCart();
    }
  }

  // =========================
  // DELETE ITEM
  // =========================
  Future<void> deleteItem(int cartItemId) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) {
      debugPrint(" Token or userId is null");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteItem(userId, cartItemId, token);
      await fetchCart();
    } catch (e) {
      debugPrint(" Delete item error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // =========================
  // CLEAR CART
  // =========================
  Future<void> clearCart() async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();

    if (token == null || userId == null) {
      debugPrint(" Token or userId is null");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await repository.clearCart(userId, token);
      await fetchCart();
    } catch (e) {
      debugPrint(" Clear cart error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}