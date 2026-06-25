import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Presentation/controllers/cart/cart_controller.dart';
import '../data/datasources/cart/cart_service.dart';
import '../data/repositories/cart/cart_repo.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.read(cartServiceProvider));
});

final cartControllerProvider =
StateNotifierProvider<CartController, CartState>((ref) {
  return CartController(
    repository: ref.read(cartRepositoryProvider),
  );
});