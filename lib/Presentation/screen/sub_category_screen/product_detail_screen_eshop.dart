import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_in_Product_detail.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/storage/token_storage.dart' show TokenStorage;
import '../../../data/models/product_model_eshop.dart';
import '../../../provider/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  final int? subcategoryId;
  final String? subcategoryName;
  final User_AuthRepository repository;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.subcategoryId,
    this.subcategoryName,
    required this.repository,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductSku? selectedSku;
  bool isPressed = false;
  bool isPressed1 = false;
  bool pressed1 = false;
  bool pressed2 = false;

  int selectIndex = 0;
  final List<String> sizeOption = ['S', 'M', 'L', 'X', 'XL'];

  int selectColorIndex = 0;
  final List<Color> colorOption = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];
  bool isExpandedText = false;
  int currentIndex = 0;
  late PageController _controller;

  int getSkuStock(ProductSku sku) {
    return sku.quantity ?? 0;
  }

  @override
  void initState() {
    super.initState();

    _controller = PageController(); //  MUST HAVE THIS
    if (widget.product.skus.isNotEmpty) {
      selectedSku = widget.product.skus.first;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  List<String> images = [];

  List<String> getDisplayImages() {
    if (selectedSku != null &&
        selectedSku!.images != null &&
        selectedSku!.images!.isNotEmpty) {
      return selectedSku!.images!;
    }

    if (widget.product.mainImage.isNotEmpty) {
      return widget.product.mainImage;
    }

    return ['assets/images/default_image.png'];
  }

  Widget _buildSkuSelector() {
    final skus = widget.product.skus;

    if (skus.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skus.map((sku) {
            final isSelected = selectedSku?.id == sku.id;

            final String attrNameText = sku.attributes
                .map(
                  (attr) =>
                      attr.values.isNotEmpty ? attr.values.first.value : '',
                )
                .where((text) => text.isNotEmpty)
                .join(" - ");

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSku = sku;
                  currentIndex = 0;
                });

                _controller.jumpToPage(0);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.44,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attrNameText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? Colors.blueAccent : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      "\$${sku.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Text(
                    //   isAvailable ? "In Stock" : "Out of Stock",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: isAvailable ? Colors.green : Colors.red,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = getDisplayImages();
    final List<ProductAttribute> attributes;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(product.name, style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),

        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //image
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final image = images[index];

                        if (image.startsWith('http')) {
                          return Image.network(
                            image,
                            // fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) {
                              return Image.asset(
                                'assets/images/default_image.png',
                                fit: BoxFit.fill,
                              );
                            },
                          );
                        }

                        return Image.asset(image, fit: BoxFit.fill);
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  Center(
                    child: product.mainImage.isEmpty
                        ? const SizedBox.shrink()
                        : SmoothPageIndicator(
                            controller: _controller,
                            count: product.mainImage.length,
                            effect: const WormEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.blue,
                            ),
                          ),
                  ),
                  SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${currentIndex + 1} / ${product.mainImage.length}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Product Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and price
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Text(
                        selectedSku != null
                            ? "\$${selectedSku!.price.toStringAsFixed(2)}"
                            : "\$${widget.product.lowestPrice.toStringAsFixed(2)}", // បើមិនទាន់រើស ឲ្យបង្ហាញតម្លៃទាបជាងគេ
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent, // ពណ៌ក្រហមដូច Amazon
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Available Options",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildSkuSelector(),
                      SizedBox(height: 5),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          'Description',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),

                      Text(
                        selectedSku != null &&
                                selectedSku!.description != null &&
                                selectedSku!.description!.isNotEmpty
                            ? selectedSku!.description!
                            : widget.product.description,
                        maxLines: isExpandedText ? null : 6,
                        overflow: isExpandedText
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 16),

                      // Attributes
                      if (selectedSku != null &&
                          selectedSku!.attributes != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const SizedBox(height: 16),

                            // =========================

                            // ATTRIBUTES

                            // =========================
                            if (selectedSku != null &&
                                selectedSku!.attributes.isNotEmpty) ...[
                              const Text(
                                'Attributes',

                                style: TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,

                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ...selectedSku!.attributes.map((attribute) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // Attribute name
                                      SizedBox(
                                        width: 100,

                                        child: Text(
                                          attribute.name,

                                          style: const TextStyle(
                                            fontSize: 15,

                                            fontWeight: FontWeight.w600,

                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),

                                      const Text(
                                        ': ',

                                        style: TextStyle(
                                          fontSize: 15,

                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      // Attribute values
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,

                                          runSpacing: 6,

                                          children: attribute.values.map((
                                            value,
                                          ) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,

                                                    vertical: 5,
                                                  ),

                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,

                                                borderRadius:
                                                    BorderRadius.circular(6),

                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),

                                              child: Text(
                                                value.value,

                                                style: const TextStyle(
                                                  fontSize: 14,

                                                  color: Colors.black87,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpandedText = !isExpandedText;
                          });
                        },
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 50),
                          curve: Curves.easeInOut,
                          child: Text(
                            isExpandedText ? 'Show Less  ' : 'Show More...  ',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                      SizedBox(height: 10),

                      // Product Images show list of images from selectedSku or mainImage
                      Column(
                        children: List.generate(images.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                images[index],
                                height: 250,
                                width: double.infinity,
                                // fit: BoxFit.fill,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/default_image.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 20),

                      //delivery info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                pressed1 = !pressed1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              curve: Curves.bounceInOut,
                              transform: Matrix4.identity()
                                ..scale(pressed1 ? 1.0 : 1.02),
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: pressed1 ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: pressed1
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.1),
                                          blurRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: pressed1
                                          ? Colors.blueGrey
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(width: 5),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),

                                      Text(
                                        'WARRANTY',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text(
                                          '2 Years',
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //delivery info
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                pressed2 = !pressed2;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              curve: Curves.bounceInOut,
                              transform: Matrix4.identity()
                                ..scale(pressed2 ? 1.0 : 1.02),
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: pressed2 ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: pressed2
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.local_shipping_outlined,
                                      color: pressed2
                                          ? Colors.blueGrey
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(width: 5),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Shipping',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text(
                                          'Free Express',
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // More Products Section (Related Products from same subcategory)
          if (widget.subcategoryId != null &&
              widget.subcategoryName != null) ...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'More From ${widget.subcategoryName}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    // height: double.infinity,
                    height: 260,
                    child: ProductInProductDetail(
                      subcategoryId: widget.subcategoryId!,
                      subcategoryName: widget.subcategoryName!,
                      repository: widget.repository,
                    ),
                  ),

                  SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _buildnav(),
    );
  }

  Widget _buildnav() {
    final bool isInStock =
        selectedSku != null && (selectedSku!.quantity ?? 0) > 0;
    // final int stockCount = selectedSku?.quantity ?? 0;
    final stockCount = getSkuStock(selectedSku!);

    print("==================selectSku:  $selectedSku");
    print("==================isInStock :$isInStock");
    print("===================qty :${selectedSku?.quantity}");

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 1, bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedSku != null
                      ? "\$${selectedSku!.price.toStringAsFixed(2)}"
                      : "\$${widget.product.lowestPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                if (isInStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Only $stockCount left",
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    "Out of Stock",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isInStock
                        ? () async {
                            final storage = TokenStorage();
                            final userId = await storage.readUserId();
                            final token = await storage.readToken();
                            print("===============user id $userId");
                            print("===============token $token");

                            if (userId == null || token == null) {
                              _showLoginSheet(context);
                              return;
                            }

                            final cartController = ref.read(
                              cartControllerProvider.notifier,
                            );
                            try {
                              await cartController.addItem(selectedSku!.id, 1);
                              print("Add success");
                            } catch (e) {
                              print("Add failed: $e");
                            }

                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CartScreen(userId: userId, token: token),
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isInStock
                            ? const Color(0xFFF1B140)
                            : Colors.grey.shade300,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Add to Cart",
                            style: TextStyle(
                              color: isInStock
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: isInStock
                        ? () {
                            // Logic សម្រាប់កម្មង់ទិញភ្លាមៗ (Direct Checkout)
                          }
                        : null,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isInStock
                            ? const Color(0xFFE56A5D)
                            : Colors.grey.shade400,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "Buy Now",
                            style: TextStyle(
                              color: isInStock
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
