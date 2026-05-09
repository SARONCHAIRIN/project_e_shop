
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/data/datasources/product_service_eshop.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/product_model_eshop.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Presentation/controllers/cart/cart_controller.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/storage/token_storage.dart';
import '../cart/cart_screen.dart';

class ProductScreen_sub extends StatefulWidget {
  final int subcategoryId;
  final String subcategoryName;

  ProductScreen_sub({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  State<ProductScreen_sub> createState() => _ProductScreen_subState();
}

class _ProductScreen_subState extends State<ProductScreen_sub>
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          widget.subcategoryName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          // Cart icon with badge
          Consumer<CartController>(
            builder: (context, cartController, _) {
              final itemCount = cartController.cart?.totalItems ?? 0;
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
                          builder: (context) => CartScreen(
                            userId: userId,
                            token: token,
                          ),
                        ),
                      );
                    }
                  },
                  child: badges.Badge(
                    badgeContent: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    badgeAnimation: const badges.BadgeAnimation.scale(
                      animationDuration: Duration(milliseconds: 300),
                    ),
                    showBadge: itemCount > 0,
                    position: badges.BadgePosition.topEnd(top: -10, end: -10),
                    child: Icon(
                      CupertinoIcons.cart,
                      size: 28,
                      color: Colors.blue,
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
            future:
                apiService.fetchProductsBySubcategoryId(widget.subcategoryId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              final products = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 0.3,
                            shadowColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                left: 10,
                                right: 2,
                                bottom: 5,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: product.mainImage.isEmpty
                                          ? Image.asset(
                                              'assets/images/default_image.png',
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                            )
                                          : Image.network(
                                              product.mainImage,
                                              width: double.infinity,
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return Image.asset(
                                                  'assets/images/default_image.png',
                                                  fit: BoxFit.fill,
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 3),
                                        Divider(
                                          height: 1,
                                          thickness: 0.9,
                                          color: Colors.grey.shade200,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(product.name,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 2,
                                            right: 5,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                selectedSku != null
                                                    ? "\$${selectedSku!.price.toStringAsFixed(2)}"
                                                    : "\$${product.lowestPrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Colors.yellowAccent,
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      blurRadius: 3,
                                                      spreadRadius: 0.4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  child: SizedBox(width: 1)),

                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blueAccent.shade100,
                                                      spreadRadius: 1,
                                                      blurStyle: BlurStyle.outer,
                                                      blurRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  key: _productCartButtonKeys.putIfAbsent(
                                                    product.id,
                                                    () => GlobalKey(),
                                                  ),
                                                  onPressed: () async {
                                                    // Store references before async operation
                                                    final storage = TokenStorage();
                                                    final cartController = context.read<CartController>();
                                                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                                                    try {
                                                      // Verify token and userId exist
                                                      final token = await storage.readToken();
                                                      final userId = await storage.readUserId();


                                                      if (token == null || token.isEmpty) {
                                                        
                                                        if (mounted) {
                                                          scaffoldMessenger.showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Please login first'),
                                                              duration: Duration(seconds: 2),
                                                              backgroundColor: Colors.orange,
                                                            ),
                                                          );
                                                        }
                                                        if(mounted) {
                                                          Navigator.pushNamed(context,LoginScreen.routeName);
                                                        }
                                                        return;
                                                      }

                                                      if (userId == null || userId <= 0) {
                                                        if (mounted) {
                                                          scaffoldMessenger.showSnackBar(
                                                            const SnackBar(
                                                              content: Text('User session invalid. Please login again'),
                                                              duration: Duration(seconds: 2),
                                                              backgroundColor: Colors.orange,
                                                            ),
                                                          );
                                                        }
                                                        return;
                                                      }

                                                      // Get product icon button position
                                                      final GlobalKey iconKey = _productCartButtonKeys[product.id]!;
                                                      final RenderBox? iconBox = iconKey.currentContext?.findRenderObject() as RenderBox?;

                                                      if (iconBox == null) {
                                                        debugPrint('Error: Could not find icon button render box');
                                                        return;
                                                      }

                                                      final productPosition = iconBox.localToGlobal(Offset.zero);

                                                      // Create flying animation
                                                      if (mounted) {
                                                        _createFlyingAnimation(
                                                          productPosition,
                                                          product.id,
                                                        );
                                                      }

                                                      // Add to cart
                                                      debugPrint('Adding product ${product.id} to cart for user $userId');

                                                      await cartController.addItem(product.id, 1);

                                                    } catch (e, stackTrace) {
                                                      debugPrint('Error adding to cart: $e');
                                                      debugPrint('Stack trace: $stackTrace');

                                                      if (mounted) {
                                                        scaffoldMessenger.showSnackBar(
                                                          SnackBar(
                                                            content: Text('Failed to add item. Please try again.'),
                                                            duration: const Duration(seconds: 2),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  icon: Icon(
                                                    CupertinoIcons.cart,
                                                    color: Colors.blue,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // Render flying animations
          ..._flyingAnimations,
        ],
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
    final scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad),
    );

    // Animate opacity
    final opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad),
    );

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
             child:  Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(204, 63, 81, 181), // Blue with ~80% opacity
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(128, 63, 81, 181), // Blue with ~50% opacity
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


