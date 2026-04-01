/*
import 'package:flutter/material.dart';

import '../../../data/datasources/cart/cart_service.dart';
import '../../../data/models/cart/cart_model.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  final String userToken;

  const CartScreen({
    super.key,
    required this.userId,
    required this.userToken,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartService cartService;
  CartModel? cart;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cartService = CartService(token: widget.userToken);
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final result = await cartService.getCart(widget.userId);
      setState(() {
        cart = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> increaseQty(int index) async {
    final item = cart!.items[index];

    await cartService.addToCart(
      userId: widget.userId,
      productId: item.productId,
      quantity: 1,
      sku: item.sku,
    );

    await loadCart();
  }

  Future<void> decreaseQty(int index) async {
    final item = cart!.items[index];

    if (item.quantity > 1) {
      await cartService.updateQuantity(
        widget.userId,
        item.productId,
        item.quantity - 1,
      );
      await loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (cart == null || cart!.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Cart")),
        body: const Center(
          child: Text(
            "Your cart is empty 🛒",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: Column(
        children: [

          /// CART ITEMS
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadCart,
              child: ListView.builder(
                itemCount: cart!.items.length,
                itemBuilder: (context, index) {
                  final item = cart!.items[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [

                          /// LEFT SIDE
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "SKU: ${item.sku}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "\$${item.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// RIGHT SIDE ( + / - )
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => decreaseQty(index),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => increaseQty(index),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// TOTAL + CHECKOUT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Column(
              children: [

                /// TOTAL ROW
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${cart!.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// CHECKOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckoutScreen(cart: cart!),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
