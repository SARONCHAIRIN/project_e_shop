import 'package:badges/badges.dart' as badges;
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/data/datasources/product_service_eshop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/product_model_eshop.dart';
import '../../../core/storage/token_storage.dart';
import '../../../provider/cart_provider.dart';
import '../cart/cart_screen.dart';

/// Screen-specific responsive sizing. Same idea as the sub-category
/// carousel widget: compute everything from width once, breakpoints
/// mobile / tablet / desktop / wide.
enum _Device { mobile, tablet, desktop, wide }

class _Responsive {
  final _Device device;
  final double maxContentWidth;
  final int crossAxisCount;
  final double childAspectRatio;
  final double gridSpacing;
  final double horizontalPadding;
  final double cardTitleFontSize;
  final double cardPriceFontSize;
  final double appBarTitleFontSize;

  const _Responsive({
    required this.device,
    required this.maxContentWidth,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.gridSpacing,
    required this.horizontalPadding,
    required this.cardTitleFontSize,
    required this.cardPriceFontSize,
    required this.appBarTitleFontSize,
  });

  factory _Responsive.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) {
      return const _Responsive(
        device: _Device.mobile,
        maxContentWidth: double.infinity,
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        gridSpacing: 10,
        horizontalPadding: 10,
        cardTitleFontSize: 14,
        cardPriceFontSize: 15,
        appBarTitleFontSize: 16,
      );
    } else if (width < 1024) {
      return const _Responsive(
        device: _Device.tablet,
        maxContentWidth: 960,
        crossAxisCount: 3,
        childAspectRatio: 0.66,
        gridSpacing: 14,
        horizontalPadding: 16,
        cardTitleFontSize: 15,
        cardPriceFontSize: 16,
        appBarTitleFontSize: 18,
      );
    } else if (width < 1440) {
      return const _Responsive(
        device: _Device.desktop,
        maxContentWidth: 1280,
        crossAxisCount: 4,
        childAspectRatio: 0.70,
        gridSpacing: 18,
        horizontalPadding: 24,
        cardTitleFontSize: 15,
        cardPriceFontSize: 17,
        appBarTitleFontSize: 19,
      );
    } else {
      return const _Responsive(
        device: _Device.wide,
        maxContentWidth: 1560,
        crossAxisCount: 5,
        childAspectRatio: 0.72,
        gridSpacing: 20,
        horizontalPadding: 32,
        cardTitleFontSize: 16,
        cardPriceFontSize: 18,
        appBarTitleFontSize: 20,
      );
    }
  }
}

class ProductScreen_sub extends ConsumerStatefulWidget {
  final int subcategoryId;
  final String subcategoryName;
  final User_AuthRepository repository;

  ProductScreen_sub({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.repository,
  });

  @override
  ConsumerState<ProductScreen_sub> createState() => _ProductScreen_subState();
}

