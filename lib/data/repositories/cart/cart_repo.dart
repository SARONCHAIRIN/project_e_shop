// data/repositories/cart/cart_repo.dart

import '../../datasources/cart/cart_service.dart';
import '../../models/cart/cart_model.dart';

class CartRepository {
  final CartService service;

  CartRepository(this.service);

  Future<CartModel> getCart(int userId, String token) => service.getCart(userId, token);
  Future<void> addItem(int userId, int productId, int quantity, String token) => service.addItem(userId, productId, quantity, token);
  Future<void> updateItem(int userId, int cartItemId, int quantity,  String token) => service.updateItem(userId, cartItemId, quantity, token);
  Future<void> deleteItem(int userId, int cartItemId, String token) => service.deleteItem(userId, cartItemId, token);
  Future<void> clearCart(int userId, String token) => service.clearCart(userId, token);
}