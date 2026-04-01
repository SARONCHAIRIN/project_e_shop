/*
import 'package:flutter/material.dart';
import '../../../data/models/cart/cart_item_model.dart';
import '../../../data/repositories/cart/cart_repository_1.dart';

class CartController extends ChangeNotifier {
  final CartRepository repository;

  CartController(this.repository);

  bool isLoading = false;

  List items = [];

  double totalPrice = 0;
  int totalItems = 0;
  Future<void> loadCart(int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await repository.getCart(userId); // call API


      if (response == null || response['data'] == null) {
        items = [];
      } else {
        final data = response['data'];
        final List<dynamic> itemList = data['items'] ?? [];
        items = itemList.map((e) => CartItemModel.fromJson(e)).toList();
      }
    } catch (e) {
      items = [];
      debugPrint('Load cart error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
  Future<void> addToCart(
      int userId, int productId) async {
    await repository.addItem(userId, {
      "product_id": productId,
      "quantity": 1
    });

    await loadCart(userId);
  }

  Future<void> updateQuantity(
      int userId, int cartItemId, int quantity) async {
    await repository.updateItem(userId, cartItemId, {
      "quantity": quantity
    });

    await loadCart(userId);
  }

  Future<void> removeItem(
      int userId, int cartItemId) async {
    await repository.deleteItem(userId, cartItemId);

    await loadCart(userId);
  }

  Future<void> clearCart(int userId) async {
    await repository.clearCart(userId);

    items.clear();
    notifyListeners();
  }
}*/