class _ProductScreen_subState extends ConsumerState<ProductScreen_sub>
    with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  ProductSku? selectedSku;
  bool heart = false;
  final ProductService productService = ProductService();

  // Flying animation variables
  final GlobalKey<State> _cartIconKey = GlobalKey<State>();
  List<_FlyingCartAnimation> _flyingAnimations = [];

  // Map to store keys for each product's cart button
  final Map<int, GlobalKey> _productCartButtonKeys = {};

  Future<List<Product>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = apiService.fetchProductsBySubcategoryId(
      widget.subcategoryId,
    );
  }

  @override
  void dispose() {
    for (var animation in _flyingAnimations) {
      animation.controller.dispose();
    }
    super.dispose();
  }

  // Create flying animation from product to cart
  void _createFlyingAnimation(Offset startPosition, int productId) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final flyingAnimation = _FlyingCartAnimation(
      startPosition: startPosition,
      cartIconKey: _cartIconKey,
      controller: controller,
    );

    setState(() {
      _flyingAnimations.add(flyingAnimation);
    });

    controller.forward().then((_) {
      setState(() {
        _flyingAnimations.remove(flyingAnimation);
      });
      controller.dispose();
    });
  }

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginBottomSheet(authRepository: widget.repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _Responsive.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.white,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        title: Text(
          overflow: TextOverflow.ellipsis,
          widget.subcategoryName,
          style: TextStyle(
            fontSize: sizes.appBarTitleFontSize,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          // Cart icon with badge
          Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartControllerProvider);
              final itemCount = cartState.cart?.totalItems ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  key: _cartIconKey,
                  onTap: () async {
                    final storage = TokenStorage();
                    final userId = await storage.getUserId();
                    final token = await storage.getToken();

                    if (userId != null && token != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CartScreen(userId: userId, token: token),
                        ),
                      );
                    }
                  },
                  child: badges.Badge(
                    badgeContent: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Color(0xFFFF4D4D),
                      padding: EdgeInsets.all(5),
                    ),
                    badgeAnimation: const badges.BadgeAnimation.scale(
                      animationDuration: Duration(milliseconds: 300),
                    ),
                    showBadge: itemCount > 0,
                    position: badges.BadgePosition.topEnd(top: -8, end: -8),
                    child: Icon(
                      CupertinoIcons.cart,
                      size: 26,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              /// ================= LOADING =================
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerPopular(sizes);
              }

              /// ================= ERROR =================
              if (snapshot.hasError) {
                return Center(
                  child: SizedBox(
                    height: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: Lottie.asset(
                            'assets/animations/Error_404.json',
                            repeat: true,
                            animate: true,
                            height: 150,
                            width: 150,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Something went wrong",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              /// ================= EMPTY =================
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: SizedBox(
                    height: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: Lottie.asset(
                            'assets/animations/empty.json',
                            repeat: true,
                            animate: true,
                            height: 140,
                            width: 140,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No products found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Try a different keyword",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final products = snapshot.data!;

              // Center + cap width on tablet/desktop/web so the grid
              // doesn't stretch into absurdly wide cards.
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: sizes.maxContentWidth),
                  child: GridView.builder(
                    padding: EdgeInsets.all(sizes.horizontalPadding),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: sizes.crossAxisCount,
                      childAspectRatio: sizes.childAspectRatio,
                      crossAxisSpacing: sizes.gridSpacing,
                      mainAxisSpacing: sizes.gridSpacing,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        sizes: sizes,
                        selectedSku: selectedSku,
                        onTapCard: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                                subcategoryId: widget.subcategoryId,
                                subcategoryName: widget.subcategoryName,
                                repository: widget.repository,
                              ),
                            ),
                          );
                        },
                        cartButtonKey: _productCartButtonKeys.putIfAbsent(
                          product.id,
                              () => GlobalKey(),
                        ),
                        onAddToCart: () => _handleAddToCart(context, product),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // Render flying animations
          ..._flyingAnimations,
        ],
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context, Product product) async {
    final storage = TokenStorage();
    final cartController = ref.read(cartControllerProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final token = await storage.readToken();
      final userId = await storage.readUserId();

      if (userId == null || token == null) {
        _showLoginSheet(context);
      }

      if (token == null || token.isEmpty) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Please login first'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (userId == null || userId <= 0) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('User session invalid. Please login again'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final GlobalKey iconKey = _productCartButtonKeys[product.id]!;
      final RenderBox? iconBox =
      iconKey.currentContext?.findRenderObject() as RenderBox?;

      if (iconBox == null) {
        debugPrint('Error: Could not find icon button render box');
        return;
      }

      final productPosition = iconBox.localToGlobal(Offset.zero);

      if (mounted) {
        _createFlyingAnimation(productPosition, product.id);
      }

      debugPrint('Adding product ${product.id} to cart for user $userId');

      await cartController.addItem(product.id, 1);
    } catch (e, stackTrace) {
      debugPrint('Error adding to cart: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Widget _buildShimmerPopular(_Responsive sizes) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: sizes.maxContentWidth),
      child: GridView.builder(
        padding: EdgeInsets.all(sizes.horizontalPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: sizes.crossAxisCount,
          childAspectRatio: sizes.childAspectRatio,
          crossAxisSpacing: sizes.gridSpacing,
          mainAxisSpacing: sizes.gridSpacing,
        ),
        itemCount: sizes.crossAxisCount * 3,
        itemBuilder: (context, index) => _ProductCardShimmer(sizes: sizes),
      ),
    ),
  );}

/// Modernized product card: flat elevation replaced with a soft shadow,
/// clean typography, no glow effects, and a filled circular cart button.
class _ProductCard extends StatelessWidget {
  final Product product;
  final _Responsive sizes;
  final ProductSku? selectedSku;
  final VoidCallback onTapCard;
  final GlobalKey cartButtonKey;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.sizes,
    required this.selectedSku,
    required this.onTapCard,
    required this.cartButtonKey,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = selectedSku != null
        ? selectedSku!.price
        : product.lowestPrice;

    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: product.mainImage.isEmpty
                    ? Image.asset(
                  'assets/images/default_image.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : Image.network(
                  product.mainImage.isNotEmpty
                      ? product.mainImage.first
                      : "",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/default_image.png',
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Details ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sizes.cardTitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "\$${price.toStringAsFixed(2)}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.cardPriceFontSize,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1FAA59),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Material(
                        color: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          key: cartButtonKey,
                          customBorder: const CircleBorder(),
                          onTap: onAddToCart,
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              CupertinoIcons.cart_fill,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Flying cart animation widget
class _FlyingCartAnimation extends StatelessWidget {
  final Offset startPosition;
  final GlobalKey<State> cartIconKey;
  final AnimationController controller;

  _FlyingCartAnimation({
    required this.startPosition,
    required this.cartIconKey,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Get the cart icon position
    RenderBox? cartBox;
    try {
      cartBox = cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    } catch (e) {
      // If can't find cart box, just skip animation
      return const SizedBox.shrink();
    }

    if (cartBox == null) {
      return const SizedBox.shrink();
    }

    final endPosition = cartBox.localToGlobal(Offset.zero);

    // Animate position from start to end
    final positionAnimation = Tween<Offset>(
      begin: startPosition,
      end: endPosition,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad));

    // Animate scale down
    final scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad));

    // Animate opacity
    final opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: positionAnimation.value.dx,
          top: positionAnimation.value.dy,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(204, 63, 81, 181),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(128, 63, 81, 181),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.cart_fill,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class _ProductCardShimmer extends StatelessWidget {
  final _Responsive sizes;

  const _ProductCardShimmer({required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image block ─────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
            ),

            // ── Details block ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: sizes.cardTitleFontSize,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: sizes.cardTitleFontSize,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: sizes.cardPriceFontSize,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}