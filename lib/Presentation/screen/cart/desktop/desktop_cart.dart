import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:e_shop/provider/cart_provider.dart';
import 'package:e_shop/Presentation/controllers/cart/cart_controller.dart';
import 'package:e_shop/Presentation/screen/order/checkout_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../data/models/cart/cart_item_model.dart';
import '../../order/checkout/checkout_page_controll.dart';

class DesktopCart extends ConsumerStatefulWidget {
  final int userId;
  final String token;

  const DesktopCart({super.key, required this.userId, required this.token});

  @override
  ConsumerState<DesktopCart> createState() => _DesktopCartState();
}

class _DesktopCartState extends ConsumerState<DesktopCart> {
  // Design system constants
  static const Color _primaryBlue = Color(0xFF0066FF);
  static const Color _bgScreen = Color(0xFFF7F9FC);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF7A7A9D);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartControllerProvider.notifier).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);
    final totalItems =
        cartState.cart?.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ) ??
        0;

    return Scaffold(
      backgroundColor: _bgScreen,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Back Option and Cart Title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Shopping Cart",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$totalItems items in your cart",
                        style: TextStyle(
                          fontSize: 14,
                          color: _textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Dynamic Body View
              Expanded(
                child: cartState.isLoading
                    ? _centerLoading()
                    : cartState.cart == null || cartState.cart!.items.isEmpty
                    ? _buildEmptyCart()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT: PRODUCTS LIST (65%)
                          Expanded(
                            flex: 7,
                            child: ListView.builder(
                              itemCount: cartState.cart!.items.length,
                              itemBuilder: (context, index) {
                                final item = cartState.cart!.items[index];
                                return _cartItem(item, controller);
                              },
                            ),
                          ),

                          const SizedBox(width: 32),

                          /// RIGHT: ORDER SUMMARY (35%)
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: _summary(cartState.cart!.totalPrice),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MODERN CART ITEM TILE =================
  Widget _cartItem(CartItem item, CartController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _borderColor.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image Container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              item.mainImage.isNotEmpty
                  ? item.mainImage.last
                  : "https://via.placeholder.com/120",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 100,
                  height: 100,
                  color: _bgScreen,
                  child: const Icon(Icons.image_outlined, color: _textMuted),
                );
              },
            ),
          ),

          const SizedBox(width: 20),

          // Details & Price Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${item.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: _primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),

                // Interactive Counter controls
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _bgScreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _borderColor.withOpacity(0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            color: _textDark,
                            onPressed: item.quantity > 1
                                ? () {
                                    controller.updateItem(
                                      item.id,
                                      item.productSku.id,
                                      item.quantity - 1,
                                    );
                                  }
                                : null,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${item.quantity}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            color: _textDark,
                            onPressed: () {
                              controller.updateItem(
                                item.id,
                                item.productSku.id,
                                item.quantity + 1,
                              );
                            },
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button Action
          IconButton(
            onPressed: () => controller.deleteItem(item.id),
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            color: Colors.redAccent,
            style: IconButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.08),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: "Remove item",
          ),
        ],
      ),
    );
  }

  // ================= MODERN ORDER SUMMARY PANEL =================
  Widget _summary(double total) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow("Subtotal", "\$${total.toStringAsFixed(2)}"),
          const SizedBox(height: 4),
          _summaryRow("Shipping Fee", "FREE", isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: _borderColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Promo Code Input Box
          TextField(
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Promo Code",
              hintStyle: TextStyle(color: _textMuted, fontSize: 13),
              filled: true,
              fillColor: _bgScreen,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _borderColor.withOpacity(0.8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Checkout Action Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: _primaryBlue.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Proceed to Checkout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isFree ? Colors.green : _textDark,
          ),
        ),
      ],
    );
  }

  void _openCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          repo: AddressRepository(AddressService()),
          storage: TokenStorage(),
          userId: widget.userId,
          token: widget.token,
          addressId: 0,
        ),
      ),
    );
  }

  Widget _buildEmptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty.json',
          width: 180,
          height: 180,
          repeat: true,
          animate: true,
        ),
        const SizedBox(height: 16),
        Text(
          "cart_is_empty".tr(),
          style: const TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Looks like you haven't added anything to your cart yet",
          style: TextStyle(color: _textMuted, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _centerLoading() {
    return const Center(child: CircularProgressIndicator(color: _primaryBlue));
  }
}
